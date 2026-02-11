import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistroConductor extends StatelessWidget {
  const RegistroConductor({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375); 
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;

    return Scaffold(
      body: Stack(
        children: [
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

          Positioned(
            top: MediaQuery.of(context).padding.top + 35,
            left: 15,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: sp(100, context),
                height: sp(100, context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/movecare.png'),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.68,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                child: Column(
                  children: [
                    SizedBox(height: sp(35, context)),
                    Text(
                      'Crea una cuenta de Conductor',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(18, context),
                      ),
                    ),
                    SizedBox(height: sp(25, context)),

                    _buildTextField(context, label: 'Nombre', iconColor: Colors.blue.shade800),
                    _buildTextField(context, label: 'Correo electrónico', iconColor: Colors.blue.shade400),
                    _buildTextField(context, label: 'Teléfono de contacto', iconColor: Colors.blue.shade800),
                    _buildTextField(context, label: 'Contraseña', iconColor: Colors.blue.shade400, isPassword: true),
                    _buildTextField(context, label: 'Confirmación de contraseña', iconColor: Colors.blue.shade800, isPassword: true),

                    SizedBox(height: sp(25, context)),

                    SizedBox(
                      width: sw * 0.75,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/continue_driver_register_screen');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Continuar con mi registro',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: sp(14, context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: sp(20, context)),

                    _buildFooter(context),
                    SizedBox(height: sp(30, context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, required Color iconColor, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          obscureText: isPassword,
          style: GoogleFonts.montserrat(fontSize: sp(14, context), color: Colors.black87),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue.withOpacity(0.7), 
              fontSize: sp(13, context), 
              fontWeight: FontWeight.w600
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: iconColor,
                radius: 8,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
          style: GoogleFonts.montserrat(fontSize: sp(13, context))
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            'Inicia Sesión',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: sp(13, context),
            ),
          ),
        ),
      ],
    );
  }
}