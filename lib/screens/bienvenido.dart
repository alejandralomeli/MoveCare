import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Bienvenido extends StatelessWidget {
  const Bienvenido({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFC5DFFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView( 
              child: SizedBox(
                width: double.infinity,
                height: size.height - MediaQuery.of(context).padding.top, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.22), 
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Image.asset(
                        'assets/movecare_principal.png',
                        fit: BoxFit.contain,
                        width: size.width * 0.75,
                        errorBuilder: (c, e, s) => const Icon(Icons.image, size: 150, color: primaryBlue),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.05), 

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSimpleButton(context, 'Iniciar Sesión', '/login', size),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                            child: Text(
                              '|',
                              style: GoogleFonts.montserrat(
                                color: primaryBlue,
                                fontSize: isSmallScreen ? 24 : 30,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          _buildSimpleButton(context, 'Registrarse', '/register_screen', size),
                        ],
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

  Widget _buildSimpleButton(BuildContext context, String text, String route, Size screenSize) {
    double fontSize = screenSize.width * 0.035; 
    if (fontSize > 16) fontSize = 16; 
    if (fontSize < 12) fontSize = 12; 

    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05, 
          vertical: 15
        ),
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}