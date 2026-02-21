import 'dart:convert';
import '../http_client.dart';

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
      "punto_inicio": puntoInicio ?? (ruta != null ? ruta["origen"]["direccion"] : ""),
      "ruta": ruta, // <--- AQUÍ MANDAMOS EL JSONB COMPLETO AL BACKEND
      "fecha_hora_inicio": fechaHoraInicio,
      "metodo_pago": metodoPago,
      "id_metodo": idMetodo,
      "costo": costo,
      // Usamos la duración de la ruta si no nos pasan una explícita
      "duracion_estimada": duracionEstimada ?? (ruta != null ? ruta["duracion_min"] : null),
      "especificaciones": especificaciones,
      "check_acompanante": checkAcompanante,
      "id_acompanante": idAcompanante,
      "check_destinos": checkVariosDestinos,
    };

    if (checkVariosDestinos) {
      body["destino"] = null;
      body["destinos"] = destinos ?? []; 
    } else {
      body["destino"] = destino ?? (ruta != null ? ruta["destino"]["direccion"] : null);
      
      // ---> ESTA ES LA LÍNEA QUE CAMBIAMOS <---
      body["destinos"] = []; // Le mandamos una lista vacía en lugar de null para complacer a FastAPI
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
}
