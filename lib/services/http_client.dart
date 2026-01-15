import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class HttpClient {

  // ================= POST =================
  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  // ================= GET =================
  static Future<http.Response> get(String path) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
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
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  // ================= DELETE =================
  static Future<http.Response> delete(String path) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    return await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
  }
}

