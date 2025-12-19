import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({super.key});

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
              height: size.height * 0.70, // Un poco más alta para que quepan bien los elementos
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
                    
                    // Logo MoveCare
                    _buildLogo(),

                    const SizedBox(height: 30),

                    // Título
                    Text(
                      'Código de verificación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Instrucción
                    Text(
                      'Codigo de verificación enviado a:\nmovecaregmail.com',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // --- BLOQUES DE CÓDIGO (4 Celdas) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCodeBox(context, first: true, last: false),
                        _buildCodeBox(context, first: false, last: false),
                        _buildCodeBox(context, first: false, last: false),
                        _buildCodeBox(context, first: false, last: true),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Botón de Confirmar Código
                    SizedBox(
                      width: size.width * 0.65,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navegar a la pantalla de "Nueva Contraseña"
                          // Navigator.pushNamed(context, '/reset_password');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirmar código',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer: Reenviar código
                    _buildResendFooter(),
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
        decoration: const BoxDecoration(
          color: Color(0xFFE8F1FF),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset('assets/movecare.png'),
        ),
      ),
    );
  }

  // Widget para cada celda del código de 4 dígitos
  Widget _buildCodeBox(BuildContext context, {required bool first, last}) {
    return Container(
      height: 70,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlue, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: false,
        readOnly: false,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryBlue
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildResendFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '00:29 ',
          style: GoogleFonts.montserrat(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          'Reenviar código de confirmación',
          style: GoogleFonts.montserrat(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}