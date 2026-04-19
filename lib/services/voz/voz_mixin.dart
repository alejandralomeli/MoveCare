import 'package:flutter/material.dart';
import 'voz_service.dart';
import 'voz_singleton.dart';

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

  // ── Inicialización ──────────────────────────────────────────────────────

  Future<void> inicializarVoz() async {
    await VozSingleton.inicializar();
  }

  // ── API pública ─────────────────────────────────────────────────────────

  /// Escucha, interpreta y ejecuta.
  ///
  /// [acciones] — mapa de intent → función a ejecutar en esta pantalla.
  /// Si el intent no está en el mapa, se intenta la navegación global.
  Future<void> escucharComando(
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

    // Si ERA esta pantalla la que estaba escuchando → toggle off
    final eraEstaEscuchando = vozEscuchando;
    if (speech.isListening) {
      await speech.stop();
      if (mounted) setState(() => vozEscuchando = false);
      if (eraEstaEscuchando) return; // el usuario quiso detener
      // Otra pantalla tenía la sesión: esperar y abrir nueva
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (mounted) setState(() => vozEscuchando = true);

    // Auto-reset si la sesión termina sin resultado (timeout)
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && vozEscuchando) setState(() => vozEscuchando = false);
    });

    try {
      await speech.listen(
        localeId: 'es_MX',
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(milliseconds: 1500),
        onResult: (result) async {
          if (!result.finalResult) return;

          final texto = result.recognizedWords.trim();
          if (mounted) setState(() => vozEscuchando = false);
          if (texto.isEmpty) return;

          if (mounted) setState(() => vozProcesando = true);

          try {
            final respuesta = await VozService.interpretarComando(texto);
            if (!mounted) return;
            if (mounted) setState(() => vozProcesando = false);

            final voz = respuesta['respuesta_voz'] as String? ?? '';
            if (voz.isNotEmpty) await tts.speak(voz);

            _despacharAccion(respuesta, acciones);
          } catch (_) {
            if (!mounted) return;
            if (mounted) setState(() => vozProcesando = false);
            await tts.speak('Lo siento, no pude conectar con el servidor');
          }
        },
      );
    } catch (e) {
      // Reinicia el estado visual si listen() falla
      if (mounted) setState(() => vozEscuchando = false);
      debugPrint('VozMixin: error al escuchar — $e');
      // Reinicializar el singleton para recuperar el objeto de reconocimiento
      await VozSingleton.reinicializar();
    }
  }

  /// Habla un texto directamente (útil para confirmaciones manuales).
  Future<void> hablar(String texto) => VozSingleton.tts.speak(texto);

  // ── Despacho ────────────────────────────────────────────────────────────

  void _despacharAccion(
    Map<String, dynamic> respuesta,
    Map<String, Function(Map<String, dynamic>)> acciones,
  ) {
    final intencion = respuesta['intencion'] as String? ?? 'no_reconocido';
    final entidades =
        (respuesta['entidades'] as Map<String, dynamic>?) ?? {};

    // 1. Acción específica de esta pantalla
    if (acciones.containsKey(intencion)) {
      acciones[intencion]!(entidades);
      return;
    }

    // 2. Navegación global (funciona en cualquier pantalla de pasajero)
    _navegarGlobal(intencion, entidades);
  }

  void _navegarGlobal(
    String intencion,
    Map<String, dynamic> entidades,
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
      case 'ver_home':
        Navigator.pushNamedAndRemoveUntil(
            context, '/principal_pasajero', (r) => false);
        break;
      case 'ir_atras':
        if (Navigator.canPop(context)) Navigator.pop(context);
        break;
      case 'no_reconocido':
        _mostrarNoReconocido();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ese comando no está disponible en esta pantalla'),
            backgroundColor: Colors.black54,
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  void _mostrarNoReconocido() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No te entendí bien',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Intenta con comandos como:\n"Quiero un viaje", "Historial", "Atrás", "Confirmar"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    );
  }
}
