import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth/auth_service.dart';
import '../app_theme.dart';

class RegistroConductor extends StatefulWidget {
  const RegistroConductor({super.key});

  @override
  State<RegistroConductor> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<RegistroConductor> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
    if (mounted) Navigator.pop(context);
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: Text('Elegir de Fototeca',
                  style: GoogleFonts.montserrat(fontSize: 14)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: Text('Tomar Foto',
                  style: GoogleFonts.montserrat(fontSize: 14)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
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
                      colors: [Color(0x55000000), Color(0x00000000)],
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

          // Profile photo picker
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imageFile == null
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset('assets/movecare.png',
                                  fit: BoxFit.contain),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: AppColors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // White bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.70,
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 28),
                    Text(
                      'Crear cuenta de Conductor',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completa tu información para continuar',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildField(
                        controller: _nombreController,
                        hint: 'Nombre completo',
                        icon: Icons.person_outline_rounded),
                    _buildField(
                        controller: _correoController,
                        hint: 'Correo electrónico',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress),
                    _buildField(
                        controller: _telefonoController,
                        hint: 'Teléfono de contacto',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    _buildField(
                        controller: _direccionController,
                        hint: 'Dirección particular',
                        icon: Icons.home_outlined),
                    _buildPasswordField(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      isObscured: _obscurePass,
                      onToggle: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Confirmar contraseña',
                      isObscured: _obscureConfirmPass,
                      onToggle: () => setState(
                          () => _obscureConfirmPass = !_obscureConfirmPass),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registerDriver,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Continuar con mi registro'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildFooter(context),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(
            fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: GoogleFonts.montserrat(
            fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/iniciar_sesion'),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.montserrat(
              color: AppColors.textSecondary, fontSize: 13),
          children: [
            const TextSpan(text: '¿Ya tienes cuenta? '),
            TextSpan(
              text: 'Inicia Sesión',
              style: GoogleFonts.montserrat(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerDriver() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Las contraseñas no coinciden');
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.registerDriver(
      nombreCompleto: _nombreController.text,
      correo: _correoController.text,
      telefono: _telefonoController.text,
      password: _passwordController.text,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (result["ok"]) {
      Navigator.pushNamed(context, '/continue_driver_register_screen',
          arguments: result["id_usuario"]);
    } else {
      _showMessage(result["error"]);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
