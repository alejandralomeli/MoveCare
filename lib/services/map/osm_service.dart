import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsmService {
  // 1. Convertir texto a Coordenadas (Nominatim)
  static Future<LatLng?> obtenerCoordenadas(String direccion) async {
    // Agregamos "Jalisco, Mexico" para que la búsqueda sea más precisa
    final query = Uri.encodeComponent("$direccion, Jalisco, Mexico");
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');

    try {
      final response = await http.get(url, headers: {
        // 🔥 AQUÍ ESTÁ EL CAMBIO CLAVE CON TU CORREO 🔥
        'User-Agent': 'MoveCareApp/1.0 (tiggertok@gmail.com)', 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      } else {
        print('Error de Nominatim: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en Geocoding: $e");
    }
    return null;
  }

  // 2. Obtener Ruta y Distancia (OSRM - 2 puntos)
  static Future<Map<String, dynamic>?> obtenerRuta(LatLng origen, LatLng destino) async {
    final start = '${origen.longitude},${origen.latitude}';
    final end = '${destino.longitude},${destino.latitude}';
    
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$start;$end?geometries=geojson&overview=full');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        
        final distanceKm = route['distance'] / 1000.0;
        final durationMin = (route['duration'] / 60.0).round(); 
        
        final coordinates = route['geometry']['coordinates'] as List;
        List<LatLng> routePoints = coordinates.map((coord) {
          return LatLng(coord[1], coord[0]); 
        }).toList();

        return {
          'distancia': distanceKm,
          'duracion': durationMin, 
          'puntos': routePoints,
        };
      }
    } catch (e) {
      print("Error en Routing: $e");
    }
    return null;
  }

  // 3. Obtener Ruta Multidestino (OSRM - Múltiples puntos)
  static Future<Map<String, dynamic>?> obtenerRutaMultiple(List<LatLng> coordenadas) async {
    if (coordenadas.length < 2) return null; // Necesitamos al menos un origen y un destino

    // Unimos todas las coordenadas en el formato que pide OSRM: lon,lat;lon,lat;lon,lat
    final stringCoordenadas = coordenadas
        .map((c) => '${c.longitude},${c.latitude}')
        .join(';');

    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$stringCoordenadas?geometries=geojson&overview=full');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];

        final distanceKm = route['distance'] / 1000.0;
        final durationMin = (route['duration'] / 60.0).round();
        
        final coordinatesList = route['geometry']['coordinates'] as List;
        List<LatLng> routePoints = coordinatesList.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();

        return {
          'distancia': distanceKm,
          'duracion': durationMin,
          'puntos': routePoints, 
        };
      }
    } catch (e) {
      print("Error en Routing Múltiple: $e");
    }
    return null;
  }
}