import 'dart:convert'; // 🔥 NUEVO: Necesario para decodificar la foto en Base64
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

import 'widgets/map_widget.dart';
import 'widgets/route_map_widget.dart';
import 'widgets/modals/viaje_detalles_modal.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../services/viaje/viaje_service.dart';
import '../core/utils/auth_helper.dart';

class PrincipalPasajero extends StatefulWidget {
  const PrincipalPasajero({super.key});

  @override
  State<PrincipalPasajero> createState() => _PrincipalPasajeroState();
}

class _PrincipalPasajeroState extends State<PrincipalPasajero>
    with SingleTickerProviderStateMixin {
  // Colores consistentes
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color buttonLightBlue = Color(0xFF64A1F4);
  static const Color darkBlue = Color(0xFF0D47A1);

  // Estado lógico
  bool _loadingHome = true;
  bool _isListening = false;
  String _selectedDateNum = '';
  int _selectedIndex = 0;

  List<DateTime> _calendarDates = [];
  Map<String, dynamic>? _viajeProximo;
  List<dynamic> _historialViajes = [];

  // Variables para almacenar la ruta del viaje próximo
  LatLng? _startCoord;
  LatLng? _endCoord;
  List<LatLng> _routePoints = [];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadHome();
  }

  void _initAnimation() {
    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
          lowerBound: 1.0,
          upperBound: 1.15,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed && _isListening) {
            _pulseController.forward();
          }
        });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _loadHome() async {
    try {
      final homeData = await HomeService.getHome(role: "pasajero");
      final userProvider = context.read<UserProvider>();
      userProvider.setUserFromJson(homeData["usuario"]);

      if (homeData['viaje_proximo'] != null) {
        _viajeProximo = homeData['viaje_proximo'];

        final fechaViaje = DateTime.parse(_viajeProximo!['fecha_hora_inicio']);
        _buildCalendarDates(fechaViaje);

        // Lógica para extraer la ruta guardada en el backend
        if (_viajeProximo!['ruta'] != null) {
          try {
            List<dynamic> rutaJson = _viajeProximo!['ruta'];
            _routePoints = rutaJson.map((punto) {
              if (punto is Map) {
                return LatLng(
                  (punto['lat'] ?? punto[1]) * 1.0,
                  (punto['lng'] ?? punto['lon'] ?? punto[0]) * 1.0,
                );
              } else if (punto is List) {
                return LatLng(punto[0] * 1.0, punto[1] * 1.0);
              }
              return const LatLng(0, 0);
            }).toList();

            if (_routePoints.isNotEmpty) {
              _startCoord = _routePoints.first;
              _endCoord = _routePoints.last;
            }
          } catch (e) {
            print("Error al decodificar la ruta del viaje próximo: $e");
          }
        }
      } else {
        _buildCalendarDates(DateTime.now());
      }

      _historialViajes = homeData['historial'] ?? [];
      setState(() => _loadingHome = false);
    } catch (e) {
      AuthHelper.manejarError(context, e);
    }
  }

  void _mostrarDialogoCancelacion(String idViaje) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Cancelar viaje",
            style: mExtrabold(size: 18, color: darkBlue),
          ),
          content: Text(
            "¿Desea cancelar el viaje? Esta acción no se puede deshacer.",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("Volver", style: mExtrabold(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: statusRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _procesarCancelacion(idViaje);
              },
              child: Text(
                "Sí, cancelar",
                style: mExtrabold(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _procesarCancelacion(String idViaje) async {
    setState(() => _loadingHome = true);

    try {
      await ViajeService.cancelarViaje(idViaje);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje cancelado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadHome();
    } catch (e) {
      setState(() => _loadingHome = false);
      AuthHelper.manejarError(context, e);
    }
  }

  void _buildCalendarDates(DateTime baseDate) {
    _calendarDates = List.generate(
      5,
      (i) => baseDate.add(Duration(days: i - 2)),
    );
    _selectedDateNum = baseDate.day.toString();
  }

  // --- INTERFAZ DE VOZ ---
  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  // --- MODAL AGENDAR ---
  void _mostrarPanelAgendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _bottomSheetContent(context),
    );
  }

  // --- HELPERS DE ESTILO ---
  TextStyle mExtrabold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHome) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    // 🔥 1. LEEMOS AL USUARIO DEL PROVIDER
    final user = context.watch<UserProvider>().user;

    // 🔥 2. PREPARAMOS LA FOTO DE PERFIL DECODIFICADA
    ImageProvider imagenPerfil = const AssetImage('assets/pasajero.png'); 
    
    if (user != null && user.fotoPerfil.isNotEmpty) {
      try {
        String base64String = user.fotoPerfil;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        imagenPerfil = MemoryImage(base64Decode(base64String));
      } catch (e) {
        debugPrint("Error decodificando foto de perfil: $e");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 3. MANDAMOS LA IMAGEN Y EL NOMBRE AL HEADER
                _buildHeader(user?.nombre ?? 'Usuario', imagenPerfil),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        _viajeProximo != null
                            ? 'Ruta de tu próximo viaje'
                            : 'Ubicación actual',
                        style: mExtrabold(size: 18),
                      ),
                      const SizedBox(height: 10),
                      _buildMapSection(),
                      const SizedBox(height: 25),
                      Text('Próximo viaje', style: mExtrabold(size: 18)),
                      const SizedBox(height: 10),
                      _buildNextTripCard(),
                      const SizedBox(height: 20),
                      _buildCalendarRow(),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildAgendarButton(),
                      ),
                      const SizedBox(height: 25),
                      Text('Historial de viajes', style: mExtrabold(size: 18)),
                      const SizedBox(height: 10),
                      _buildTripHistory(),
                      const SizedBox(height: 30),
                      _buildReportButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildVoiceButton(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  // --- WIDGETS COMPONENTES ---

  // 🔥 4. ACEPTAMOS LA IMAGEN COMO PARÁMETRO EN EL HEADER
  Widget _buildHeader(String name, ImageProvider imagenPerfil) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: 120, width: double.infinity, color: lightBlueBg),
        Positioned(
          bottom: -50,
          left: 20,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundImage: imagenPerfil, // 🔥 USAMOS LA IMAGEN AQUÍ
            ),
          ),
        ),
        Positioned(
          bottom: -35,
          left: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido!',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(name, style: mExtrabold(size: 18, color: primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceButton() {
    return Positioned(
      top: 80,
      right: 20,
      child: GestureDetector(
        onTap: _toggleListening,
        child: ScaleTransition(
          scale: _pulseController,
          child: Image.asset(
            _isListening ? 'assets/escuchando.png' : 'assets/controlvoz.png',
            width: 65,
            height: 65,
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: (_viajeProximo != null && _routePoints.isNotEmpty)
            ? RouteMapWidget(
                startCoord: _startCoord,
                endCoord: _endCoord,
                routePoints: _routePoints,
                isLoading: false,
              )
            : const MapWidget(),
      ),
    );
  }

  Widget _buildNextTripCard() {
    if (_viajeProximo == null) {
      return Text(
        "No tienes viajes programados",
        style: mExtrabold(color: Colors.grey),
      );
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _viajeProximo!['destino'] ?? 'Destino',
                      style: mExtrabold(size: 16),
                    ),
                    Text(
                      'Conductor: ${_viajeProximo!['nombre_conductor'] ?? 'Asignando...'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '9:30 AM',
                  style: mExtrabold(color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionBtn(
                'Ver detalles',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        ViajeDetallesModal(viaje: _viajeProximo!, esConductor: false),
                  );
                },
              ),
              const SizedBox(width: 10),
              _actionBtn(
                'Cancelar',
                color: statusRed,
                onPressed: () {
                  _mostrarDialogoCancelacion(
                    _viajeProximo!['id_viaje'].toString(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _calendarDates.map((date) => _calendarDay(date)).toList(),
    );
  }

  Widget _calendarDay(DateTime date) {
    bool isSelected = _selectedDateNum == date.day.toString();
    String dayLetter = ['D', 'L', 'M', 'M', 'J', 'V', 'S'][date.weekday % 7];

    return GestureDetector(
      onTap: () => setState(() => _selectedDateNum = date.day.toString()),
      child: Container(
        width: 55,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Text(
                dayLetter,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: mExtrabold(color: primaryBlue, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHistory() {
    if (_historialViajes.isEmpty) return const Text("Sin historial");
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue, width: 1.5),
      ),
      child: Column(
        children: _historialViajes.take(3).map((v) => _historyItem(v)).toList(),
      ),
    );
  }

  Widget _historyItem(dynamic viaje) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text("Oct 28", style: mExtrabold(size: 12)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              viaje['destino'] ?? 'Viaje',
              style: mExtrabold(color: primaryBlue, size: 13),
            ),
          ),
          Text(
            viaje['estado'] ?? 'Finalizado',
            style: mExtrabold(color: statusRed, size: 10),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label, {
    Color? color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? buttonLightBlue,
          elevation: 0,
        ),
        child: Text(label, style: mExtrabold(color: Colors.white, size: 11)),
      ),
    );
  }

  Widget _buildAgendarButton() {
    return ElevatedButton(
      onPressed: () => _mostrarPanelAgendar(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonLightBlue,
        shape: const StadiumBorder(),
      ),
      child: Text('Agendar viaje', style: mExtrabold(color: Colors.black)),
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.error, color: Colors.white),
        label: Text(
          'Reportar incidencia',
          style: mExtrabold(color: Colors.white, size: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: statusRed,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _bottomSheetContent(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tipo de Viaje',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _optionBtn('Un destino', Colors.white, context, () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/agendar_viaje');
          }),
          const SizedBox(height: 15),
          _optionBtn('Dos o más destinos', buttonLightBlue, context, () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/agendar_varios_destinos');
          }),
        ],
      ),
    );
  }

  Widget _optionBtn(
    String text,
    Color color,
    BuildContext context,
    VoidCallback onPressed,
  ) {
    final Color textColor = (color == Colors.white)
        ? primaryBlue
        : Colors.white;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFD6E8FF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
          (index) => _navIcon(
            index,
            [Icons.home, Icons.location_on, Icons.history, Icons.person][index],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pushNamed(
          context,
          [
            '/principal_pasajero',
            '/agendar_viaje',
            '/historial_viajes_pasajero',
            '/perfil_pasajero',
          ][index],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 26),
      ),
    );
  }
}
