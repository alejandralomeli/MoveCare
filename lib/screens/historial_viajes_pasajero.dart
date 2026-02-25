import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/auth_helper.dart';
import '../services/viaje/viaje_service.dart';

class HistorialViajesPasajero extends StatefulWidget {
  const HistorialViajesPasajero({super.key});

  @override
  State<HistorialViajesPasajero> createState() => _HistorialViajesPasajero();
}

class _HistorialViajesPasajero extends State<HistorialViajesPasajero>
    with TickerProviderStateMixin {
  // Colores
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  // Variables de estado
  int _selectedIndex = 2;
  String _filterSelected = 'Todos';
  bool _isVoiceActive = false;
  bool _isLoading = true;

  // Listas de datos
  List<dynamic> _viajesCompletos = [];
  List<dynamic> _viajesFiltrados = [];

  // Controladores de animación
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Filtros completos (HEAD)
  final List<String> filters = [
    'Todos',
    'Pendiente',
    'Agendado',
    'En curso',
    'Finalizado',
    'Cancelado',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Inicializar animación (Main)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Cargar datos (HEAD)
    _cargarHistorial();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Estilo de texto flexible (Basado en Main)
  TextStyle mFont({
    Color color = primaryBlue,
    double size = 14,
    FontWeight weight = FontWeight.w800,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  Future<void> _cargarHistorial() async {
    try {
      final data = await ViajeService.obtenerHistorial();
      if (mounted) {
        setState(() {
          _viajesCompletos = data;
          _viajesFiltrados = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false); // Asegurar que deje de cargar
        AuthHelper.manejarError(context, e);
      }
    }
  }

  void _aplicarFiltro(String filtro) {
    setState(() {
      _filterSelected = filtro;
      if (filtro == 'Todos') {
        _viajesFiltrados = _viajesCompletos;
      } else {
        String filtroNormalizado = filtro.replaceAll(" ", "_");
        _viajesFiltrados = _viajesCompletos
            .where(
              (v) =>
                  v['estado'].toString().toLowerCase() ==
                  filtroNormalizado.toLowerCase(),
            )
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_curso':
        return const Color(0xFF1559B2);
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'agendado':
        return Colors.orange;
      case 'pendiente':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(), // Header animado de Main
            const SizedBox(height: 35),
            _buildFilterMenu(),
            Expanded(
              // Lógica de lista dinámica de HEAD
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    )
                  : _viajesFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        "No hay viajes en esta categoría",
                        style: mFont(
                          color: Colors.grey,
                          weight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: _viajesFiltrados.length,
                      itemBuilder: (context, index) {
                        final viaje = _viajesFiltrados[index];
                        return _buildTripCard(
                          viaje['estado'].toString().replaceAll("_", " "),
                          _getStatusColor(viaje['estado']),
                          viaje['fecha_inicio'] ?? 'Fecha desconocida',
                          viaje['punto_inicio'] ?? 'Origen desconocido',
                          viaje['destino'] ?? 'Múltiples destinos',
                          viaje['nombre_conductor'],
                          viaje['foto_conductor'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Header interactivo con animación (Main)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            bottom: 35,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: primaryBlue,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Center(
            child: Text(
              'Historial de Viajes',
              style: mFont(
                size: 20,
                color: Colors.black,
                weight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -32,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isVoiceActive = !_isVoiceActive;
                  if (_isVoiceActive) {
                    _pulseController.repeat(reverse: true);
                  } else {
                    _pulseController.stop();
                    _pulseController.reset();
                  }
                });
              },
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVoiceActive ? Colors.red : primaryBlue,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isVoiceActive ? Icons.graphic_eq : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = _filterSelected == filter;
          return GestureDetector(
            onTap: () => _aplicarFiltro(filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : lightBlueBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: mFont(
                  color: isSelected ? Colors.white : primaryBlue,
                  size: 13,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Tarjeta híbrida: Datos de HEAD + Estilo de Main
  Widget _buildTripCard(
    String status,
    Color statusColor,
    String date,
    String origen,
    String destino,
    String? conductor,
    String? foto,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Badge de estado
          Positioned(
            right: 20,
            top: 45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                status,
                style: mFont(
                  color: Colors.white,
                  size: 11,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Sección de Origen y Destino (Datos de HEAD, Layout limpio)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        origen,
                        style: mFont(
                          size: 14,
                          color: Colors.black,
                          weight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.black26,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        destino,
                        textAlign: TextAlign.end,
                        style: mFont(
                          size: 14,
                          color: Colors.black,
                          weight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  'Fecha: $date',
                  style: mFont(
                    size: 12,
                    color: accentBlue,
                    weight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 15),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 15),

                // Sección Conductor (Datos de HEAD + UI de Main)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: containerBlue,
                      backgroundImage: (foto != null && foto.isNotEmpty)
                          ? NetworkImage(foto) as ImageProvider
                          : const AssetImage('assets/conductor.png'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conductor ?? 'Buscando conductor...',
                          style: mFont(
                            size: 14,
                            color: Colors.black,
                            weight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Estrellas y Verificado (UI de Main)
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: mFont(
                                      color: Colors.white,
                                      size: 9,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, '/agendar_viaje'),
          _navIcon(2, Icons.history, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, '/perfil_pasajero'),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, String routeName) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}
