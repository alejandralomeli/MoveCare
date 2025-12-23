import 'dart:convert';
import '../http_client.dart';

class AuthService {

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await HttpClient.post(
      "/auth/auth/login",
      {
        "correo": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "data": jsonDecode(response.body),
      };
    } else {
      return {
        "ok": false,
        "error": jsonDecode(response.body)["detail"],
      };
    }
  }

  // ================= REGISTRO PASAJERO =================
  static Future<Map<String, dynamic>> registerPassenger({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String password,
  }) async {

    final response = await HttpClient.post(
      "/auth/auth/registro/pasajero",
      {
        "nombre_completo": nombreCompleto,
        "correo": correo,
        "telefono": telefono,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "message": jsonDecode(response.body)["mensaje"],
      };
    } else {
      return {
        "ok": false,
        "error": jsonDecode(response.body)["detail"],
      };
    }
  }
}
