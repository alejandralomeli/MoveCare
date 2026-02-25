import 'dart:convert';
import '../http_client.dart'; // Asegúrate de que esta ruta apunte a tu archivo real

class ValidacionService {
  
  /// Envía las imágenes de la INE en Base64 al backend para crear la validación.
  static Future<bool> enviarValidacionINE({
    required String ineFrenteBase64,
    required String ineReversoBase64,
  }) async {
    final Map<String, dynamic> body = {
      "ine_frente": ineFrenteBase64,
      "ine_reverso": ineReversoBase64,
    };

    // Usamos tu HttpClient que ya maneja los tokens y la URL base
    final response = await HttpClient.post("/auth/auth/validacion", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al enviar los documentos de validación");
  }
}