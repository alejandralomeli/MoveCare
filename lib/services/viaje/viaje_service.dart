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
    required String metodoPago, // <--- Agregamos método de pago
    String? idMetodo, // <--- Mantenemos el ID del método
    String? especificaciones,
    bool checkAcompanante = false,
    String? idAcompanante,
    double? costo,
    int? duracionEstimada,
  }) async {
    final Map<String, dynamic> body = {
      "punto_inicio":
          puntoInicio ?? (ruta != null ? ruta["origen"]["direccion"] : ""),
      "ruta": ruta,
      "fecha_hora_inicio": fechaHoraInicio,
      "metodo_pago": metodoPago, // <--- Lo inyectamos en el JSON
      "id_metodo": idMetodo, // <--- Se va junto con su ID
      "costo": costo,
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
      body["destinos"] = [];
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
    final response = await HttpClient.put("/viajes/$idViaje/cancelar", {});

    if (response.statusCode == 200) {
      return;
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

        points.add(LatLng(lat / 1E5, lng / 1E5));
      }
    } catch (e) {
      print(
        "⚠️ Error decodificando polyline: $e. Se dibujará hasta donde se pudo.",
      );
    }

    return points;
  }

  static Future<Map<String, dynamic>> obtenerDetalleViaje(
    String idViaje,
  ) async {
    final response = await HttpClient.get("/viajes/$idViaje/detalle");

    if (response.statusCode == 200) {
      final bodyResponse = jsonDecode(response.body);

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

  // ── NUEVO: Método para validar el PIN ingresado por el conductor ──
  static Future<bool> validarPinViaje(String idViaje, String pin) async {
    final Map<String, dynamic> body = {"pin": pin};

    final response = await HttpClient.post(
      "/viajes/$idViaje/validar-pin",
      body,
    );

    if (response.statusCode == 200) {
      return true; // PIN correcto
    }

    if (response.statusCode == 400) {
      return false; // PIN incorrecto
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al validar el PIN");
  }

  // ── NUEVO: Método para finalizar el viaje ──
  static Future<bool> finalizarViaje(String idViaje) async {
    // Usamos patch ya que así lo definimos en el backend. 
    // Nota: Asegúrate de que tu clase HttpClient tenga implementado el método .patch().
    // Si no lo tiene, puedes agregarlo a HttpClient o cambiar esta petición (y la ruta de FastAPI) a .put()
    final response = await HttpClient.put(
      "/viajes/$idViaje/finalizar", 
      {} // Mandamos un body vacío si tu HttpClient lo requiere
    );

    if (response.statusCode == 200) {
      return true; // Viaje finalizado correctamente
    }

    if (response.statusCode == 400) {
      return false; // Error de lógica (ej. el viaje ya estaba finalizado)
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    // Manejo de otros errores que devuelva el backend
    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al finalizar el viaje");
  }

}
