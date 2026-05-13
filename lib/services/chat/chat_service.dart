import 'dart:convert';
import '../../models/mensaje_model.dart';
import '../http_client.dart'; // Ajusta la ruta según tu proyecto

class ChatService {
  // Obtener historial completo
  static Future<List<MensajeModel>> obtenerHistorial(String idViaje) async {
    final response = await HttpClient.get('/chat/$idViaje');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MensajeModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar el historial del chat');
    }
  }

  // Enviar un nuevo mensaje
  static Future<MensajeModel> enviarMensaje(String idViaje, String contenido) async {
    final body = {
      "id_viaje": idViaje,
      "contenido": contenido,
    };
    
    final response = await HttpClient.post('/chat/enviar', body);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MensajeModel.fromJson(data);
    } else {
      throw Exception('Error al enviar el mensaje');
    }
  }
}