import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteMapWidget extends StatelessWidget {
  final LatLng? startCoord;
  final LatLng? endCoord;
  final List<LatLng> routePoints;
  final List<LatLng>? paradas; // Lista opcional para los múltiples destinos
  final double? distanciaTotalKm;
  final bool isLoading;

  const RouteMapWidget({
    super.key,
    this.startCoord,
    this.endCoord,
    required this.routePoints,
    this.paradas, 
    this.distanciaTotalKm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ESTADO DE CARGA
    if (isLoading) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1559B2)),
              SizedBox(height: 10),
              Text("Calculando ruta..."),
            ],
          ),
        ),
      );
    }

    // Centro por defecto (Guadalajara, ZMG) si aún no hay coordenadas
    final defaultCenter = const LatLng(20.676667, -103.3475);
    final centerMap = startCoord ?? defaultCenter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. CONTENEDOR DEL MAPA
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF64A1F4), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: centerMap,
                initialZoom: routePoints.isNotEmpty ? 13.0 : 11.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tuempresa.movecare',
                ),
                
                // Línea de la ruta
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: const Color(0xFF1559B2),
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                
                // --- CAPA DE MARCADORES INTELIGENTE ---
                MarkerLayer(
                  markers: [
                    // A) PIN DE ORIGEN (Verde) - Siempre se dibuja si existe
                    if (startCoord != null)
                      Marker(
                        point: startCoord!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                      ),
                      
                    // B) MÚLTIPLES DESTINOS (Numerados) - Solo si 'paradas' tiene datos
                    if (paradas != null && paradas!.isNotEmpty)
                      ...paradas!.asMap().entries.map((entry) {
                        int index = entry.key;
                        LatLng punto = entry.value;
                        // El último de la lista es el destino final (Rojo), los demás son paradas (Naranja)
                        bool isLast = index == paradas!.length - 1;

                        return Marker(
                          point: punto,
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isLast ? Colors.red : Colors.orange,
                                size: 40,
                              ),
                              Positioned(
                                top: 6,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      
                    // C) UN SOLO DESTINO (Rojo normal) - Solo si NO hay paradas pero SÍ hay endCoord
                    else if (endCoord != null)
                      Marker(
                        point: endCoord!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // 3. TEXTO DE DISTANCIA TOTAL
        if (distanciaTotalKm != null)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 5),
            child: Row(
              children: [
                const Icon(Icons.directions_car, color: Color(0xFF1559B2), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Distancia del viaje: ${distanciaTotalKm!.toStringAsFixed(2)} km',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF1559B2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}