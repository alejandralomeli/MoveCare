import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
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
            height: size.height * 0.4,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),

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

                    _buildTextField('Nombre', Colors.blue.shade800, _nombreCtrl),
                    _buildTextField('Correo electrónico', Colors.blue.shade400, _correoCtrl),
                    _buildTextField('Teléfono de contacto', Colors.blue.shade800, _telefonoCtrl),

                    _buildPasswordField(
                      'Contraseña',
                      Colors.blue.shade400,
                      _passwordCtrl,
                      _obscurePass,
                      () => setState(() => _obscurePass = !_obscurePass),
                    ),

                    _buildPasswordField(
                      'Confirmación de contraseña',
                      Colors.blue.shade800,
                      _confirmCtrl,
                      _obscureConfirmPass,
                      () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: size.width * 0.7,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
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

  Widget _buildTextField(String label, Color color, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: fieldBlue, borderRadius: BorderRadius.circular(20)),
        child: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.w600),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: color, radius: 10),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    Color color,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: fieldBlue, borderRadius: BorderRadius.circular(20)),
        child: TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.w600),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: color, radius: 10),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: primaryBlue),
              onPressed: toggle,
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
      _alert(
        'Registro exitoso',
        'Revisa tu correo para verificar tu cuenta',
      );
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
        ],
      ),
    );
  }
}
