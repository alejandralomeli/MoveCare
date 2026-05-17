import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../services/auth/auth_service.dart'; // Ajusta la ruta a tu service

class NuevaContrasena extends StatefulWidget {
  final String email;
  final String codigo;

  const NuevaContrasena({
    super.key,
    required this.email,
    required this.codigo,
  });

  @override
  State<NuevaContrasena> createState() => _NuevaContrasenaState();
}

class _NuevaContrasenaState extends State<NuevaContrasena> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
      ),
    );
  }

  Future<void> _cambiarContrasena() async {
    final pass = _passController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (pass.isEmpty || confirmPass.isEmpty) {
      _mostrarMensaje("Por favor, llena ambos campos", isError: true);
      return;
    }

    if (pass.length < 6) {
      _mostrarMensaje("La contraseña debe tener al menos 6 caracteres", isError: true);
      return;
    }

    if (pass != confirmPass) {
      _mostrarMensaje("Las contraseñas no coinciden", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.cambiarPassword(widget.email, widget.codigo, pass);

    setState(() => _isLoading = false);

    if (result['ok']) {
      _mostrarMensaje("¡Contraseña actualizada exitosamente!");
      // Ajusta la ruta dependiendo de cómo se llame tu vista de login en el main.dart
      Navigator.pushNamedAndRemoveUntil(context, '/iniciar_sesion', (route) => false);
    } else {
      _mostrarMensaje(result['error'] ?? "Hubo un error al cambiar la contraseña", isError: true);
    }
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
            top: 0, left: 0, right: 0, height: size.height * 0.36,
            child: Stack(
              children: [
                Image.asset('assets/ruta.png', width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: AppColors.primaryLight)),
                Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40000000), Color(0x00000000)]))),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.032),
                    _buildLogo(size),
                    SizedBox(height: size.height * 0.025),
                    Text('Nueva Contraseña', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text('Por favor ingresa tu nueva contraseña', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(height: size.height * 0.03),

                    _buildPasswordField(
                      controller: _passController,
                      label: 'Nueva contraseña',
                      isObscured: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordField(
                      controller: _confirmPassController,
                      label: 'Confirmar nueva contraseña',
                      isObscured: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    SizedBox(height: size.height * 0.04),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _cambiarContrasena,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                            : const Text('Confirmar contraseña'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
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
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/movecare.png', fit: BoxFit.contain, errorBuilder: (c, e, s) => Icon(Icons.local_hospital_rounded, size: logoSize * 0.5, color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
