import 'dart:convert';
import '../http_client.dart'; 

class ValidacionService {
  
  /// Envía todos los documentos en Base64 al backend
  static Future<bool> enviarValidacionDocumentos({
    required String ineFrenteBase64,
    required String ineReversoBase64,
    String? licenciaFrenteBase64,
    String? licenciaReversoBase64,
    String? polizaBase64,
  }) async {
    final Map<String, dynamic> body = {
      "ine_frente": ineFrenteBase64,
      "ine_reverso": ineReversoBase64,
    };

    if (licenciaFrenteBase64 != null) body["licencia_frente"] = licenciaFrenteBase64;
    if (licenciaReversoBase64 != null) body["licencia_reverso"] = licenciaReversoBase64;
    if (polizaBase64 != null) body["poliza"] = polizaBase64;

    final response = await HttpClient.post("/auth/auth/validacion", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al enviar los documentos");
  }
}