import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightButtonBlue = Color(0xFFB3D4FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png', 
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  _buildLogo(),

                  const SizedBox(height: 40),

                  _buildRoleButton(
                    label: 'Soy conductor',
                    onPressed: () {
                      Navigator.pushNamed(context, '/driver_register_screen');
                    },
                  ),
                  
                  const SizedBox(height: 15),

                  _buildRoleButton(
                    label: 'Soy pasajero',
                    onPressed: () {
                      Navigator.pushNamed(context, '/passenger_register_screen');
                    },
                  ),

                  const SizedBox(height: 40),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120, 
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval( 
        child: Image.asset(
          'assets/movecare.png', 
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildRoleButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightButtonBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: GoogleFonts.montserrat(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            'Inicia Sesión',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}