import 'dart:convert';
import '../http_client.dart';

class PagosService {
  
  /// Registra la tarjeta en el backend.
  /// En un entorno real, el 'token' te lo da Stripe. 
  /// Aquí lo simularemos desde la vista.
  static Future<bool> agregarTarjeta({
    required String token,
    required String ultimosCuatro,
    String? marca,
    String? alias,
  }) async {
    final Map<String, dynamic> body = {
      "token_tarjeta": token,
      "ultimos_cuatro": ultimosCuatro,
      "marca": marca,
      "alias": alias,
    };

    // Limpiamos nulos
    body.removeWhere((key, value) => value == null);

    final response = await HttpClient.post("/pagos/tarjetas", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al registrar tarjeta");
  }

  /// Listar tarjetas guardadas
  static Future<List<dynamic>> obtenerTarjetas() async {
    final response = await HttpClient.get("/pagos/tarjetas");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    if (response.statusCode == 401) throw Exception('TOKEN_INVALIDO');
    
    throw Exception("Error al obtener tarjetas");
  }
}