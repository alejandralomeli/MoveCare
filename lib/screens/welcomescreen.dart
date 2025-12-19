import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color de fondo de tu imagen para evitar bordes blancos
      backgroundColor: const Color(0xFFC5DFFF), 
      body: Stack(
        children: [
          // 1. FONDO: Tu imagen completa (Mapa + Pin + Texto)
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_welcome.png', // Asegúrate de que este sea el nombre en pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. BOTONES: Posicionados en la parte inferior
          Positioned(
            bottom: 80, // Ajusta este número para subir o bajar los botones
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSimpleButton(context, 'Iniciar Sesión', '/login'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '|',
                    style: TextStyle(
                      color: Color(0xFF1559B2), 
                      fontSize: 26, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                _buildSimpleButton(context, 'Registrarse', '/register_screen'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleButton(BuildContext context, String text, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1559B2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}