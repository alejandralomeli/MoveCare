import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth/auth_service.dart';
import '../core/storage/secure_storage.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightInputBlue = Color(0xFFB3D4FF);
  static const Color googleBtnBlue = Color(0xFFE1EBFD);
  static const Color forgotPasswordRed = Color(0xFFE57373);

  @override
  State<IniciarSesion> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<IniciarSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.75,
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
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildTextField(
                      hint: 'Correo',
                      iconColor: IniciarSesion.primaryBlue,
                      controller: _emailController,
                      isPassword: false,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      hint: 'Contraseña',
                      iconColor: const Color(0xFF64A1F4),
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    _buildIngresarBtn(),
                    const SizedBox(height: 25),
                    _buildGoogleBtn(),
                    const SizedBox(height: 35),
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

  Widget _buildLogo() {
    return Container(
      width: 130,
      height: 130,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset('assets/movecare.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required Color iconColor,
    required TextEditingController controller,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: IniciarSesion.lightInputBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            color: IniciarSesion.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CircleAvatar(radius: 18, backgroundColor: iconColor),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildIngresarBtn() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: IniciarSesion.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Ingresar',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleBtn() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: IniciarSesion.googleBtnBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icono_google.png', height: 24),
          const SizedBox(width: 12),
          Text(
            'Iniciar Sesión con Google',
            style: GoogleFonts.montserrat(
              color: IniciarSesion.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/registro');
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(
                color: Colors.black87,
                fontSize: 16,
              ),
              children: [
                const TextSpan(text: '¿No tienes cuenta? '),
                TextSpan(
                  text: 'Registrate',
                  style: GoogleFonts.montserrat(
                    color: IniciarSesion.primaryBlue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/olvide_contrasena');
          },
          child: Text(
            'Olvide mi contraseña',
            style: GoogleFonts.montserrat(
              color: IniciarSesion.forgotPasswordRed,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ================== LOGIN ==================

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlert('Campos vacíos', 'Por favor llena todos los campos');
      return;
    }

    setState(() => _loading = true);

    final result = await AuthService.login(email: email, password: password);

    setState(() => _loading = false);

    if (result['ok']) {
      final data = result['data'];
      final rol = data['rol'];

      if (!mounted) return;

      if (rol == 'pasajero') {
        Navigator.pushReplacementNamed(context, '/principal_pasajero');
      } else if (rol == 'conductor') {
        Navigator.pushReplacementNamed(context, '/home_conductor_screen');
      } else if (rol == 'administrador') {
        Navigator.pushReplacementNamed(context, '/home_admin_screen');
      } else {
        _showAlert('Error', 'Rol no reconocido');
      }
    } else {
      final error = result['error'];
      final errorMsg = error is Map && error['detail'] != null
          ? error['detail'].toString()
          : error.toString();

      // 🔥 REDIRECCIÓN A CONFIRMAR CORREO
      if (errorMsg.contains(
        'Debes verificar tu correo antes de iniciar sesión.',
      )) {
        Navigator.pushReplacementNamed(context, '/confirmar-correo');
        return;
      }

      _showAlert('Error de inicio de sesión', errorMsg);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
