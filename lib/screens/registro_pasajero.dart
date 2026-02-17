import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth/auth_service.dart';

class RegistroPasajero extends StatefulWidget {
  const RegistroPasajero({super.key});

  @override
  State<RegistroPasajero> createState() => _RegistroPasajeroState();
}

class _RegistroPasajeroState extends State<RegistroPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController(); 
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _loading = false;
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
              leading: const Icon(Icons.photo_library, color: primaryBlue),
              title: const Text('Fototeca'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: primaryBlue),
              title: const Text('Cámara'),
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
    final sw = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: size.height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Stack(
                  children: [
                    Container(
                      width: sp(110, context), 
                      height: sp(110, context),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                        ],
                        image: _imageFile != null 
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _imageFile == null 
                        ? Padding(
                            padding: const EdgeInsets.all(15),
                            child: Image.asset('assets/movecare.png'),
                          )
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: primaryBlue,
                        radius: 18,
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.68,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08), 
                child: Column(
                  children: [
                    SizedBox(height: sp(35, context)), 
                    Text(
                      'Crea una cuenta de Pasajero',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(18, context),
                      ),
                    ),
                    SizedBox(height: sp(25, context)), 

                    _buildTextField(context, label: 'Nombre', iconColor: Colors.blue.shade800, ctrl: _nombreCtrl),
                    _buildTextField(context, label: 'Correo electrónico', iconColor: Colors.blue.shade400, ctrl: _correoCtrl),
                    _buildTextField(context, label: 'Teléfono de contacto', iconColor: Colors.blue.shade800, ctrl: _telefonoCtrl),
                    _buildTextField(context, label: 'Dirección particular', iconColor: Colors.blue.shade400, ctrl: _direccionCtrl),

                    _buildPasswordField(
                      context: context,
                      label: 'Contraseña',
                      iconColor: Colors.blue.shade800,
                      ctrl: _passwordCtrl,
                      isObscured: _obscurePass,
                      onToggle: () => setState(() => _obscurePass = !_obscurePass),
                    ),

                    _buildPasswordField(
                      context: context,
                      label: 'Confirmación de contraseña',
                      iconColor: Colors.blue.shade400,
                      ctrl: _confirmCtrl,
                      isObscured: _obscureConfirmPass,
                      onToggle: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                    ),

                    SizedBox(height: sp(25, context)),

                    SizedBox(
                      width: sw * 0.75,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Registrarme',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: sp(14, context), 
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
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

  Widget _buildTextField(BuildContext context, {required String label, required Color iconColor, required TextEditingController ctrl}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: fieldBlue, borderRadius: BorderRadius.circular(20)),
        child: TextField(
          controller: ctrl,
          style: GoogleFonts.montserrat(fontSize: sp(14, context), color: Colors.black87),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue.withOpacity(0.7), 
              fontSize: sp(13, context), 
              fontWeight: FontWeight.w600
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: iconColor, radius: 8),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18), 
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required BuildContext context, required String label, required Color iconColor, required TextEditingController ctrl, required bool isObscured, required VoidCallback onToggle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: fieldBlue, borderRadius: BorderRadius.circular(20)),
        child: TextField(
          controller: ctrl,
          obscureText: isObscured,
          style: GoogleFonts.montserrat(fontSize: sp(14, context), color: Colors.black87),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue.withOpacity(0.7), 
              fontSize: sp(13, context), 
              fontWeight: FontWeight.w600
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: iconColor, radius: 8),
            ),
            suffixIcon: IconButton(
              icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: primaryBlue, size: 20),
              onPressed: onToggle,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿Ya tienes cuenta? ', style: GoogleFonts.montserrat(fontSize: sp(13, context))),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/iniciar_sesion'),
          child: Text('Inicia Sesión', style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: sp(13, context))),
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      _alert('Error', 'Las contraseñas no coinciden');
      return;
    }
    setState(() => _loading = true);
    final result = await AuthService.registerPassenger(
      nombreCompleto: _nombreCtrl.text,
      correo: _correoCtrl.text,
      telefono: _telefonoCtrl.text,
      password: _passwordCtrl.text,
    );
    setState(() => _loading = false);
    if (result['ok']) {
      _alert('Registro exitoso', 'Tu cuenta ha sido creada.');
    } else {
      _alert('Error', result['error'].toString());
    }
  }

  void _alert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar'))],
      ),
    );
  }
}