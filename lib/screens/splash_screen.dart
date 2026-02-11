// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/storage/secure_storage.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    // 1. Simular carga
    await Future.delayed(const Duration(seconds: 2));

    // 2. Verificar token
    final token = await SecureStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // ✅ HAY SESIÓN: Vamos al Home del Pasajero
      Navigator.of(context).pushReplacementNamed('/principal_pasajero');
    } else {
      // ❌ NO HAY SESIÓN: Vamos a Bienvenido
      // CORRECCIÓN: Apuntamos a '/bienvenido' en lugar de '/'
      Navigator.of(context).pushReplacementNamed('/bienvenido'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E6FFC), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled, 
                size: 60, 
                color: Color(0xFF2E6FFC),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              "Cargando MoveCare...",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}