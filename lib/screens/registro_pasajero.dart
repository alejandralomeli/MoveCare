import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistroPasajero extends StatefulWidget {
  const RegistroPasajero({super.key});

  @override
  State<RegistroPasajero> createState() => _RegistroPasajeroState();
}

class _RegistroPasajeroState extends State<RegistroPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  // Estados para ocultar/mostrar contraseñas
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

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
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
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
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Crea una cuenta de Pasajero',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campos de Texto
                    _buildTextField(label: 'Nombre', iconColor: Colors.blue.shade800),
                    _buildTextField(label: 'Correo electrónico', iconColor: Colors.blue.shade400),
                    _buildTextField(label: 'Teléfono de contacto', iconColor: Colors.blue.shade800),
                    
                    // Campo Contraseña con Ojo
                    _buildPasswordField(
                      label: 'Contraseña', 
                      iconColor: Colors.blue.shade400, 
                      isObscured: _obscurePass,
                      onToggle: () => setState(() => _obscurePass = !_obscurePass)
                    ),

                    // Campo Confirmación con Ojo
                    _buildPasswordField(
                      label: 'Confirmación de contraseña', 
                      iconColor: Colors.blue.shade800, 
                      isObscured: _obscureConfirmPass,
                      onToggle: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass)
                    ),

                    const SizedBox(height: 25),

                    // Botón Registrarme
                    SizedBox(
                      width: size.width * 0.7,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Usamos pushNamedAndRemoveUntil para que el usuario entre al Home
                          // y no pueda regresar al formulario de registro con el botón "atrás".
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            '/home_passenger_screen', 
                            (route) => false
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Registrarme',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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

  Widget _buildTextField({required String label, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: iconColor, radius: 10),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label, 
    required Color iconColor, 
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: iconColor, radius: 10),
            ),
            suffixIcon: IconButton(
              icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: primaryBlue),
              onPressed: onToggle,
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