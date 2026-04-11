import 'dart:convert';
import '../http_client.dart'; // Ajusta la ruta según tu proyecto
import '../../models/auditoria_model.dart';

class AuditoriaService {
  /// Listado del historial de auditorías
  static Future<List<Auditoria>> obtenerHistorial() async {
    // Usamos tu HttpClient y apuntamos al endpoint de FastAPI
    final response = await HttpClient.get("/auditoria");

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => Auditoria.fromJson(item)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('TOKEN_INVALIDO');
    }

    final body = jsonDecode(response.body);
    throw Exception(body["detail"] ?? "Error al obtener el historial de auditoría");
  }
}