import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMapPreview extends StatelessWidget {
  final LatLng? startCoord;
  final LatLng? endCoord;
  final List<LatLng> routePoints;
  final VoidCallback onOpenRoute;

  const HomeMapPreview({
    super.key,
    this.startCoord,
    this.endCoord,
    required this.routePoints,
    required this.onOpenRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Colores del tema
    const Color primaryBlue = Color(0xFF1559B2);
    const Color buttonLightBlue = Color(0xFF64A1F4);

    // Centro por defecto si no hay coordenadas (Guadalajara)
    final centerMap = startCoord ?? const LatLng(20.676667, -103.3475);

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
            // --- LADO IZQUIERDO: BOTÓN "ABRIR RUTA" (40%) ---
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: onOpenRoute,
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
                      child: Text(
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

            // --- LADO DERECHO: MAPA EN MINIATURA (60%) ---
            Expanded(
              flex: 6,
              child: IgnorePointer( // Para que no interfiera con el scroll de la Home
                child: FlutterMap(
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
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: primaryBlue,
                            strokeWidth: 3.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (startCoord != null)
                          Marker(
                            point: startCoord!,
                            width: 25,
                            height: 25,
                            child: const Icon(Icons.location_on, color: Colors.blue, size: 25),
                          ),
                        if (endCoord != null)
                          Marker(
                            point: endCoord!,
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