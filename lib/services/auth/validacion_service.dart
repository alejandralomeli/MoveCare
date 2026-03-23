import 'dart:convert';
import '../http_client.dart'; 

class ValidacionService {
  
  /// Envía todos los documentos en Base64 al backend (Pasajero/Conductor)
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

  // =========================================================================
  // NUEVOS MÉTODOS PARA EL ADMINISTRADOR
  // =========================================================================

  /// Obtiene las validaciones pendientes separadas por rol
  static Future<Map<String, dynamic>> obtenerPendientes() async {
    final response = await HttpClient.get("/validaciones/pendientes");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    throw Exception("Error al cargar validaciones pendientes");
  }

  /// Acepta una validación pendiente
  static Future<bool> aceptarValidacion(String idValidacion) async {
    // ¡Aquí estaba el error! Le pasamos {} como segundo argumento
    final response = await HttpClient.put("/validaciones/$idValidacion/aceptar", {});

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al aceptar la validación");
  }

  /// Rechaza una validación pendiente con un motivo
  static Future<bool> rechazarValidacion(String idValidacion, String motivo) async {
    final Map<String, dynamic> body = {
      "motivo_rechazo": motivo,
    };

    final response = await HttpClient.put("/validaciones/$idValidacion/rechazar", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al rechazar la validación");
  }
}