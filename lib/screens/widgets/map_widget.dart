import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 
import '../../services/location_service.dart'; // Tu servicio actual

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        // Usamos LatLng de la librería latlong2
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Error obteniendo ubicación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!, // Reemplaza a 'target'
        initialZoom: 15.0,
      ),
      children: [
        // 1. Capa del Mapa (Las imágenes de las calles)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tuempresa.movecare', // Buena práctica para OSM
        ),
        // 2. Capa de Marcadores (Para tu ubicación actual)
        MarkerLayer(
          markers: [
            Marker(
              point: _currentPosition!,
              width: 50.0,
              height: 50.0,
              // Alineamos para que la punta del pin toque la ubicación real
              alignment: Alignment.topCenter, 
              // 🔥 AQUÍ ESTÁ EL CAMBIO: El clásico pin azul 🔥
              child: const Icon(
                Icons.location_on,
                color: Colors.blue, // Puedes cambiarlo a tu Color(0xFF1559B2) si quieres tu azul exacto
                size: 45.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}