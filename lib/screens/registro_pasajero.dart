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

  // Controladores funcionales (HEAD)
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _loading = false;

  // Función de escalado responsivo (main)
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagen de fondo superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),

          // Botón de retroceso (main)
          Positioned(
            top: MediaQuery.of(context).padding.top + sp(15, context),
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

          // Logo flotante (main)
          Positioned(
            top: size.height * 0.10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: sp(90, context),
                height: sp(90, context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sp(25, context)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(sp(10, context)),
                  child: Image.asset('assets/movecare.png'),
                ),
              ),
            ),
          ),

          // Contenedor de Formulario
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
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sp(30, context)),
                child: Column(
                  children: [
                    SizedBox(height: sp(30, context)),
                    Text(
                      'Crea una cuenta de Pasajero',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(18, context),
                      ),
                    ),
                    SizedBox(height: sp(20, context)),

                    // Campos de texto con controladores
                    _buildTextField(
                      context,
                      label: 'Nombre',
                      iconColor: Colors.blue.shade800,
                      ctrl: _nombreCtrl,
                    ),
                    _buildTextField(
                      context,
                      label: 'Correo electrónico',
                      iconColor: Colors.blue.shade400,
                      ctrl: _correoCtrl,
                    ),
                    _buildTextField(
                      context,
                      label: 'Teléfono de contacto',
                      iconColor: Colors.blue.shade800,
                      ctrl: _telefonoCtrl,
                    ),

                    _buildPasswordField(
                      context: context,
                      label: 'Contraseña',
                      iconColor: Colors.blue.shade400,
                      ctrl: _passwordCtrl,
                      isObscured: _obscurePass,
                      onToggle: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),

                    _buildPasswordField(
                      context: context,
                      label: 'Confirmación de contraseña',
                      iconColor: Colors.blue.shade800,
                      ctrl: _confirmCtrl,
                      isObscured: _obscureConfirmPass,
                      onToggle: () => setState(
                        () => _obscureConfirmPass = !_obscureConfirmPass,
                      ),
                    ),

                    SizedBox(height: sp(25, context)),

                    // Botón de Registro con lógica de carga
                    SizedBox(
                      width: size.width * 0.7,
                      height: sp(50, context),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              sp(25, context),
                            ),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Registrarme',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: sp(15, context),
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: sp(20, context)),
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

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required Color iconColor,
    required TextEditingController ctrl,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(12, context)),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(sp(20, context)),
        ),
        child: TextField(
          controller: ctrl,
          style: GoogleFonts.montserrat(fontSize: sp(14, context)),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue,
              fontSize: sp(14, context),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(sp(12, context)),
              child: CircleAvatar(
                backgroundColor: iconColor,
                radius: sp(10, context),
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: sp(15, context)),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required Color iconColor,
    required TextEditingController ctrl,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(12, context)),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(sp(20, context)),
        ),
        child: TextField(
          controller: ctrl,
          obscureText: isObscured,
          style: GoogleFonts.montserrat(fontSize: sp(14, context)),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue,
              fontSize: sp(14, context),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(sp(12, context)),
              child: CircleAvatar(
                backgroundColor: iconColor,
                radius: sp(10, context),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: primaryBlue,
                size: sp(20, context),
              ),
              onPressed: onToggle,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: sp(15, context)),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: GoogleFonts.montserrat(fontSize: sp(13, context)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/iniciar_sesion'),
          child: Text(
            'Inicia Sesión',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: sp(13, context),
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
        'Tu cuenta ha sido creada. Ahora puedes iniciar sesión.',
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
