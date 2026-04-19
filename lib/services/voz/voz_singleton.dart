import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Singleton de Speech-to-Text y TTS compartido por toda la app.
/// Garantiza que solo exista UNA instancia del SpeechRecognition del navegador.
class VozSingleton {
  VozSingleton._();

  static final SpeechToText speech = SpeechToText();
  static final FlutterTts tts = FlutterTts();

  static bool _inicializado = false;

  static Future<bool> inicializar() async {
    if (_inicializado) return true;
    final ok = await speech.initialize();
    if (ok) {
      await tts.setLanguage('es-MX');
      await tts.setSpeechRate(0.45);
      await tts.setVolume(1.0);
      _inicializado = true;
    }
    return ok;
  }
}
