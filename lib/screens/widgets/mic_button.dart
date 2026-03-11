import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Botón de micrófono reutilizable con animación de pulso.
/// Primario (azul) en reposo, error (rojo) cuando está activo.
class MicButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  final double size;

  const MicButton({
    super.key,
    required this.isActive,
    required this.onTap,
    this.size = 52,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isActive ? AppColors.error : AppColors.primary;
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            widget.isActive ? Icons.graphic_eq : Icons.mic,
            color: AppColors.white,
            size: widget.size * 0.46,
          ),
        ),
      ),
    );
  }
}
