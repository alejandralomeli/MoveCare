import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth/auth_service.dart';
import '../core/storage/secure_storage.dart';
import '../app_theme.dart';
import '../core/utils/ui_helpers.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Top image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.36,
            child: Stack(
              children: [
                Image.asset(
                  'assets/ruta.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(color: AppColors.primaryLight),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x40000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // White bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.72,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sp(28, context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.032),
                    _buildLogo(size),
                    SizedBox(height: size.height * 0.025),

                    Text(
                      'Bienvenido de vuelta',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicia sesión para continuar',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Email field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        prefixIcon:
                            const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/olvide_contrasena'),
                        child: Text(
                          '¿Olvidé mi contraseña?',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.028),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Ingresar'),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Google button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/icono_google.png',
                          height: 20,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.g_mobiledata, size: 22),
                        ),
                        label: Text(
                          'Continuar con Google',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.035),

                    // Footer
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/registro'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: '¿No tienes cuenta? '),
                            TextSpan(
                              text: 'Regístrate',
                              style: GoogleFonts.montserrat(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(Size size) {
    final logoSize = size.height * 0.11;
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/movecare.png',
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Icon(Icons.local_hospital_rounded,
                size: logoSize * 0.5, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  // =================== LOGIC ===================

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
        Navigator.pushReplacementNamed(context, '/principal_conductor');
      } else if (rol == 'administrador') {
        Navigator.pushReplacementNamed(context, '/gestion_usuarios');
      } else {
        _showAlert('Error', 'Rol no reconocido');
      }
    } else {
      final error = result['error'];
      final errorMsg = error is Map && error['detail'] != null
          ? error['detail'].toString()
          : error.toString();

      if (errorMsg.contains(
          'Debes verificar tu correo antes de iniciar sesión.')) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/confirmar-correo');
        return;
      }

      if (!mounted) return;
      _showAlert('Error de inicio de sesión', errorMsg);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        content: Text(message, style: GoogleFonts.montserrat(fontSize: 14)),
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
