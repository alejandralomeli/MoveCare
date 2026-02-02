import 'dart:convert';
import '../http_client.dart';

class ViajeService {
  static Future<String> crearViaje({
    required String puntoInicio,
    required String destino,
    required String fechaHoraInicio, // ISO string
    String? metodoPago,
    String? especificaciones,
    bool checkAcompanante = false,
    String? idAcompanante,
    double? costo,
    int? duracionEstimada,
  }) async {
    final response = await HttpClient.post(
      "/viajes/crear",
      {
        "punto_inicio": puntoInicio,
        "destino": destino,
        "fecha_hora_inicio": fechaHoraInicio,
        "metodo_pago": metodoPago,
        "costo": costo,
        "duracion_estimada": duracionEstimada,
        "especificaciones": especificaciones,
        "check_acompanante": checkAcompanante,
        "id_acompanante": idAcompanante,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body["viaje_id"];
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final body = jsonDecode(response.body);
    throw Exception(body["detail"] ?? "Error al crear viaje");
  }
}
