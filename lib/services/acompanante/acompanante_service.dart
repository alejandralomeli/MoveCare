import 'dart:convert';
import '../http_client.dart';

class AcompananteService {
  /// Crear acompañante para el pasajero autenticado
  static Future<bool> crearAcompanante({
    required String nombreCompleto,
    String? parentesco,
    String? ineFrenteBase64,
    String? ineReversoBase64,
  }) async {
    final Map<String, dynamic> body = {
      "nombre_completo": nombreCompleto,
      "parentesco": parentesco,
      "ine_frente": ineFrenteBase64,
      "ine_reverso": ineReversoBase64,
    };

    // Quitamos nulos para limpiar el JSON
    body.removeWhere((key, value) => value == null);

    final response = await HttpClient.post("/acompanantes", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al registrar acompañante");
  }

  /// Listado para el select (id + nombre)
  static Future<List<dynamic>> obtenerAcompanantes() async {
    final response = await HttpClient.get("/acompanantes");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final body = jsonDecode(response.body);
    throw Exception(body["detail"] ?? "Error al obtener acompañantes");
  }
}
