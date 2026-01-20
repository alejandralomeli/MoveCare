import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Bienvenido extends StatelessWidget {
  const Bienvenido({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantenemos el color de fondo para suavizar bordes
      backgroundColor: const Color(0xFFC5DFFF), 
      body: Stack(
        children: [
          // 1. FONDO: Ahora usa ruta.png
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png', 
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. IMAGEN CENTRAL: movecare_principal.png
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                'assets/movecare_principal.png',
                fit: BoxFit.contain,
                // Ajusta el ancho según necesites que se vea el logo
                width: MediaQuery.of(context).size.width * 0.7, 
                errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),
          ),

          // 3. BOTONES: Posicionados en la parte inferior
          Positioned(
            bottom: 250, 
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSimpleButton(context, 'Iniciar Sesión', '/iniciar_sesion'),
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
                _buildSimpleButton(context, 'Registrarse', '/registro'),
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