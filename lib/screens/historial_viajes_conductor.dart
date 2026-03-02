import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/auth_helper.dart'; // Ajusta según tu estructura
import '../services/viaje/viaje_service.dart'; // Ajusta según tu estructura

class HistorialViajesConductor extends StatefulWidget {
  const HistorialViajesConductor({super.key});

  @override
  State<HistorialViajesConductor> createState() => _HistorialViajesConductorState();
}

class _HistorialViajesConductorState extends State<HistorialViajesConductor> with SingleTickerProviderStateMixin {
  // --- PALETA DE COLORES ORIGINAL ---
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color statusGreen = Color(0xFF66BB6A);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color navBarBlue = Color(0xFFD6E8FF);

  int _selectedIndex = 2;
  String _activeFilter = 'Todos';
  bool _isVoiceActive = false;
  bool _isLoading = true;

  List<dynamic> _viajesCompletos = [];
  List<dynamic> _viajesFiltrados = [];

  late AnimationController _pulseController;
  final List<String> _filters = ['Todos', 'En curso', 'Finalizado', 'Cancelado', 'Pendiente'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed && _isVoiceActive) {
          _pulseController.forward();
        }
      });

    _cargarDatos();
  }

  // --- CARGA DE DATOS DESDE EL BACKEND ---
  Future<void> _cargarDatos() async {
    try {
      final data = await ViajeService.obtenerHistorialConductor();
      if (mounted) {
        setState(() {
          _viajesCompletos = data;
          _viajesFiltrados = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AuthHelper.manejarError(context, e);
      }
    }
  }

  // --- LÓGICA DE FILTRADO ---
  void _aplicarFiltro(String label) {
    setState(() {
      _activeFilter = label;
      if (label == 'Todos') {
        _viajesFiltrados = _viajesCompletos;
      } else {
        // Convierte "En curso" -> "en_curso" para comparar con el API
        String busca = label.toLowerCase().replaceAll(" ", "_");
        _viajesFiltrados = _viajesCompletos.where((v) {
          return v['estado'].toString().toLowerCase() == busca;
        }).toList();
      }
    });
  }

  // --- PROCESAMIENTO DE TEXTO DE DISCAPACIDADES ---
  Widget _buildDiscapacidadIcons(String? textoNecesidades, double sw) {
    if (textoNecesidades == null || textoNecesidades.isEmpty || textoNecesidades.toLowerCase() == 'ninguna') {
      return const SizedBox.shrink();
    }

    // Dividimos el String "Discapacidad auditiva, Movilidad reducida" por la coma
    List<String> lista = textoNecesidades.split(',').map((e) => e.trim().toLowerCase()).toList();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: lista.map((n) {
        String path = 'assets/tercera_edad.png'; // Por defecto
        
        if (n.contains('tercera edad')) path = 'assets/tercera_edad.png';
        else if (n.contains('movilidad') || n.contains('silla')) path = 'assets/silla_ruedas.png';
        else if (n.contains('auditiva')) path = 'assets/auditiva.png';
        else if (n.contains('obesidad')) path = 'assets/obesidad.png';
        else if (n.contains('visual')) path = 'assets/visual.png';

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: accentBlue.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Image.asset(
              path, 
              width: sp(28, sw), 
              height: sp(28, sw),
              errorBuilder: (c, e, s) => Icon(Icons.accessibility_new, color: primaryBlue, size: sp(20, sw)),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- UTILS DE DISEÑO ---
  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceActive = !_isVoiceActive;
      if (_isVoiceActive) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(sw),
          SizedBox(height: sp(45, sw)),
          _buildFilterList(sw),
          const SizedBox(height: 15),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : _viajesFiltrados.isEmpty
                    ? Center(child: Text('No hay registros', style: mBold(sw: sw, color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _viajesFiltrados.length,
                        itemBuilder: (context, index) => _buildHistoryCard(_viajesFiltrados[index], sw),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildHeader(double sw) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 110,
          width: double.infinity,
          decoration: const BoxDecoration(color: lightBlueBg),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('Historial de Viajes', style: mBold(size: 18, sw: sw)),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: sp(20, sw)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          bottom: -28,
          right: 25,
          child: GestureDetector(
            onTap: _toggleVoice,
            child: ScaleTransition(
              scale: _pulseController,
              child: Container(
                width: 65, height: 65,
                child: Image.asset(
                  _isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => CircleAvatar(
                    backgroundColor: _isVoiceActive ? Colors.red : primaryBlue,
                    child: Icon(_isVoiceActive ? Icons.graphic_eq : Icons.mic, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterList(double sw) {
    return SizedBox(
      height: sp(40, sw),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          bool isSelected = _activeFilter == _filters[index];
          return GestureDetector(
            onTap: () => _aplicarFiltro(_filters[index]),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(horizontal: sp(18, sw)),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : lightBlueBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: mBold(color: isSelected ? Colors.white : primaryBlue, size: 11, sw: sw),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(dynamic v, double sw) {
    // Determinar color de estado
    Color statusColor = statusGreen;
    String estado = v['estado'].toString().toLowerCase();
    if (estado == 'cancelado') statusColor = statusRed;
    if (estado == 'en_curso') statusColor = primaryBlue;
    if (estado == 'pendiente') statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(sp(15, sw)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
              child: Text(estado.replaceAll("_", " ").toUpperCase(), 
                style: mBold(color: Colors.white, size: 9, sw: sw)),
            ),
          ),
          const Text('--------------------------------------', 
            style: TextStyle(color: Colors.grey, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: Center(child: Text(v['punto_inicio'] ?? 'Origen', style: mBold(size: 13, sw: sw), overflow: TextOverflow.ellipsis))),
              const Text('---', style: TextStyle(color: Colors.grey)),
              Expanded(child: Center(child: Text(v['destino'] ?? 'Destino', style: mBold(size: 13, sw: sw), overflow: TextOverflow.ellipsis))),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: sp(10, sw), top: 5),
              child: Text('Fecha: ${v['fecha_inicio'] ?? '---'}', 
                style: mBold(color: accentBlue, size: 10, sw: sw)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: sp(22, sw),
                backgroundColor: lightBlueBg,
                backgroundImage: (v['foto_pasajero'] != null && v['foto_pasajero'].isNotEmpty)
                  ? NetworkImage(v['foto_pasajero']) as ImageProvider
                  : const AssetImage('assets/conductor.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v['nombre_pasajero'] ?? 'Pasajero', style: mBold(size: 13, sw: sw)),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(Icons.star, color: Colors.orange, size: sp(12, sw))),
                        Text(' 5.0', style: mBold(size: 9, color: primaryBlue, sw: sw)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildVerifyBadge(sw),
                  ],
                ),
              ),
              // Renderizado de iconos de discapacidad dinámicos
              _buildDiscapacidadIcons(v['necesidad_especial'], sw),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyBadge(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: sp(10, sw)),
          const SizedBox(width: 4),
          Text('Verificado', style: mBold(color: Colors.white, size: 8, sw: sw)),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 70, 
      decoration: const BoxDecoration(color: navBarBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, '/principal_conductor', sw),
          _navIcon(1, Icons.location_on, '/ruta_conductor', sw),
          _navIcon(2, Icons.history, '/historial_conductor', sw),
          _navIcon(3, Icons.person, '/perfil_conductor', sw),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, String route, double sw) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 26),
      ),
    );
  }
}