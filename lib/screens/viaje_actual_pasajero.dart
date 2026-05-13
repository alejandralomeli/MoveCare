import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../services/viaje/viaje_service.dart';

// Importamos los widgets modulares
import 'widgets/indicador_fases_pasajero.dart';
import 'widgets/panel_inferior_viaje_pasajero.dart';

class ViajeActualPasajero extends StatefulWidget {
  const ViajeActualPasajero({super.key});

  @override
  State<ViajeActualPasajero> createState() => _ViajeActualPasajeroState();
}

class _ViajeActualPasajeroState extends State<ViajeActualPasajero> {
  bool _panelExpanded = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  // COMENTADO: Lógica de ubicación del chofer
  // Timer? _driverLocationTimer;
  // LatLng? _driverLocation;

  LatLng? _myLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];

  Map<String, dynamic>? _datosViaje;
  String? _idViaje;
  bool _isLoading = true;
  String _estadoViaje = 'Agendado';
  String _pinSeguridad = '----';

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
    _iniciarRastreoPasajero();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    // _driverLocationTimer?.cancel(); // COMENTADO
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosViaje() async {
    if (_idViaje == null) return;
    try {
      final data = await ViajeService.obtenerViajeActual(_idViaje!);
      if (mounted) {
        setState(() {
          _datosViaje = data;
          _estadoViaje = data['estado'] ?? 'Agendado';
          _pinSeguridad = data['pin_seguridad'] ?? '0000';

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

          // COMENTADO: Extracción de ubicación del conductor
          /*
          if (data['lat_conductor'] != null && data['lng_conductor'] != null) {
            _driverLocation = LatLng(
              double.parse(data['lat_conductor'].toString()),
              double.parse(data['lng_conductor'].toString()),
            );
          }
          */

          _isLoading = false;
        });

        _trazarRutaBase();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Ahora solo traza la ruta global del viaje: Origen -> Destino
  void _trazarRutaBase() {
    if (_pickupLocation != null && _destinationLocation != null) {
      _obtenerRuta(_pickupLocation!, _destinationLocation!);
    }
  }

  Future<void> _iniciarRastreoPasajero() async {
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
        _myLocation = LatLng(pos.latitude, pos.longitude);
      });
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
              _myLocation = LatLng(position.latitude, position.longitude);
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
            _routePoints = coords
                .map(
                  (c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ),
                )
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo ruta: $e");
    }
  }

  void _togglePanel() {
    final target = _panelExpanded ? 0.42 : 0.12;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    setState(() => _panelExpanded = !_panelExpanded);
  }

  void _accionPasajero() {
    if (_estadoViaje == 'Agendado') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Dicta este PIN a tu conductor',
            style: mBold(size: 16),
            textAlign: TextAlign.center,
          ),
          content: Text(
            _pinSeguridad,
            style: GoogleFonts.montserrat(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: mBold(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: (_isLoading || _myLocation == null)
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _pickupLocation ?? _myLocation!,
                      initialZoom: 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.tuapp.pasajero',
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
                          // Marcador Destino (B)
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
                          // Marcador Origen (A)
                          if (_pickupLocation != null)
                            Marker(
                              point: _pickupLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.person_pin_circle_rounded,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),

                          // COMENTADO: Marcador del Conductor
                          /*
                          if (_driverLocation != null)
                            Marker(
                              point: _driverLocation!,
                              width: 50,
                              height: 50,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                                ),
                                child: const Icon(Icons.directions_car_rounded, color: Colors.orange, size: 30),
                              ),
                            ),
                          */
                        ],
                      ),
                    ],
                  ),
          ),

          // ── BARRA SUPERIOR (Regresa a /principal_pasajero) ──
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
                        Navigator.pushReplacementNamed(
                          context,
                          '/principal_pasajero',
                        );
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
                  ],
                ),
              ),
            ),
          ),

          // ── INDICADOR DE FASE ──
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: IndicadorFases(
              estadoViaje: _estadoViaje, // El que viene de tu backend
              esConductor: false, // <--- Así de simple
            ),
          ),

          // ── PANEL INFERIOR ──
          if (!_isLoading)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.42,
              minChildSize: 0.12,
              maxChildSize: 0.42,
              snap: true,
              snapSizes: const [0.12, 0.42],
              builder: (context, scrollController) =>
                  PanelInferiorViajePasajero(
                    scrollController: scrollController,
                    datosViaje: _datosViaje,
                    estadoViaje: _estadoViaje,
                    onTogglePanel: _togglePanel,
                    onAvanzarFase: _accionPasajero,
                  ),
            ),
        ],
      ),
    );
  }
}
