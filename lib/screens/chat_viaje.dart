import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Asegúrate de que las rutas a tus archivos coincidan con tu proyecto
import '../app_theme.dart';
import '../models/mensaje_model.dart';
import '../services/chat/chat_service.dart';

class ChatViaje extends StatefulWidget {
  final String nombreContacto;
  final bool esConductor;
  final String idViaje;
  final String idUsuarioActual;

  const ChatViaje({
    super.key,
    required this.nombreContacto,
    required this.esConductor,
    required this.idViaje,
    required this.idUsuarioActual,
  });

  @override
  State<ChatViaje> createState() => _ChatViajeState();
}

class _ChatViajeState extends State<ChatViaje> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<MensajeModel> _mensajes = [];
  Timer? _pollingTimer;
  bool _isCargando = true;

  final List<String> _respuestasRapidas = [
    'Ya voy 👍',
    'Estoy esperando',
    'Llego en 5 min',
    'Ok, entendido',
    'Gracias',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Carga inicial de mensajes
    _cargarHistorial(animarScroll: true);
    
    // 2. Polling: Pide mensajes nuevos cada 3 segundos al backend
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _cargarHistorial(animarScroll: false);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // IMPORTANTE: Matar el proceso en 2do plano al salir
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial({required bool animarScroll}) async {
    try {
      final historial = await ChatService.obtenerHistorial(widget.idViaje);
      
      // Solo repinta la pantalla si hay mensajes nuevos
      if (historial.length != _mensajes.length) {
        setState(() {
          _mensajes = historial;
          _isCargando = false;
        });

        if (animarScroll) {
          _hacerScrollAlFondo();
        }
      } else if (_isCargando) {
        setState(() => _isCargando = false);
      }
    } catch (e) {
      debugPrint("Error al hacer polling del chat: $e");
    }
  }

  void _hacerScrollAlFondo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviar(String texto) async {
    if (texto.trim().isEmpty) return;
    
    final textoEnviado = texto.trim();
    _ctrl.clear(); // Limpiamos el input de inmediato
    
    try {
      // Enviamos el mensaje a FastAPI
      final nuevoMensaje = await ChatService.enviarMensaje(widget.idViaje, textoEnviado);
      
      setState(() {
        _mensajes.add(nuevoMensaje);
      });
      _hacerScrollAlFondo();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el mensaje: $e')),
      );
    }
  }

  String _formatearHora(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isCargando 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
                : _buildMensajes(),
          ),
          _buildRespuestasRapidas(),
          _buildInput(context),
        ],
      ),
    );
  }

  // ── HEADER CON REDIRECCIÓN DE RUTAS ───────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                onPressed: () {
                  // Cancelamos el timer por seguridad antes de cambiar de ruta
                  _pollingTimer?.cancel();
                  
                  // Lógica de ruteo según el rol del usuario
                  if (widget.esConductor) {
                    Navigator.pushReplacementNamed(context, '/viaje_actual');
                  } else {
                    Navigator.pushReplacementNamed(context, '/viaje_actual_pasajero');
                  }
                },
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  widget.esConductor ? 'assets/pasajero.png' : 'assets/conductor.png',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.nombreContacto, style: mBold(size: 15)),
                    Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.esConductor ? 'Pasajero · En viaje' : 'Conductor · En camino',
                          style: mBold(color: AppColors.textSecondary, size: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── MENSAJES ──────────────────────────────────────────────────────────────
  Widget _buildMensajes() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: _mensajes.length,
      itemBuilder: (_, i) => _buildBurbuja(_mensajes[i]),
    );
  }

  Widget _buildBurbuja(MensajeModel msg) {
    // Determinamos si el globo va a la derecha o izquierda comparando IDs
    final esMio = msg.idEmisor == widget.idUsuarioActual;
    final horaStr = _formatearHora(msg.fechaEnvio);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esMio) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage(
                widget.esConductor ? 'assets/pasajero.png' : 'assets/conductor.png',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.52),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: esMio ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(esMio ? 16 : 4),
                    bottomRight: Radius.circular(esMio ? 4 : 16),
                  ),
                  border: esMio ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  msg.contenido,
                  style: mBold(
                    color: esMio ? AppColors.white : AppColors.textPrimary,
                    size: 13,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(horaStr, style: mBold(color: AppColors.textSecondary, size: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ── RESPUESTAS RÁPIDAS ────────────────────────────────────────────────────
  Widget _buildRespuestasRapidas() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _respuestasRapidas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _enviar(_respuestasRapidas[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              _respuestasRapidas[i],
              style: mBold(color: AppColors.primary, size: 12),
            ),
          ),
        ),
      ),
    );
  }

  // ── INPUT ─────────────────────────────────────────────────────────────────
  Widget _buildInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 10, 16, MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              onSubmitted: _enviar,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: mBold(color: AppColors.textSecondary, size: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _enviar(_ctrl.text),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
