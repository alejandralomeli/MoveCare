import 'dart:convert';
import '../http_client.dart';

class ReportesService {
  static Future<Map<String, dynamic>> obtenerMetricasConductor() async {
    final response = await HttpClient.get("/ia/reportes/conductor");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final body = jsonDecode(response.body);
    throw Exception(body["detail"] ?? "Error al obtener métricas");
  }
}
