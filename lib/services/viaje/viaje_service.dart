import 'dart:convert';
import '../http_client.dart';
import 'package:latlong2/latlong.dart';

class ViajeService {
  static Future<String> crearViaje({
    Map<String, dynamic>? ruta,
    String? puntoInicio,
    String? destino,
    List<Map<String, dynamic>>? destinos,
    bool checkVariosDestinos = false,
    required String fechaHoraInicio,
    String? metodoPago,
    String? idMetodo,
    String? especificaciones,
    bool checkAcompanante = false,
    String? idAcompanante,
    double? costo,
    int? duracionEstimada,
  }) async {
    final Map<String, dynamic> body = {
      // Extraemos el texto del origen de la ruta si no nos pasan 'puntoInicio' explícitamente
      "punto_inicio":
          puntoInicio ?? (ruta != null ? ruta["origen"]["direccion"] : ""),
      "ruta": ruta, // <--- AQUÍ MANDAMOS EL JSONB COMPLETO AL BACKEND
      "fecha_hora_inicio": fechaHoraInicio,
      "metodo_pago": metodoPago,
      "id_metodo": idMetodo,
      "costo": costo,
      // Usamos la duración de la ruta si no nos pasan una explícita
      "duracion_estimada":
          duracionEstimada ?? (ruta != null ? ruta["duracion_min"] : null),
      "especificaciones": especificaciones,
      "check_acompanante": checkAcompanante,
      "id_acompanante": idAcompanante,
      "check_destinos": checkVariosDestinos,
    };

    if (checkVariosDestinos) {
      body["destino"] = null;
      body["destinos"] = destinos ?? [];
    } else {
      body["destino"] =
          destino ?? (ruta != null ? ruta["destino"]["direccion"] : null);

      // ---> ESTA ES LA LÍNEA QUE CAMBIAMOS <---
      body["destinos"] =
          []; // Le mandamos una lista vacía en lugar de null para complacer a FastAPI
    }

    final response = await HttpClient.post("/viajes/crear", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final bodyResponse = jsonDecode(response.body);
      return bodyResponse["viaje_id"];
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    print("Error Backend: $bodyResponse");
    throw Exception(bodyResponse["detail"] ?? "Error al crear viaje");
  }

  static Future<List<dynamic>> obtenerHistorial() async {
    final response = await HttpClient.get("/viajes/historial");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    throw Exception("Error al obtener historial");
  }

  static Future<List<dynamic>> obtenerHistorialConductor() async {
    // Apuntamos al nuevo endpoint del back
    final response = await HttpClient.get("/viajes/historial-conductor");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    throw Exception("Error al obtener historial del conductor");
  }

  static Future<void> cancelarViaje(String idViaje) async {
    // Llamamos al endpoint que acabamos de crear en el backend
    final response = await HttpClient.put("/viajes/$idViaje/cancelar", {});

    if (response.statusCode == 200) {
      return; // Todo salió bien
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al cancelar viaje");
  }

  static Future<List<dynamic>> obtenerViajesPorEstadoConductor(
    String idUsuario,
    String estado,
  ) async {
    // AHORA APUNTA A LA NUEVA RUTA QUE ESPERA EL id_usuario
    final response = await HttpClient.get(
      "/viajes/conductor/usuario/$idUsuario/viajes/$estado",
    );

    if (response.statusCode == 200) {
      final bodyResponse = jsonDecode(response.body);
      if (bodyResponse is Map && bodyResponse.containsKey('data')) {
        return bodyResponse['data'];
      }
      return bodyResponse;
    }

    if (response.statusCode == 404) {
      throw Exception('No eres un conductor registrado.');
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    throw Exception("Error al obtener viajes con estado $estado");
  }

  static Future<bool> aceptarViaje(String idViaje) async {
    final response = await HttpClient.put("/viajes/$idViaje/aceptar", {});
    if (response.statusCode == 200) return true;
    throw Exception("Error al aceptar el viaje");
  }

  static Future<bool> rechazarViaje(String idViaje) async {
    final response = await HttpClient.put("/viajes/$idViaje/rechazar", {});
    if (response.statusCode == 200) return true;
    throw Exception("Error al rechazar el viaje");
  }

  static Future<bool> cancelarViajeChofer(String idViaje) async {
    final response = await HttpClient.put("/viajes/$idViaje/cancelar", {});
    if (response.statusCode == 200) return true;
    throw Exception("Error al cancelar el viaje");
  }

  static Future<Map<String, dynamic>> obtenerViajeActual(String idViaje) async {
    final response = await HttpClient.get("/viajes/viaje_actual/$idViaje");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception("Error al obtener los detalles del viaje actual");
  }

  static List<LatLng> decodificarPolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    try {
      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        // OSRM usa precisión de 5 decimales (1E5)
        points.add(LatLng(lat / 1E5, lng / 1E5));
      }
    } catch (e) {
      print(
        "⚠️ Error decodificando polyline: $e. Se dibujará hasta donde se pudo.",
      );
    }

    return points;
  }

  static Future<Map<String, dynamic>> obtenerDetalleViaje(String idViaje) async {
    // Apuntamos a la nueva ruta RESTful que creamos
    final response = await HttpClient.get("/viajes/$idViaje/detalle");

    if (response.statusCode == 200) {
      final bodyResponse = jsonDecode(response.body);
      
      // Extraemos el objeto "data" ya que el back responde con {"ok": true, "data": {...}}
      if (bodyResponse["ok"] == true && bodyResponse.containsKey("data")) {
        return bodyResponse["data"] as Map<String, dynamic>;
      }
      return bodyResponse as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    throw Exception("Error al obtener los detalles del viaje");
  }
}
