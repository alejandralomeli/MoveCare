import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class HttpClient {
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
}
