import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class ChatViaje extends StatefulWidget {
  /// nombre del contacto con quien se chatea
  final String nombreContacto;

  /// true = el usuario actual es conductor, false = pasajero
  final bool esConductor;

  const ChatViaje({
    super.key,
    required this.nombreContacto,
    required this.esConductor,
  });

  @override
  State<ChatViaje> createState() => _ChatViajeState();
}

class _ChatViajeState extends State<ChatViaje> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_Mensaje> _mensajes = [
    _Mensaje('Hola, ya voy en camino hacia ti.', false, '9:18 AM'),
    _Mensaje('Perfecto, te espero en la entrada principal.', true, '9:19 AM'),
    _Mensaje('Entendido, en 5 minutos llego.', false, '9:19 AM'),
  ];

  final List<String> _respuestasRapidas = [
    'Ya voy 👍',
    'Estoy esperando',
    'Llego en 5 min',
    'Ok, entendido',
    'Gracias',
  ];

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  void _enviar(String texto) {
    if (texto.trim().isEmpty) return;
    setState(() {
      _mensajes.add(_Mensaje(texto.trim(), true, _horaActual()));
    });
    _ctrl.clear();
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

  String _horaActual() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMensajes()),
          _buildRespuestasRapidas(),
          _buildInput(context),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

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
                onPressed: () => Navigator.pop(context),
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

  Widget _buildBurbuja(_Mensaje msg) {
    final esMio = msg.esMio;
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
                  msg.texto,
                  style: mBold(
                    color: esMio ? AppColors.white : AppColors.textPrimary,
                    size: 13,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(msg.hora, style: mBold(color: AppColors.textSecondary, size: 10)),
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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

class _Mensaje {
  final String texto;
  final bool esMio;
  final String hora;
  _Mensaje(this.texto, this.esMio, this.hora);
}
