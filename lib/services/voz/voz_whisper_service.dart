import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import '../../core/config/api_config.dart';
import '../../core/storage/secure_storage.dart';

// Importado solo en móvil para obtener el directorio temporal
import 'voz_whisper_service_path.dart'
    if (dart.library.html) 'voz_whisper_service_path_web.dart'
    as platform;

/// Servicio de grabación y transcripción con Whisper.
///
/// Flujo:
///   1. [iniciar]         — pide permiso y empieza a grabar
///   2. [detenerYEnviar]  — detiene y sube el audio al backend
///   3. Backend transcribe con Whisper y devuelve intención + entidades
class VozWhisperService {
  static final AudioRecorder _recorder = AudioRecorder();

  static Future<bool> get estaGrabando => _recorder.isRecording();

  /// Solicita permiso y comienza a grabar.
  static Future<bool> iniciar() async {
    if (!await _recorder.hasPermission()) return false;

    const config = RecordConfig(sampleRate: 16000, numChannels: 1);
    await _recorder.start(config, path: platform.getTempAudioPath());
    return true;
  }

  /// Detiene la grabación, sube el audio al backend y devuelve el resultado.
  static Future<Map<String, dynamic>> detenerYEnviar() async {
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) throw Exception('No se grabó audio');

    final token = await SecureStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/ia/voz/interpretar-audio');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    await platform.adjuntarAudio(request, path);

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception('Error ${streamed.statusCode}: $body');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  static Future<void> cancelar() async => _recorder.cancel();
}
