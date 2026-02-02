import 'dart:convert';
import '../http_client.dart';

class HomeService {

  /// role: pasajero | conductor | admin
  static Future<Map<String, dynamic>> getHome({
    required String role,
  }) async {

    final response = await HttpClient.get("/app/home/home/$role");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final body = jsonDecode(response.body);
    throw Exception(body["detail"] ?? "Error al cargar home");
  }
}

