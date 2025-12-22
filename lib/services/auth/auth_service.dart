import 'dart:convert';
import '../http_client.dart';

class AuthService {

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
        "error": jsonDecode(response.body),
      };
    }
  }
}
