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

  // 1. Variable que almacena el estado real traído del backend
  String _estadoViaje = 'Agendado';

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

          // 2. Leemos el estado directamente del JSON del back
          _estadoViaje = data['estado'] ?? 'Agendado';

          final rutaData = data['ruta_data'] ?? data['ruta'];
          if (rutaData != null) {
            _pickupLocation = LatLng(
              double.parse(rutaData['origen']['lat'].toString()),
              double.parse(rutaData['origen']['lon'].toString()),
            );
            _destinationLocation = LatLng(
              double.parse(rutaData['destino']['lat'].toString()),
              double.parse(rutaData['destino']['lon'].toString()),
            );
          }
          _isLoading = false;
        });

        // 3. Trazamos la ruta correcta dependiendo del estado inicial
        if (_driverLocation != null) {
          if (_estadoViaje == 'Agendado' && _pickupLocation != null) {
            _obtenerRuta(_driverLocation!, _pickupLocation!);
          } else if (_estadoViaje == 'En_curso' &&
              _destinationLocation != null) {
            _obtenerRuta(_driverLocation!, _destinationLocation!);
          }
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
      // Trazar ruta inicial según el estado actual
      if (_estadoViaje == 'Agendado' && _pickupLocation != null) {
        _obtenerRuta(_driverLocation!, _pickupLocation!);
      } else if (_estadoViaje == 'En_curso' && _destinationLocation != null) {
        _obtenerRuta(_driverLocation!, _destinationLocation!);
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
    setState(() => _panelExpanded = false);
  }

  // 4. Lógica de avance sincronizada con el backend
  void _avanzarFase() async {
    if (_driverLocation == null) return;

    // ── ESTADO: Agendado -> Validar PIN e iniciar viaje ──
    if (_estadoViaje == 'Agendado') {
      if (_pickupLocation != null) {
        double distanciaOrigen = Geolocator.distanceBetween(
          _driverLocation!.latitude,
          _driverLocation!.longitude,
          _pickupLocation!.latitude,
          _pickupLocation!.longitude,
        );

        if (distanciaOrigen > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Acércate a menos de 100m. Actual: ${distanciaOrigen.toInt()}m',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        ModalesViaje.mostrarModalPin(context, (String pin) async {
          try {
            // Nota: Se asume que este endpoint valida y cambia el estado en BD a 'En_curso'
            bool pinValido = await ViajeService.validarPinViaje(_idViaje!, pin);
            if (pinValido) {
              setState(
                () => _estadoViaje = 'En_curso',
              ); // Actualizamos UI local
              _colapsarPanel();

              if (_destinationLocation != null) {
                setState(() => _routePoints.clear());
                _obtenerRuta(_driverLocation!, _destinationLocation!);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN incorrecto.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
        return;
      }
    }
    // ── ESTADO: En_curso -> Llegar al destino y finalizar ──
    else if (_estadoViaje == 'En_curso') {
      if (_destinationLocation != null) {
        double distanciaDestino = Geolocator.distanceBetween(
          _driverLocation!.latitude,
          _driverLocation!.longitude,
          _destinationLocation!.latitude,
          _destinationLocation!.longitude,
        );

        if (distanciaDestino > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Debes estar en el destino. Actual: ${distanciaDestino.toInt()}m',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        String idMetodo = _datosViaje?['id_metodo'] ?? 'efectivo';
        double costoViaje = 0.0;
        if (_datosViaje != null && _datosViaje!['costo'] != null) {
          costoViaje = double.tryParse(_datosViaje!['costo'].toString()) ?? 0.0;
        }

        ModalesViaje.mostrarFinViaje(
          context: context,
          idMetodo: idMetodo,
          costo: costoViaje,
          onFinalizar: () async {
            try {
              // DETENEMOS RASTREO LOCAL
              _positionStream?.cancel();

              if (idMetodo.toLowerCase() != 'efectivo') {
                debugPrint("Cobrando off-session a la tarjeta: $idMetodo");
              } else {
                debugPrint("El conductor confirmó haber recibido el efectivo.");
              }

              // Llamada real al backend para marcar el viaje como 'Finalizado'
              await ViajeService.finalizarViaje(_idViaje!);

              if (mounted) {
                Navigator.pop(context); // Cierra el modal
                // Redirigir a la principal del conductor tras finalizar
                Navigator.pushReplacementNamed(context, '/principal_conductor');
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al finalizar viaje: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
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
                          // Ocultar origen cuando ya estemos en ruta
                          if (_pickupLocation != null &&
                              _estadoViaje == 'Agendado')
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

          // ── BARRA SUPERIOR (Solo botón de regreso) ──
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
                        // Redirige explícitamente a la ruta del conductor
                        Navigator.pushReplacementNamed(
                          context,
                          '/principal_conductor',
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

          // ── INDICADOR DE FASE (Widget Modular) ──
          Positioned(
            top: 80, // Se mantiene en su lugar
            left: 16,
            right: 16,
            child: IndicadorFases(estadoViaje: _estadoViaje),
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
                estadoViaje: _estadoViaje,
                onTogglePanel: _togglePanel,
                onAvanzarFase: _avanzarFase,
              ),
            ),
        ],
      ),
    );
  }
}
