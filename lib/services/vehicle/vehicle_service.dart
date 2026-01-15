import 'dart:convert';
import '../http_client.dart';

class VehicleService {

  // ================= OBTENER ID CONDUCTOR =================
  static Future<Map<String, dynamic>> getConductorId({
    required String idUsuario,
  }) async {

    final response = await HttpClient.get(
      "/users/usuarios/$idUsuario/conductor",
    );

    if (response.statusCode == 200) {
      return {
        "ok": true,
        "id_conductor": jsonDecode(response.body)["id_conductor"],
      };
    } else {
      return {
        "ok": false,
        "error": jsonDecode(response.body)["detail"],
      };
    }
  }

  // ================= REGISTRAR VEHÍCULO =================
  static Future<Map<String, dynamic>> registerVehicle({
    required String idConductor,
    required String marca,
    required String modelo,
    required String color,
    required String placas,
    String? accesorios,
  }) async {

    final response = await HttpClient.post(
      "/register/vehiculos",
      {
        "id_conductor": idConductor,
        "marca": marca,
        "modelo": modelo,
        "color": color,
        "placas": placas,
        "accesorios": accesorios,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "ok": true,
        "data": jsonDecode(response.body),
      };
    } else {
      return {
        "ok": false,
        "error": jsonDecode(response.body)["detail"],
      };
    }
  }
}
