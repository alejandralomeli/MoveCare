import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import 'voz_service.dart';
import 'voz_singleton.dart';
import 'voz_whisper_service.dart';

/// Mixin de control por voz para pantallas de pasajero.
///
/// Uso en cualquier State:
///   class _MiScreenState extends State`<MiScreen>` with VozMixin {
///     @override void initState() { super.initState(); inicializarVoz(); }
///
///     void _onMic() => escucharComando({
///       'confirmar': (_) => _enviar(),
///       'ir_atras': (_) => Navigator.pop(context),
///     });
///   }
///
/// El mixin expone [vozEscuchando] y [vozProcesando] para reflejar
/// el estado en el MicButton: isActive: vozEscuchando || vozProcesando
mixin VozMixin<T extends StatefulWidget> on State<T> {
  bool vozEscuchando = false;
  bool vozProcesando = false;

  // Fallback para cuando Android nunca dispara finalResult=true
  String _ultimoTexto = '';
  bool _procesado = false;
  Timer? _vozTimer;

  // ── Inicialización ──────────────────────────────────────────────────────

  Future<void> inicializarVoz() async {
    await VozSingleton.inicializar();
  }

  @override
  void reassemble() {
    super.reassemble();
    VozSingleton.reinicializar();
  }

  // ── API pública ─────────────────────────────────────────────────────────

  /// Activa o desactiva el control por voz con Whisper.
  /// true  → primer tap graba, segundo tap sube audio a Whisper y procesa.
  /// false → usa speech_to_text (flujo original, funciona offline).
  static bool usarWhisper = false;

  /// Escucha, interpreta y ejecuta.
  ///
  /// Con Whisper: tap para grabar, tap de nuevo para enviar.
  /// Sin Whisper: flujo speech_to_text original con timer fallback.
  Future<void> escucharComando(
    Map<String, Function(Map<String, dynamic> entidades)> acciones,
  ) async {
    if (usarWhisper) {
      await _escucharConWhisper(acciones);
    } else {
      await _escucharConSpeechToText(acciones);
    }
  }

  // ── Flujo Whisper ────────────────────────────────────────────────────────

  Future<void> _escucharConWhisper(
    Map<String, Function(Map<String, dynamic> entidades)> acciones,
  ) async {
    final tts = VozSingleton.tts;

    // Segundo tap mientras graba → detener y procesar
    if (vozEscuchando) {
      if (mounted) setState(() { vozEscuchando = false; vozProcesando = true; });
      try {
        final respuesta = await VozWhisperService.detenerYEnviar();
        if (!mounted) return;
        setState(() => vozProcesando = false);
        final voz = respuesta['respuesta_voz'] as String? ?? '';
        if (voz.isNotEmpty) await tts.speak(voz);
        if (mounted) {
          final dbgI = respuesta['intencion'] ?? '?';
          final dbgT = respuesta['transcripcion'] ?? '';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('[$dbgI] "$dbgT"'),
            duration: const Duration(seconds: 5),
          ));
        }
        _despacharAccion(respuesta, acciones);
      } catch (e) {
        if (!mounted) return;
        setState(() => vozProcesando = false);
        await tts.speak('Lo siento, no pude procesar el audio');
        debugPrint('VozMixin Whisper: $e');
      }
      return;
    }

    // Primer tap → iniciar grabación
    final ok = await VozWhisperService.iniciar();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Micrófono no disponible')),
        );
      }
      return;
    }
    if (mounted) setState(() => vozEscuchando = true);

    // Auto-stop después de 10s si el usuario no toca de nuevo
    Future.delayed(const Duration(seconds: 10), () async {
      if (mounted && vozEscuchando) {
        await _escucharConWhisper(acciones); // simula segundo tap
      }
    });
  }

  // ── Flujo speech_to_text (original) ──────────────────────────────────────

  Future<void> _escucharConSpeechToText(
    Map<String, Function(Map<String, dynamic> entidades)> acciones,
  ) async {
    final speech = VozSingleton.speech;
    final tts = VozSingleton.tts;

    if (!speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Micrófono no disponible')),
      );
      return;
    }

    final eraEstaEscuchando = vozEscuchando;
    if (speech.isListening) {
      await speech.stop();
      if (mounted) setState(() => vozEscuchando = false);
      if (eraEstaEscuchando) return;
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _ultimoTexto = '';
    _procesado = false;
    _vozTimer?.cancel();

    if (mounted) setState(() => vozEscuchando = true);

    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && vozEscuchando) setState(() => vozEscuchando = false);
    });

    try {
      await speech.listen(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(milliseconds: 1500),
        onResult: (result) async {
          final texto = result.recognizedWords.trim();
          if (texto.isNotEmpty) _ultimoTexto = texto;
          _vozTimer?.cancel();

          if (result.finalResult) {
            if (!_procesado && _ultimoTexto.isNotEmpty) {
              _procesado = true;
              await _procesarComando(_ultimoTexto, acciones, tts);
            }
            return;
          }

          _vozTimer = Timer(const Duration(milliseconds: 2000), () async {
            if (!_procesado && _ultimoTexto.isNotEmpty) {
              _procesado = true;
              await _procesarComando(_ultimoTexto, acciones, tts);
            }
          });
        },
      );
    } catch (e) {
      if (mounted) setState(() => vozEscuchando = false);
      debugPrint('VozMixin: error al escuchar — $e');
      await VozSingleton.reinicializar();
    }
  }

  Future<void> _procesarComando(
    String texto,
    Map<String, Function(Map<String, dynamic> entidades)> acciones,
    dynamic tts,
  ) async {
    if (mounted) setState(() { vozEscuchando = false; vozProcesando = true; });

    try {
      final respuesta = await VozService.interpretarComando(texto);
      if (!mounted) return;
      if (mounted) setState(() => vozProcesando = false);

      final voz = respuesta['respuesta_voz'] as String? ?? '';
      if (voz.isNotEmpty) await tts.speak(voz);

      // DEBUG temporal
      if (!mounted) return;
      final dbgI = respuesta['intencion'] ?? '?';
      final dbgT = respuesta['transcripcion'] ?? texto;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('[$dbgI] "$dbgT"'),
        duration: const Duration(seconds: 5),
      ));

      _despacharAccion(respuesta, acciones);
    } catch (_) {
      if (!mounted) return;
      if (mounted) setState(() => vozProcesando = false);
      await tts.speak('Lo siento, no pude conectar con el servidor');
    }
  }

  /// Habla un texto directamente (útil para confirmaciones manuales).
  Future<void> hablar(String texto) => VozSingleton.tts.speak(texto);

  /// Ejemplos de comandos que se muestran en el modal de "no reconocido".
  /// Cada pantalla puede sobreescribir este getter con sus comandos relevantes.
  String get vozEjemplos =>
      '"Quiero un viaje", "Historial", "Mi perfil", "Atrás"';

  // ── Despacho ────────────────────────────────────────────────────────────

  void _despacharAccion(
    Map<String, dynamic> respuesta,
    Map<String, Function(Map<String, dynamic>)> acciones,
  ) {
    final intencion = respuesta['intencion'] as String? ?? 'no_reconocido';
    final entidades = (respuesta['entidades'] as Map<String, dynamic>?) ?? {};
    final transcripcion = respuesta['transcripcion'] as String? ?? '';

    if (acciones.containsKey(intencion)) {
      acciones[intencion]!(entidades);
      return;
    }

    _navegarGlobal(intencion, entidades, transcripcion);
  }

  void _navegarGlobal(
    String intencion,
    Map<String, dynamic> entidades,
    String transcripcion,
  ) {
    switch (intencion) {
      case 'solicitar_viaje':
        Navigator.pushNamed(context, '/agendar_viaje', arguments: entidades);
        break;
      case 'solicitar_viaje_multiple':
        Navigator.pushNamed(
            context, '/agendar_varios_destinos', arguments: entidades);
        break;
      case 'ver_historial':
        Navigator.pushNamed(context, '/historial_viajes_pasajero');
        break;
      case 'ver_viaje_actual':
        Navigator.pushNamed(context, '/viaje_actual');
        break;
      case 'ver_acompanantes':
        Navigator.pushNamed(context, '/registro_acompanante');
        break;
      case 'crear_acompanante':
        Navigator.pushNamed(context, '/registro_acompanante',
            arguments: entidades);
        break;
      case 'ver_pagos':
        Navigator.pushNamed(context, '/metodos_pago_lista');
        break;
      case 'ver_perfil':
        Navigator.pushNamed(context, '/perfil_pasajero');
        break;
      case 'ver_home':
        Navigator.pushNamedAndRemoveUntil(
            context, '/principal_pasajero', (r) => false);
        break;
      case 'ir_atras':
        if (Navigator.canPop(context)) Navigator.pop(context);
        break;
      case 'no_reconocido':
        _mostrarNoReconocido(transcripcion);
        break;
      default:
        _mostrarNoReconocido(transcripcion);
    }
  }

  void _mostrarNoReconocido(String texto) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/rechazado.png', height: 64),
            const SizedBox(height: 16),
            Text(
              'No entendí el comando',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texto.isNotEmpty ? '"$texto"' : 'Intenta de nuevo',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Puedes decir:\n$vozEjemplos',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'Entendido',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
