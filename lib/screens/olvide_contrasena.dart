import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OlvideContrasena extends StatelessWidget {
  const OlvideContrasena({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);
  double sp(double size, double sw) => sw * (size / 375);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sh * 0.45,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 45,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: primaryBlue,
                size: 20, 
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: sh * 0.65,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.09),
                child: Column(
                  children: [
      
                    _buildLogo(sh),

                    SizedBox(height: sh * 0.03),

                    Text(
                      '¿Olvidaste tu contraseña?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(22, sw),
                      ),
                    ),

                    SizedBox(height: sh * 0.02),

                    Text(
                      'Por favor ingrese su correo electrónico para recibir un código de confirmación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: sp(14, sw),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: sh * 0.04),

                    _buildEmailField(sw),

                    SizedBox(height: sh * 0.05),
                    SizedBox(
                      width: sw * 0.75,
                      height: sp(55, sw),
                      child: ElevatedButton(
                        onPressed: () {
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
                            fontSize: sp(16, sw),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double sh) {
    double logoSize = sh * 0.13;
    if (logoSize > 110) logoSize = 110;

    return Center(
      child: Container(
        width: logoSize,
        height: logoSize,
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

  Widget _buildEmailField(double sw) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.montserrat(
          color: primaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: sp(15, sw),
        ),
        decoration: InputDecoration(
          hintText: 'Correo',
          hintStyle: GoogleFonts.montserrat(
            color: primaryBlue.withOpacity(0.7),
            fontSize: sp(15, sw),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: UnconstrainedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CircleAvatar(
                radius: sp(12, sw),
                backgroundColor: primaryBlue,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: sp(18, sw)),
        ),
      ),
    );
  }
}