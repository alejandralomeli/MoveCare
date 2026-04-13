import 'dart:convert';
import '../http_client.dart'; // Ajusta la ruta a tu HttpClient

class IncidenciasService {
  static Future<bool> enviarIncidencia({
    required String idReportante,
    required String idReportado, // El ID del pasajero
    required String idViaje,     // 🔥 NUEVO: El ID del viaje
    required String tipoReporte,
    required String descripcion,
  }) async {
    final Map<String, dynamic> body = {
      "id_reportante": idReportante,
      "id_reportado": idReportado,
      "id_viaje": idViaje,       // 🔥 NUEVO: Lo agregamos al JSON
      "tipo_reporte": tipoReporte,
      "descripcion": descripcion,
    };

    final response = await HttpClient.post("/api/reportes/incidencia", body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al enviar el reporte");
  }

  static Future<List<dynamic>> obtenerReportesPendientes() async {
    // Asegúrate de que HttpClient tenga el método .get()
    final response = await HttpClient.get("/api/reportes/pendientes");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al cargar los reportes pendientes");
  }

  // 🔥 NUEVO: CAMBIAR ESTADO DEL REPORTE (Aceptar/Rechazar)
  static Future<bool> cambiarEstadoReporte({
    required String idReporte,
    required String estado,        // "Aceptado" o "Rechazado"
    required int idAdministrador,  // Enviamos el ID del admin que gestiona
  }) async {
    final Map<String, dynamic> body = {
      "estado": estado,
      "id_administrador": idAdministrador,
    };

    // Asegúrate de que HttpClient tenga el método .patch() 
    // Si usas HTTP puro en tu client: http.patch(url, body: jsonEncode(body), ...)
    final response = await HttpClient.put("/api/reportes/$idReporte/estado", body);

    if (response.statusCode == 200) {
      return true;
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final bodyResponse = jsonDecode(response.body);
    throw Exception(bodyResponse["detail"] ?? "Error al actualizar el estado del reporte");
  }
}
