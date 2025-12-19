import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo del Mapa
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

          // 2. Tarjeta Blanca
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
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
                    
                    // Logo Circular
                    _buildLogo(),

                    const SizedBox(height: 30),

                    // Título
                    Text(
                      '¿Olvidaste tu contraseña?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Instrucción
                    Text(
                      'Por favor ingrese su correo electrónico para recibir un codigo de confirmación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Campo de Correo
                    _buildEmailField(),

                    const SizedBox(height: 40),

                    // Botón de Confirmar
                    SizedBox(
                      width: size.width * 0.7,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para enviar código
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirma tu correo',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF), // Azul muy clarito de fondo del logo
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset('assets/movecare.png'),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: fieldBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Correo',
          hintStyle: GoogleFonts.montserrat(
            color: primaryBlue.withOpacity(0.7),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: UnconstrainedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: primaryBlue,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}