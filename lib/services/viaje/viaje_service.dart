import 'dart:convert';
import '../http_client.dart';

class ViajeService {
  static Future<String> crearViaje({
    required String puntoInicio,
    String? destino,
    List<Map<String, dynamic>>? destinos,
    bool checkVariosDestinos = false,
    required String fechaHoraInicio,
    String? metodoPago,
    String? especificaciones,
    bool checkAcompanante = false,
    String? idAcompanante,
    double? costo,
    int? duracionEstimada,
  }) async {

    final Map<String, dynamic> body = {
      "punto_inicio": puntoInicio,
      "fecha_hora_inicio": fechaHoraInicio,
      "metodo_pago": metodoPago,
      "costo": costo,
      "duracion_estimada": duracionEstimada,
      "especificaciones": especificaciones,
      "check_acompanante": checkAcompanante,
      "id_acompanante": idAcompanante,
      "check_destinos": checkVariosDestinos,
    };

    if (checkVariosDestinos) {
      body["destino"] = null;
      body["destinos"] = destinos;
    } else {
      body["destino"] = destino;
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
    throw Exception(bodyResponse["detail"] ?? "Error al crear viaje");
  }
}

