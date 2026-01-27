import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightButtonBlue = Color(0xFFB3D4FF);

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png', 
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            left: sp(10, context),
            top: sp(45, context), 
            child: SafeArea( 
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: sp(20, context)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: sp(30, context)),
                padding: EdgeInsets.symmetric(
                  horizontal: sp(24, context), 
                  vertical: sp(40, context)
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sp(40, context)),
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
                    _buildLogo(context),
                    SizedBox(height: sp(40, context)),
                    _buildRoleButton(
                      context: context,
                      label: 'Soy conductor',
                      onPressed: () => Navigator.pushNamed(context, '/driver_register_screen'),
                    ),
                    SizedBox(height: sp(15, context)),
                    _buildRoleButton(
                      context: context,
                      label: 'Soy pasajero',
                      onPressed: () => Navigator.pushNamed(context, '/passenger_register_screen'),
                    ),
                    SizedBox(height: sp(40, context)),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogo(BuildContext context) {
    double size = sp(120, context);
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(child: Image.asset('assets/movecare.png', fit: BoxFit.contain)),
    );
  }

  Widget _buildRoleButton({required BuildContext context, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: sp(55, context),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: lightButtonBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sp(20, context))),
        ),
        child: Text(label, style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: sp(16, context))),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿Ya tienes cuenta? ', style: GoogleFonts.montserrat(color: Colors.black54, fontSize: sp(13, context))),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text('Inicia Sesión', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: sp(13, context))),
        ),
      ],
    );
  }
}