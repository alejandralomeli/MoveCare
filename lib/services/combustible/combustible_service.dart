import 'dart:convert';
import '../http_client.dart';

class CombustibleService {
  static const _base = '/combustible';

  /// Registra una carga de gasolina.
  /// [litrosEnTanque] — litros en el tanque DESPUÉS de cargar.
  /// [kmAlCargar]     — km totales del conductor en este momento.
  static Future<Map<String, dynamic>> registrarCarga({
    required double litrosEnTanque,
    required double capacidadTanque,
    required double rendimientoKmL,
    required double costo,
    required double kmAlCargar,
    String? notas,
  }) async {
    final response = await HttpClient.post('$_base/registrar', {
      'litros_en_tanque': litrosEnTanque,
      'capacidad_tanque': capacidadTanque,
      'rendimiento_kmL': rendimientoKmL,
      'costo': costo,
      'km_al_cargar': kmAlCargar,
      if (notas != null && notas.isNotEmpty) 'notas': notas,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final body = jsonDecode(response.body);
    throw Exception(body['detail'] ?? 'Error al registrar carga');
  }

  /// Historial de cargas del conductor (más reciente primero).
  static Future<List<Map<String, dynamic>>> obtenerHistorial({int limite = 10}) async {
    final response = await HttpClient.get('$_base/historial?limite=$limite');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['cargas'] ?? []);
    }
    throw Exception('Error al obtener historial de combustible');
  }

  /// Nivel estimado actual basado en la última carga y km recorridos.
  static Future<Map<String, dynamic>> obtenerNivel(double kmActuales) async {
    final response = await HttpClient.get(
      '$_base/nivel?km_actuales=$kmActuales',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Error al obtener nivel de combustible');
  }
}
