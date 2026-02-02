import 'dart:convert';
import '../http_client.dart';

class AcompananteService {
  /// Crear acompañante para el pasajero autenticado
  static Future<void> crearAcompanante({
    required String nombreCompleto,
    String? telefono,
    String? parentesco,
    String? foto,
  }) async {
    final response = await HttpClient.post("/acompanantes", {
      "nombre_completo": nombreCompleto,
      "telefono": telefono,
      "parentesco": parentesco,
      "foto": foto,
    });

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final body = jsonDecode(response.body);
    throw Exception(body["detail"] ?? "Error al crear acompañante");
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
