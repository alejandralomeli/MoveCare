import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth/auth_service.dart';

class RegistroConductor extends StatefulWidget {
  const RegistroConductor({super.key});

  @override
  State<RegistroConductor> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<RegistroConductor> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  // Controladores y estados de lógica (HEAD)
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  // Función de escalado responsivo (main)
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    return sw * (size / 375);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagen de fondo superior (main height)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),

          // Botón de retroceso
          Positioned(
            top: MediaQuery.of(context).padding.top + 35,
            left: 15,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: primaryBlue,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Logo MoveCare con sombra mejorada (main)
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: sp(100, context),
                height: sp(100, context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/movecare.png'),
                ),
              ),
            ),
          ),

          // Formulario con bordes redondeados
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
                      'Crea una cuenta de Conductor',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(18, context),
                      ),
                    ),
                    SizedBox(height: sp(25, context)),

                    // Campos de texto vinculados a controladores
                    _buildTextField(
                      context,
                      label: 'Nombre',
                      iconColor: Colors.blue.shade800,
                      controller: _nombreController,
                    ),
                    _buildTextField(
                      context,
                      label: 'Correo electrónico',
                      iconColor: Colors.blue.shade400,
                      controller: _correoController,
                    ),
                    _buildTextField(
                      context,
                      label: 'Teléfono de contacto',
                      iconColor: Colors.blue.shade800,
                      controller: _telefonoController,
                    ),

                    _buildTextField(
                      context,
                      label: 'Contraseña',
                      iconColor: Colors.blue.shade400,
                      isPassword: true,
                      controller: _passwordController,
                      obscure: _obscurePass,
                      onToggle: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),

                    _buildTextField(
                      context,
                      label: 'Confirmación de contraseña',
                      iconColor: Colors.blue.shade800,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirmPass,
                      onToggle: () => setState(
                        () => _obscureConfirmPass = !_obscureConfirmPass,
                      ),
                    ),

                    SizedBox(height: sp(25, context)),

                    // Botón de acción con estado Loading
                    SizedBox(
                      width: sw * 0.75,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registerDriver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Continuar con mi registro',
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

  // Lógica de registro (HEAD)
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

    if (result["ok"]) {
      Navigator.pushNamed(
        context,
        '/continue_driver_register_screen',
        arguments: result["id_usuario"],
      );
    } else {
      _showMessage(result["error"]);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Widget unificado de TextField
  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required Color iconColor,
    required TextEditingController controller,
    bool isPassword = false,
    bool? obscure,
    VoidCallback? onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? (obscure ?? true) : false,
          style: GoogleFonts.montserrat(
            fontSize: sp(14, context),
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue.withOpacity(0.7),
              fontSize: sp(13, context),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(backgroundColor: iconColor, radius: 8),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure! ? Icons.visibility_off : Icons.visibility,
                      color: primaryBlue,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
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
}
