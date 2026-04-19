import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Singleton de Speech-to-Text y TTS compartido por toda la app.
/// Garantiza que solo exista UNA instancia del SpeechRecognition del navegador.
class VozSingleton {
  VozSingleton._();

  /// Mutable para poder reemplazarse en [reinicializar].
  static SpeechToText speech = SpeechToText();
  static final FlutterTts tts = FlutterTts();

  static bool _inicializado = false;

  static Future<bool> inicializar() async {
    if (_inicializado) return true;
    // finalTimeout: 500 ms → resultado final llega ~500 ms después de que
    // _stop() es llamado internamente (mucho más rápido que el default 2 s).
    final ok = await speech.initialize(
      finalTimeout: const Duration(milliseconds: 500),
    );
    if (ok) {
      await tts.setLanguage('es-MX');
      await tts.setSpeechRate(0.45);
      await tts.setVolume(1.0);
      _inicializado = true;
    }
    return ok;
  }

  /// Fuerza reinicialización REAL del reconocimiento de voz.
  /// Crea una nueva instancia de SpeechToText para evitar que
  /// _initWorked=true bloquee la creación de un nuevo _webSpeech.
  static Future<bool> reinicializar() async {
    _inicializado = false;
    try {
      if (speech.isListening) await speech.stop();
    } catch (_) {}
    // Nueva instancia → _initWorked = false → initialize() crea nuevo _webSpeech
    speech = SpeechToText();
    return inicializar();
  }
}
