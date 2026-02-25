import 'dart:convert';
import '../http_client.dart';
import '../../core/storage/secure_storage.dart';

class AuthService {
  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await HttpClient.post("/auth/auth/login", {
      "correo": email,
      "password": password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data["token"];

      // 🔥 AQUÍ se guarda el token (NO en el screen)
      await SecureStorage.saveToken(token);

      return {"ok": true, "data": data};
    } else {
      return {"ok": false, "error": data["detail"]};
    }
  }

  // ================= REGISTRO PASAJERO =================
  static Future<Map<String, dynamic>> registerPassenger({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    final response = await HttpClient.post("/auth/auth/registro/pasajero", {
      "nombre_completo": nombreCompleto,
      "correo": correo,
      "telefono": telefono,
      "password": password,
      "rol": "pasajero",
    });

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "message": jsonDecode(response.body)["mensaje"],
        "id_usuario": jsonDecode(response.body)["id_usuario"],
      };
    } else {
      return {"ok": false, "error": jsonDecode(response.body)["detail"]};
    }
  }

  // ================= REGISTRO CONDUCTOR =================
  static Future<Map<String, dynamic>> registerDriver({
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    final response = await HttpClient.post("/auth/auth/registro/conductor", {
      "nombre_completo": nombreCompleto,
      "correo": correo,
      "telefono": telefono,
      "password": password,
      "rol": "conductor",
    });

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "message": jsonDecode(response.body)["mensaje"],
        "id_usuario": jsonDecode(response.body)["id_usuario"],
      };
    } else {
      return {"ok": false, "error": jsonDecode(response.body)["detail"]};
    }
  }

  // ================= CONFIRMAR CORREO =================
  static Future<Map<String, dynamic>> confirmarCorreo(String uid) async {
    final response = await HttpClient.post("/auth/auth/confirmar-correo", {
      "uid": uid,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"ok": true, "mensaje": data["mensaje"]};
    } else {
      return {"ok": false, "error": data["detail"]};
    }
  }

  // ================= TOKEN =================
  static Future<String?> getToken() async {
    return await SecureStorage.getToken();
  }

  static Future<bool> hasValidToken() async {
    final token = await SecureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    await SecureStorage.deleteAll();
  }
}
