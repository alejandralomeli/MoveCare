// screens/splash_screen.dart
import 'dart:convert'; // Necesario para base64Url y jsonDecode
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
    // 1. Simular tiempo de carga para que se vea la animación
    await Future.delayed(const Duration(seconds: 2));

    // 2. Obtener el token guardado
    final token = await SecureStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      try {
        // 3. Decodificar el JWT (header.payload.signature)
        final parts = token.split('.');
        if (parts.length == 3) {
          final payloadBase64 = parts[1];
          
          // Normalizamos el base64 por si faltan caracteres de padding (=)
          final normalized = base64Url.normalize(payloadBase64);
          final payloadString = utf8.decode(base64Url.decode(normalized));
          final payloadMap = jsonDecode(payloadString);

          // 4. Extraer el rol (coincide con tu payload de FastAPI)
          final rol = payloadMap['rol']; 

          // 5. Redirigir según el rol
          if (rol == 'conductor') {
            Navigator.of(context).pushReplacementNamed('/principal_conductor');
            return; // Salimos de la función para no ejecutar el código de abajo
          }
        }
      } catch (e) {
        debugPrint("Error decodificando token en Splash: $e");
        // Si el token está mal formado por alguna razón, no rompemos la app,
        // simplemente caerá al default de pasajero.
      }

      // Por defecto o si el rol es 'pasajero'
      Navigator.of(context).pushReplacementNamed('/principal_pasajero');
    } else {
      // ❌ NO HAY SESIÓN o TOKEN VACÍO: Vamos a Bienvenido
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