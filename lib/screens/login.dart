import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightInputBlue = Color(0xFFB3D4FF);
  static const Color googleBtnBlue = Color(0xFFE1EBFD);
  static const Color forgotPasswordRed = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Capa de Fondo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Capa de Contenido
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.75,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildTextField(
                      hint: 'Correo',
                      iconColor: primaryBlue,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      hint: 'Contraseña',
                      iconColor: const Color(0xFF64A1F4),
                    ),
                    const SizedBox(height: 30),
                    _buildIngresarBtn(),
                    const SizedBox(height: 25),
                    _buildGoogleBtn(),
                    const SizedBox(height: 35),
                    _buildFooter(context), // Pasando el context correctamente
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 130,
      height: 130,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/movecare.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required Color iconColor}) {
    return Container(
      decoration: BoxDecoration(
        color: lightInputBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: iconColor,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildIngresarBtn() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          'Ingresar',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleBtn() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: googleBtnBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icono_google.png', height: 24),
          const SizedBox(width: 12),
          Text(
            'Iniciar Sesión con Google',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER ACTUALIZADO CON RUTAS ---
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Navega a la pantalla de selección de rol
            Navigator.pushNamed(context, '/register_screen');
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(color: Colors.black87, fontSize: 16),
              children: [
                const TextSpan(text: '¿No tienes cuenta? '),
                TextSpan(
                  text: 'Registrate',
                  style: GoogleFonts.montserrat(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Navega a la pantalla de recuperación de contraseña
            Navigator.pushNamed(context, '/forgot_password_screen');
          },
          child: Text(
            'Olvide mi contraseña',
            style: GoogleFonts.montserrat(
              color: forgotPasswordRed,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}