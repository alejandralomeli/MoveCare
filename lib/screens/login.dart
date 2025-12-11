import 'package:flutter/material.dart';
import '../main.dart'; 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
     
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _buildBackgroundPattern(screenHeight),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildLoginCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern(double screenHeight) {
    return Container(
      height: screenHeight * 0.55, 
      decoration: BoxDecoration(
        color: cardBackgroundColor.withOpacity(0.8), 
      ),
      child: Image.asset(
        'assets/fondo_ruta.png', 
        fit: BoxFit.cover, 
        alignment: Alignment.topCenter, 
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: cardBackgroundColor.withOpacity(0.8),
            child: const Center(
              child: Text("Fondo no cargado", style: TextStyle(color: Colors.white70)),
            ),
          );
        },
      ),
    );
  }

  // El card que contiene todos los campos y botones
  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.only(top: 80, bottom: 20),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildAppLogo(),
          const SizedBox(height: 30),

          _buildTextField(
            label: 'Correo',
            icon: Icons.email_outlined,
            isPassword: false,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Contraseña',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 30),

          // Botón Ingresar
          _buildPrimaryButton(context),
          const SizedBox(height: 20),

          // Botón Iniciar Sesión con Google
          _buildGoogleSignInButton(),
          const SizedBox(height: 40),

          // Enlaces Registrate y Olvidé mi contraseña
          _buildFooterLinks(),
        ],
      ),
    );
  }

  // Logo de la aplicación 
  Widget _buildAppLogo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/movecare.png',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si la imagen no se encuentra
            return const Icon(
              Icons.directions_car_filled,
              size: 50,
              color: primaryColor,
            );
          },
        ),
      ),
    );
  }

  // Campo de texto personalizado (Correo y Contraseña)
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: primaryColor),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 10.0),
            child: Icon(icon, color: primaryColor),
          ),
        ),
      ),
    );
  }

  // Botón principal de Ingresar
  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Lógica de inicio de sesión aquí
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Intentando Iniciar Sesión...')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Ingresar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // Botón de Iniciar Sesión con Google
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Lógica de inicio de sesión con Google aquí
        },
        icon: Image.asset(
          'assets/icono_google.png', // Ruta a tu icono de Google
          height: 20.0,
        ),
        label: const Text(
          'Iniciar Sesión con Google',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
    );
  }

  // Enlaces de pie de página (Registrate y Olvidé mi contraseña)
  Widget _buildFooterLinks() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '¿No tienes cuenta? ',
              style: TextStyle(color: Colors.black54),
            ),
            GestureDetector(
              onTap: () {
                // Lógica para navegar a la pantalla de registro
              },
              child: const Text(
                'Regístrate',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            // Lógica para navegar a la pantalla de olvido de contraseña
          },
          child: Text(
            'Olvidé mi contraseña',
            style: TextStyle(
              color: primaryColor.withOpacity(0.7),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// **CLASE MapPatternPainter ELIMINADA** porque ahora usamos una imagen asset.