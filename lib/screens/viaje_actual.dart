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

// Importamos los nuevos widgets modulares
import 'widgets/indicador_fases.dart';
import 'widgets/panel_inferior_viaje.dart';
import 'widgets/modals/modales_viaje.dart';

class ViajeActualMapa extends StatefulWidget {
  const ViajeActualMapa({super.key});

  @override
  State<ViajeActualMapa> createState() => _ViajeActualMapaState();
}

class _ViajeActualMapaState extends State<ViajeActualMapa> {
  bool _panelExpanded = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  LatLng? _driverLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];

  Map<String, dynamic>? _datosViaje;
  String? _idViaje;
  bool _isLoading = true;

  int _tripPhase = 0; // 0 = En camino, 1 = A bordo, 2 = Llegando

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
        if (_driverLocation != null &&
            _pickupLocation != null &&
            _tripPhase == 0) {
          _obtenerRuta(_driverLocation!, _pickupLocation!);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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

  void _colapsarPanel() {
    _sheetController.animateTo(
      0.12,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    setState(() => _panelExpanded = true);
  }

  void _avanzarFase() async {
    if (_driverLocation == null) return;

    // ── FASE 0: Validar origen y pedir PIN ──
    if (_tripPhase == 0) {
      if (_pickupLocation != null) {
        double distanciaOrigen = Geolocator.distanceBetween(
          _driverLocation!.latitude, _driverLocation!.longitude,
          _pickupLocation!.latitude, _pickupLocation!.longitude,
        );

        if (distanciaOrigen > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Acércate a menos de 100m. Actual: ${distanciaOrigen.toInt()}m'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        ModalesViaje.mostrarModalPin(context, (String pin) async {
          try {
            bool pinValido = await ViajeService.validarPinViaje(_idViaje!, pin);
            if (pinValido) {
              setState(() => _tripPhase = 1);
              _colapsarPanel();
              
              if (_destinationLocation != null) {
                setState(() => _routePoints.clear());
                _obtenerRuta(_driverLocation!, _destinationLocation!);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN incorrecto.'), backgroundColor: AppColors.error),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
            );
          }
        });
        return; 
      }
    } 
    // ── FASE 1: Transición hacia Llegada ──
    else if (_tripPhase == 1) {
      setState(() => _tripPhase = 2);
      _colapsarPanel();
    } 
    // ── FASE 2: Validar destino y procesar cobro ──
    else if (_tripPhase == 2) {
      if (_destinationLocation != null) {
        double distanciaDestino = Geolocator.distanceBetween(
          _driverLocation!.latitude, _driverLocation!.longitude,
          _destinationLocation!.latitude, _destinationLocation!.longitude,
        );

        if (distanciaDestino > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debes estar en el destino. Actual: ${distanciaDestino.toInt()}m'),
              backgroundColor: AppColors.error,
            ),
          );
          return; 
        }

        // Extraemos info de pago de los detalles del viaje
        String idMetodo = _datosViaje?['id_metodo'] ?? 'efectivo';
        
        // Manejo seguro del costo parseándolo a double
        double costoViaje = 0.0;
        if (_datosViaje != null && _datosViaje!['costo'] != null) {
          costoViaje = double.tryParse(_datosViaje!['costo'].toString()) ?? 0.0;
        }

        // Llamamos al modal dinámico
        ModalesViaje.mostrarFinViaje(
          context: context,
          idMetodo: idMetodo,
          costo: costoViaje,
          onFinalizar: () async {
            _positionStream?.cancel();
            
            if (idMetodo.toLowerCase() != 'efectivo') {
              // TODO: Aquí llamarás al nuevo endpoint de Stripe del backend (cobrar_con_tarjeta_guardada)
              print("Cobrando off-session a la tarjeta: $idMetodo");
            } else {
              print("El conductor confirmó haber recibido el efectivo.");
            }

            // TODO: Llamar al endpoint para marcar el viaje como FINALIZADO en tu BD general

            Navigator.pop(context); // Vuelve al Home tras acabar todo
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── MAPA FUNCIONAL ──
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

          // ── BARRA SUPERIOR ──
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

          // ── INDICADOR DE FASE (Widget Modular) ──
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: IndicadorFases(tripPhase: _tripPhase),
          ),

          // ── PANEL INFERIOR (Widget Modular) ──
          if (!_isLoading)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.42,
              minChildSize: 0.12,
              maxChildSize: 0.42,
              snap: true,
              snapSizes: const [0.12, 0.42],
              builder: (context, scrollController) => PanelInferiorViaje(
                scrollController: scrollController,
                datosViaje: _datosViaje,
                tripPhase: _tripPhase,
                onTogglePanel: _togglePanel,
                onAvanzarFase: _avanzarFase,
              ),
            ),
        ],
      ),
    );
  }
}