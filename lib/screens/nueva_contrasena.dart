import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NuevaContrasena extends StatefulWidget {
  const NuevaContrasena({super.key});

  @override
  State<NuevaContrasena> createState() => _NuevaContrasenaState();
}

class _NuevaContrasenaState extends State<NuevaContrasena> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightInputBlue = Color(0xFFB3D4FF);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sh * 0.4,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 45,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: sp(20, sw)),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: sh * 0.72,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.09),
                child: Column(
                  children: [
                    SizedBox(height: sh * 0.04),

                    _buildLogo(sh, sw),

                    SizedBox(height: sh * 0.03),

                    Text(
                      'Nueva Contraseña',
                      textAlign: TextAlign.center,
                      style: mBold(color: primaryBlue, size: 24, sw: sw),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Por favor ingrese su nueva contraseña',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: sp(13, sw),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: sh * 0.04),

                    _buildPasswordField(
                      label: 'Nueva contraseña',
                      isObscured: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      iconColor: primaryBlue,
                      sw: sw,
                    ),

                    const SizedBox(height: 15),

                    _buildPasswordField(
                      label: 'Confirmar nueva contraseña',
                      isObscured: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      iconColor: const Color(0xFF64A1F4),
                      sw: sw,
                    ),

                    SizedBox(height: sh * 0.05),

                    SizedBox(
                      width: sw * 0.75,
                      height: sp(55, sw),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/iniciar_sesion', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Confirmar contraseña',
                          style: mBold(color: Colors.white, size: 16, sw: sw),
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.05), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double sh, double sw) {
    double logoDim = sh * 0.12; 
    if (logoDim > 100) logoDim = 100;

    return Center(
      child: Container(
        width: logoDim,
        height: logoDim,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F1FF),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/movecare.png', errorBuilder: (c, e, s) => const Icon(Icons.health_and_safety, color: primaryBlue, size: 40)),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool isObscured,
    required VoidCallback onToggle,
    required Color iconColor,
    required double sw,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              color: Colors.black87,
              fontSize: sp(13, sw),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: lightInputBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            obscureText: isObscured,
            style: GoogleFonts.montserrat(
              color: primaryBlue, 
              fontWeight: FontWeight.w600,
              fontSize: sp(14, sw)
            ),
            decoration: InputDecoration(
              prefixIcon: UnconstrainedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CircleAvatar(
                    radius: sp(10, sw),
                    backgroundColor: iconColor,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: primaryBlue.withOpacity(0.6),
                  size: sp(20, sw),
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: sp(18, sw)),
            ),
          ),
        ),
      ],
    );
  }
}