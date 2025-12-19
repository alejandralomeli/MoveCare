import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightInputBlue = Color(0xFFB3D4FF);

  // Estados para mostrar/ocultar contraseña
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
            height: size.height * 0.4,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Tarjeta Blanca
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.7,
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
                    const SizedBox(height: 35),
                    
                    // Logo MoveCare
                    _buildLogo(),

                    const SizedBox(height: 25),

                    // Título
                    Text(
                      'Nueva Contraseña',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Instrucción
                    Text(
                      'Por favor ingrese su nueva contraseña',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- CAMPOS DE CONTRASEÑA ---
                    _buildPasswordField(
                      label: 'Nueva contraseña',
                      isObscured: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      iconColor: primaryBlue,
                    ),

                    const SizedBox(height: 15),

                    _buildPasswordField(
                      label: 'Confirmar nueva contraseña',
                      isObscured: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      iconColor: const Color(0xFF64A1F4), // Azul más claro
                    ),

                    const SizedBox(height: 40),

                    // Botón Confirmar
                    SizedBox(
                      width: size.width * 0.7,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para guardar la nueva contraseña y volver al login
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirmar contraseña',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F1FF),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/movecare.png'),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool isObscured,
    required VoidCallback onToggle,
    required Color iconColor,
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
              fontSize: 13,
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
            style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: UnconstrainedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: iconColor,
                  ),
                ),
              ),
              // ICONO DE OJO PARA MOSTRAR/OCULTAR
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: primaryBlue.withOpacity(0.6),
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}