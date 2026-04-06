import 'dart:convert';
import '../http_client.dart';

/// Servicio de control por voz.
/// Envía el texto transcrito al backend y recibe intención + entidades.
class VozService {
  static const String _endpoint = '/ia/voz/interpretar';

  /// Interpreta un comando de voz en texto.
  /// Devuelve un mapa con: intencion, entidades, accion, respuesta_voz.
  static Future<Map<String, dynamic>> interpretarComando(String texto) async {
    final response = await HttpClient.post(_endpoint, {'texto': texto});

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Error al interpretar comando: ${response.statusCode}');
  }
}
