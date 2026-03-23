import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// Asegúrate de tener tus imports correctos
import '../app_theme.dart';
import 'chat_viaje.dart';
import '../services/viaje/viaje_service.dart'; // <-- IMPORT DEL SERVICE

class ViajeActualMapa extends StatefulWidget {
  const ViajeActualMapa({super.key});

  @override
  State<ViajeActualMapa> createState() => _ViajeActualMapaState();
}

class _ViajeActualMapaState extends State<ViajeActualMapa> {
  bool _panelExpanded = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // ── LÓGICA DE MAPA Y GPS ──
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  LatLng? _driverLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];

  // ── DATOS DEL BACKEND ──
  Map<String, dynamic>? _datosViaje;
  String? _idViaje;
  bool _isLoading = true;

  // 0 = En camino al pasajero | 1 = Pasajero a bordo | 2 = Llegando al destino
  int _tripPhase = 0;

  final List<Map<String, String>> _phases = [
    {'label': 'En camino', 'sub': 'Dirígete al punto de recogida'},
    {'label': 'En ruta', 'sub': 'Pasajero a bordo'},
    {'label': 'Llegando', 'sub': 'Próximo al destino'},
  ];

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  void initState() {
    super.initState();
    _iniciarRastreo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🚀 CAMBIO AQUI: Capturamos el argumento solo como String
    if (_idViaje == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _idViaje = args;
        _cargarDatosViaje();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  // ── FUNCIONES DE GPS Y OSRM ──

  Future<void> _cargarDatosViaje() async {
    if (_idViaje == null) return;

    try {
      final data = await ViajeService.obtenerViajeActual(_idViaje!);

      if (mounted) {
        setState(() {
          _datosViaje = data;
          final rutaData = data['ruta_data'] ?? data['ruta'];

          if (rutaData != null) {
            _pickupLocation = LatLng(
              double.parse(rutaData['origen']['lat'].toString()),
              double.parse(rutaData['origen']['lng'].toString()),
            );
            _destinationLocation = LatLng(
              double.parse(rutaData['destino']['lat'].toString()),
              double.parse(rutaData['destino']['lng'].toString()),
            );
          }
          _isLoading = false;
        });

        // Si ya tenemos el GPS encendido, trazamos ruta
        if (_driverLocation != null &&
            _pickupLocation != null &&
            _tripPhase == 0) {
          _obtenerRuta(_driverLocation!, _pickupLocation!);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error al cargar viaje: $e");
    }
  }

  Future<void> _iniciarRastreo() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _driverLocation = LatLng(pos.latitude, pos.longitude);
      });

      // Si los datos ya cargaron del API, trazar ruta
      if (_pickupLocation != null && _tripPhase == 0) {
        _obtenerRuta(_driverLocation!, _pickupLocation!);
      }
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _driverLocation = LatLng(position.latitude, position.longitude);
            });
          }
        });
  }

  Future<void> _obtenerRuta(LatLng origen, LatLng destino) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        if (mounted) {
          setState(() {
            _routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo ruta: $e");
    }
  }

  // ── CONTROL DE INTERFAZ ──

  void _togglePanel() {
    final target = _panelExpanded ? 0.42 : 0.12;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    setState(() => _panelExpanded = !_panelExpanded);
  }

  void _colapsarPanel() {
    _sheetController.animateTo(
      0.12,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    setState(
      () => _panelExpanded = true,
    ); // Se invierte porque queda minimizado
  }

  void _avanzarFase() async {
    if (_tripPhase < 2) {
      setState(() => _tripPhase++);
      _colapsarPanel();

      // NOTA: Aquí puedes llamar al Service para actualizar el estado en BD
      // await ViajeService.actualizarEstadoViaje(_idViaje!, _tripPhase.toString());

      if (_tripPhase == 1 &&
          _driverLocation != null &&
          _destinationLocation != null) {
        // Fase 1: Pasajero a bordo -> Ruta al destino final
        _obtenerRuta(_driverLocation!, _destinationLocation!);
      }
    } else {
      _mostrarFinViaje();
    }
  }

  void _mostrarFinViaje() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Finalizar viaje?',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Confirma que el pasajero llegó a su destino.',
              textAlign: TextAlign.center,
              style: mBold(color: AppColors.textSecondary, size: 13),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: mBold(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _positionStream?.cancel();
                      // NOTA: Llamar endpoint para finalizar el viaje
                      // ViajeService.finalizarViaje(_idViaje!);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Finalizar',
                      style: mBold(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── RENDERIZADO DE IMAGEN BASE64 ──
  Widget _buildAvatar(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.border,
        child: Icon(Icons.person, color: AppColors.primary, size: 28),
      );
    }
    try {
      final String cleanBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return CircleAvatar(
        radius: 26,
        backgroundImage: MemoryImage(base64Decode(cleanBase64)),
      );
    } catch (e) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.border,
        child: Icon(Icons.person, color: AppColors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── MAPA FUNCIONAL ──────────────────────────────────────────────
          Positioned.fill(
            child: (_isLoading || _driverLocation == null)
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _driverLocation!,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.tuapp.conductor',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5.0,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          if (_destinationLocation != null)
                            Marker(
                              point: _destinationLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.flag_rounded,
                                color: AppColors.error,
                                size: 40,
                              ),
                            ),
                          if (_pickupLocation != null && _tripPhase == 0)
                            Marker(
                              point: _pickupLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.person_pin_circle_rounded,
                                color: Colors.orange,
                                size: 40,
                              ),
                            ),
                          Marker(
                            point: _driverLocation!,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // ── Barra de navegación (instrucción) ─────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _positionStream?.cancel();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.turn_right_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _tripPhase == 0
                                    ? 'Dirígete hacia el pasajero'
                                    : 'Sigue la ruta al destino',
                                style: mBold(color: AppColors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Indicador de fase ─────────────────────────────────────────────
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: _buildPhaseIndicator(),
          ),

          // ── Panel inferior deslizable ─────────────────────────────────────
          if (!_isLoading) // Solo mostrar si ya cargaron los datos
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.42,
              minChildSize: 0.12,
              maxChildSize: 0.42,
              snap: true,
              snapSizes: const [0.12, 0.42],
              builder: (context, scrollController) =>
                  _buildBottomPanel(scrollController),
            ),
        ],
      ),
      // bottomNavigationBar: const DriverBottomNav(selectedIndex: 1), // Descomentar si usas la barra de nav inferior
    );
  }

  // ── FASE INDICATOR ────────────────────────────────────────────────────────

  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == _tripPhase;
          final done = i < _tripPhase;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: done || active
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phases[i]['label']!,
                        textAlign: TextAlign.center,
                        style: mBold(
                          size: 9,
                          color: active
                              ? AppColors.primary
                              : done
                              ? AppColors.textSecondary
                              : AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── PANEL INFERIOR ────────────────────────────────────────────────────────

  Widget _buildBottomPanel(ScrollController scrollController) {
    // Extracción dinámica de datos desde el JSON
    final pasajeroData = _datosViaje?['pasajero'] ?? {};
    final rutaData = _datosViaje?['ruta_data'] ?? _datosViaje?['ruta'] ?? {};

    final nombre = pasajeroData['nombre'] ?? 'Cargando...';
    final fotoBase64 = pasajeroData['foto_perfil'];
    final calificacion = pasajeroData['calificacion'] ?? '--';
    final discapacidad = pasajeroData['discapacidad'] ?? 'Ninguna';

    final direccionDestino =
        rutaData['destino']?['direccion'] ?? 'Dirección no disponible';
    final tiempo = rutaData['duracion_aprox_min'] != null
        ? "${rutaData['duracion_aprox_min']} min"
        : "-- min";
    final distancia = rutaData['distancia_km'] != null
        ? "${rutaData['distancia_km']} km"
        : "-- km";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill
              GestureDetector(
                onTap: _togglePanel,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ETA + distancia
              Row(
                children: [
                  _etaChip(
                    Icons.access_time_rounded,
                    tiempo, // DINÁMICO
                    AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _etaChip(
                    Icons.route_rounded,
                    distancia, // DINÁMICO
                    AppColors.textSecondary,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'En Tiempo', // Puedes hacerlo dinámico si tienes llegada estimada
                      style: mBold(color: AppColors.success, size: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Info pasajero
              Row(
                children: [
                  _buildAvatar(fotoBase64), // DINÁMICO
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: mBold(size: 15)), // DINÁMICO
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              calificacion, // DINÁMICO
                              style: mBold(
                                color: AppColors.textSecondary,
                                size: 12,
                              ),
                            ),
                            if (discapacidad != 'Ninguna' &&
                                discapacidad.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.accessible_forward_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  discapacidad, // DINÁMICO
                                  overflow: TextOverflow.ellipsis,
                                  style: mBold(
                                    color: AppColors.textSecondary,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botones contacto
                  _circleBtn(Icons.phone_rounded, AppColors.primary, () {
                    // Acción de llamar
                  }),
                  const SizedBox(width: 10),
                  _circleBtn(Icons.message_rounded, AppColors.primary, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatViaje(
                          nombreContacto: nombre, // DINÁMICO
                          esConductor: true,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),

              // Destino
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        direccionDestino, // DINÁMICO
                        style: mBold(size: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botón de acción principal
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _avanzarFase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tripPhase == 2
                        ? AppColors.success
                        : AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _tripPhase == 0
                        ? 'Confirmar recogida'
                        : _tripPhase == 1
                        ? 'Iniciar ruta'
                        : 'Finalizar viaje',
                    style: mBold(color: AppColors.white, size: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etaChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: mBold(color: color, size: 13)),
      ],
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
