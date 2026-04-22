import 'package:flutter/foundation.dart';
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
      onError: (e) => debugPrint('VOZ ERROR: ${e.errorMsg} permanent=${e.permanent}'),
      onStatus: (s) => debugPrint('VOZ STATUS: $s'),
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
  static bool _reinicializando = false;

  /// Solo recrea el STT — nunca toca TTS (evita assertion de user-gesture en web).
  static Future<bool> reinicializar() async {
    if (_reinicializando) return _inicializado;
    _reinicializando = true;
    try {
      _inicializado = false;
      try {
        await speech.stop(); // siempre detener — web puede seguir activo aunque isListening=false
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 150)); // dar tiempo al browser para limpiar
      speech = SpeechToText();
      final ok = await speech.initialize(
        finalTimeout: const Duration(milliseconds: 500),
        onError: (e) => debugPrint('VOZ ERROR: ${e.errorMsg} permanent=${e.permanent}'),
        onStatus: (s) => debugPrint('VOZ STATUS: $s'),
      );
      if (ok) _inicializado = true;
      return ok;
    } finally {
      _reinicializando = false;
    }
  }
}
