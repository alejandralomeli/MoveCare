import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/auth"; // BACKEND

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final body = {
      "correo": email,
      "password": password,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
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
