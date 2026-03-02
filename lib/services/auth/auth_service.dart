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

  // ================= ACTUALIZAR PERFIL =================
  static Future<Map<String, dynamic>> updateProfile({
    String? nombreCompleto,
    String? telefono,
    String? direccion,
    String? fechaNacimiento,
    String? fotoPerfil,
    String? discapacidad,
  }) async {
    // 1. Armamos el body solo con los campos que no sean nulos
    final Map<String, dynamic> body = {};
    if (nombreCompleto != null) body["nombre_completo"] = nombreCompleto;
    if (telefono != null) body["telefono"] = telefono;
    if (direccion != null) body["direccion"] = direccion;
    if (fechaNacimiento != null) body["fecha_nacimiento"] = fechaNacimiento;
    if (fotoPerfil != null) body["foto_perfil"] = fotoPerfil;
    if (discapacidad != null) body["discapacidad"] = discapacidad;

    // 2. Usamos el método PUT (Asegúrate de que tu clase HttpClient tenga soporte para .put)
    // Nota: Mantuve el prefijo "/auth/auth" para seguir el estándar de tus otras rutas
    final response = await HttpClient.put("/auth/auth/actualizar-perfil", body);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"ok": true, "mensaje": data["mensaje"] ?? "Perfil actualizado"};
    } else {
      return {"ok": false, "error": data["detail"] ?? "Error al actualizar"};
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
