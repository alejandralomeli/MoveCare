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
        "rol": "pasajero",
      },
    );

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "message": jsonDecode(response.body)["mensaje"],
        "id_usuario": jsonDecode(response.body)["id_usuario"],
      };
    } else {
      return {
        "ok": false,
        "error": jsonDecode(response.body)["detail"],
      };
    }
  }

  // ================= REGISTRO CONDUCTOR =================
  static Future<Map<String, dynamic>> registerDriver({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    final response = await HttpClient.post(
      "/auth/auth/registro/conductor",
      {
        "nombre_completo": nombreCompleto,
        "correo": correo,
        "telefono": telefono,
        "password": password,
        "rol": "conductor",
      },
    );

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "message": jsonDecode(response.body)["mensaje"],
        "id_usuario": jsonDecode(response.body)["id_usuario"],
      };
    } else {
      return {
        "ok": false,
        "error": jsonDecode(response.body)["detail"],
      };
    }
  }
}
