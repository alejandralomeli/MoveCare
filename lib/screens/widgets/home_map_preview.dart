import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class HomeMapPreview extends StatefulWidget {
  final Map<String, dynamic>? viajeProximo;
  final LatLng? ubicacionConductor;
  final VoidCallback? onOpenRoute;

  const HomeMapPreview({
    super.key,
    this.viajeProximo,
    this.ubicacionConductor,
    this.onOpenRoute,
  });

  @override
  State<HomeMapPreview> createState() => _HomeMapPreviewState();
}

class _HomeMapPreviewState extends State<HomeMapPreview> {
  bool _isLoading = false;
  List<LatLng> _routePoints = [];
  LatLng? _startCoord;
  LatLng? _endCoord;

  @override
  void initState() {
    super.initState();
    _procesarDatosMapa();
  }

  @override
  void didUpdateWidget(HomeMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viajeProximo != oldWidget.viajeProximo ||
        widget.ubicacionConductor != oldWidget.ubicacionConductor) {
      _procesarDatosMapa();
    }
  }

  Future<void> _procesarDatosMapa() async {
    // CASO 1: NO hay viaje próximo
    if (widget.viajeProximo == null) {
      if (mounted) {
        setState(() {
          _startCoord = widget.ubicacionConductor;
          _endCoord = null;
          _routePoints = [];
          _isLoading = false;
        });
      }
      return;
    }

    // CASO 2: SÍ hay viaje próximo
    setState(() => _isLoading = true);

    try {
      final v = widget.viajeProximo!;
      List<LatLng> puntosRuta = [];
      LatLng? start;
      LatLng? end;

      // 🔥 CORRECCIÓN: Leemos directamente del objeto "ruta" de tu JSON
      if (v['ruta'] != null) {
        final ruta = v['ruta'];
        
        if (ruta['origen'] != null) {
          start = LatLng(
            double.parse(ruta['origen']['lat'].toString()),
            double.parse(ruta['origen']['lng'].toString()),
          );
        }
        
        if (ruta['destino'] != null) {
          end = LatLng(
            double.parse(ruta['destino']['lat'].toString()),
            double.parse(ruta['destino']['lng'].toString()),
          );
        }
      }

      // Si tenemos ambas coordenadas, pedimos la ruta a OSRM
      if (start != null && end != null) {
        puntosRuta = await _obtenerRutaDesdeOSRM(start, end);
      }

      if (mounted) {
        setState(() {
          // Si por alguna razón no viniera el start, usamos la ubicación del conductor
          _startCoord = start ?? widget.ubicacionConductor;
          _endCoord = end;
          _routePoints = puntosRuta;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error procesando ruta en HomeMapPreview: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _startCoord = widget.ubicacionConductor;
        });
      }
    }
  }

  Future<List<LatLng>> _obtenerRutaDesdeOSRM(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

          return coordinates.map((coord) {
            return LatLng(
              double.parse(coord[1].toString()),
              double.parse(coord[0].toString()),
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("❌ Error obteniendo ruta desde OSRM: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1559B2);
    const Color buttonLightBlue = Color(0xFF64A1F4);

    final centerMap = _startCoord ?? const LatLng(20.676667, -103.3475);

    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            // --- LADO IZQUIERDO: BOTÓN "ABRIR RUTA" ---
            if (widget.viajeProximo != null && widget.onOpenRoute != null)
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: widget.onOpenRoute,
                  child: Container(
                    color: buttonLightBlue,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 15, width: 15, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Text(
                              'Abrir ruta',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),

            // --- LADO DERECHO: MAPA EN MINIATURA ---
            Expanded(
              flex: 6,
              child: IgnorePointer(
                child: FlutterMap(
                  // Forzamos el redibujado cuando cambien los puntos
                  key: ValueKey('map_preview_${_routePoints.length}_${_startCoord?.latitude}'),
                  options: MapOptions(
                    initialCenter: centerMap,
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tuempresa.movecare',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: primaryBlue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_startCoord != null)
                          Marker(
                            point: _startCoord!,
                            width: 25,
                            height: 25,
                            child: const Icon(Icons.location_on, color: Colors.blue, size: 25),
                          ),
                        if (_endCoord != null)
                          Marker(
                            point: _endCoord!,
                            width: 25,
                            height: 25,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 25),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}