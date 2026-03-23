import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/storage/secure_storage.dart';
import '../app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _verificarSesion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await SecureStorage.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final normalized = base64Url.normalize(parts[1]);
          final payloadMap = jsonDecode(
            utf8.decode(base64Url.decode(normalized)),
          );
          final rol = payloadMap['rol'];

          // Evaluamos el rol y redirigimos a la pantalla correspondiente
          switch (rol) {
            case 'conductor':
              Navigator.of(
                context,
              ).pushReplacementNamed('/principal_conductor');
              return;
            case 'pasajero':
              Navigator.of(context).pushReplacementNamed('/principal_pasajero');
              return;
            case 'administrador':
              Navigator.of(
                context,
              ).pushReplacementNamed('/principal_administrador');
              return;
            default:
              // Si el rol no coincide con ninguno, marcamos en consola y seguimos
              debugPrint('Rol desconocido: $rol. Redirigiendo a bienvenido.');
              break;
          }
        }
      } catch (e) {
        debugPrint('Error decodificando token: $e');
      }
    }

    // Si no hay token, falló la decodificación o el rol era inválido:
    Navigator.of(context).pushReplacementNamed('/bienvenido');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/movecare.png',
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.local_hospital_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'MoveCare',
                style: GoogleFonts.montserrat(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tu movilidad, nuestra prioridad',
                style: GoogleFonts.montserrat(
                  color: AppColors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white.withValues(alpha: 0.8),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
