import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverRegisterScreen extends StatelessWidget {
  const DriverRegisterScreen({super.key});

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
            height: size.height * 0.4,
            child: Image.asset(
              'assets/ruta.png', 
              fit: BoxFit.cover,
            ),
          ),

          // 2. Logo superior flotante
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset('assets/movecare.png'),
                ),
              ),
            ),
          ),

          // 3. Tarjeta Blanca con Formulario
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
              child: SingleChildScrollView( // Permite scroll si el teclado aparece
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Crea una cuenta de Conductor',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Campos de Texto
                    _buildTextField(label: 'Nombre', iconColor: Colors.blue.shade800),
                    _buildTextField(label: 'Correo electrónico', iconColor: Colors.blue.shade400),
                    _buildTextField(label: 'Teléfono de contacto', iconColor: Colors.blue.shade800),
                    _buildTextField(label: 'Contraseña', iconColor: Colors.blue.shade400, isPassword: true),
                    _buildTextField(label: 'Confirmación de contraseña', iconColor: Colors.blue.shade800, isPassword: true),

                    const SizedBox(height: 30),

                    // Botón Continuar
                    SizedBox(
                      width: size.width * 0.7,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/continue_driver_register_screen');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Continuar con mi registro',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Footer
                    _buildFooter(context),
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

  Widget _buildTextField({required String label, required Color iconColor, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: iconColor,
                radius: 10,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿Ya tienes cuenta? ', style: GoogleFonts.montserrat(fontSize: 13)),
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