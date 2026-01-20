import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/storage/secure_storage.dart';

class HttpClient {

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ================= POST =================
  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  // ================= GET =================
  static Future<http.Response> get(String path) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.get(
      url,
      headers: await _headers(),
    );
  }

  // ================= PUT =================
  static Future<http.Response> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  // ================= DELETE =================
  static Future<http.Response> delete(String path) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.delete(
      url,
      headers: await _headers(),
    );
  }
}


