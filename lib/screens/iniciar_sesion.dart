import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth/auth_service.dart';
import '../core/storage/secure_storage.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightInputBlue = Color(0xFFB3D4FF);
  static const Color googleBtnBlue = Color(0xFFE1EBFD);
  static const Color forgotPasswordRed = Color(0xFFE57373);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  // Función de escalado responsive
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fondo superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.40,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: lightInputBlue),
            ),
          ),

          // Botón de regreso (UI de main)
          Positioned(
            top: MediaQuery.of(context).padding.top + sp(10, context),
            left: sp(10, context),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: primaryBlue,
                size: sp(20, context),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Contenedor blanco principal
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sp(50, context)),
                  topRight: Radius.circular(sp(50, context)),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5)
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sp(35, context)),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.04),
                    _buildLogo(size, context),
                    SizedBox(height: size.height * 0.04),
                    
                    _buildTextField(
                      context: context,
                      hint: 'Correo',
                      iconColor: primaryBlue,
                      controller: _emailController,
                      isPassword: false,
                    ),
                    
                    SizedBox(height: sp(15, context)),
                    
                    _buildTextField(
                      context: context,
                      hint: 'Contraseña',
                      iconColor: const Color(0xFF64A1F4),
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    _buildIngresarBtn(context),
                    
                    SizedBox(height: sp(20, context)),
                    
                    _buildGoogleBtn(size, context),
                    
                    SizedBox(height: sp(30, context)),
                    
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

  Widget _buildLogo(Size size, BuildContext context) {
    double logoSize = size.height * 0.15;
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset(
          'assets/movecare.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => CircleAvatar(
            backgroundColor: lightInputBlue,
            child: Icon(Icons.person, size: logoSize * 0.5, color: primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String hint,
    required Color iconColor,
    required TextEditingController controller, // Restaurado de HEAD
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: lightInputBlue,
        borderRadius: BorderRadius.circular(sp(20, context)),
      ),
      child: TextField(
        controller: controller, // Restaurado conexión
        obscureText: isPassword,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w500,
          fontSize: sp(14, context),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: sp(14, context),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(sp(8, context)),
            child: CircleAvatar(
              radius: sp(15, context),
              backgroundColor: iconColor,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: sp(18, context)),
        ),
      ),
    );
  }

  Widget _buildIngresarBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: sp(55, context),
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sp(25, context)),
          ),
          elevation: 4,
        ),
        // Combinación: Estilo de main, Lógica de HEAD
        child: _loading
            ? SizedBox(
                height: sp(24, context),
                width: sp(24, context),
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Ingresar',
                style: GoogleFonts.montserrat(
                  fontSize: sp(18, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleBtn(Size size, BuildContext context) {
    return Container(
      width: double.infinity,
      height: sp(55, context),
      decoration: BoxDecoration(
        color: googleBtnBlue,
        borderRadius: BorderRadius.circular(sp(25, context)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () {
          // Implementar login con Google
        },
        borderRadius: BorderRadius.circular(sp(25, context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icono_google.png',
              height: sp(24, context),
              errorBuilder: (c, e, s) => Icon(Icons.g_mobiledata, size: sp(30, context)),
            ),
            SizedBox(width: sp(12, context)),
            Text(
              'Iniciar Sesión con Google',
              style: GoogleFonts.montserrat(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: sp(14, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Usando rutas en español consistentes con HEAD
            Navigator.pushNamed(context, '/registro'); 
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.montserrat(
                color: Colors.black87,
                fontSize: sp(14, context),
              ),
              children: [
                const TextSpan(text: '¿No tienes cuenta? '),
                TextSpan(
                  text: 'Regístrate',
                  style: GoogleFonts.montserrat(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sp(15, context)),
        GestureDetector(
          onTap: () {
             Navigator.pushNamed(context, '/olvide_contrasena');
          },
          child: Text(
            'Olvidé mi contraseña',
            style: GoogleFonts.montserrat(
              color: forgotPasswordRed,
              fontSize: sp(13, context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ================== LOGIN LOGIC ==================

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

      if (errorMsg.contains('Debes verificar tu correo antes de iniciar sesión.')) {
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