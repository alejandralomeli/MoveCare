import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../services/auth/auth_service.dart'; // Ajusta la ruta a tu service
import 'nueva_contrasena.dart'; // Ajusta la ruta a tu vista

class OlvideContrasena extends StatefulWidget {
  const OlvideContrasena({super.key});

  @override
  State<OlvideContrasena> createState() => _OlvideContrasenaState();
}

class _OlvideContrasenaState extends State<OlvideContrasena> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  double sp(double size, double sw) => sw * (size / 375);

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
      ),
    );
  }

  Future<void> _solicitarCodigo() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _mostrarMensaje("Por favor, ingresa tu correo electrónico", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.solicitarRecuperacion(email);

    setState(() => _isLoading = false);

    if (result['ok']) {
      _mostrarMensaje("Código enviado a tu correo");
      _mostrarModalValidacion(email);
    } else {
      _mostrarMensaje(result['error'] ?? "Hubo un error", isError: true);
    }
  }

  void _mostrarModalValidacion(String email) {
    final TextEditingController codigoController = TextEditingController();
    bool isValidating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 28,
                right: 28,
                top: 30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingresa el código',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hemos enviado un código de 4 dígitos a\n$email',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
                    decoration: const InputDecoration(
                      hintText: '0000',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isValidating
                          ? null
                          : () async {
                              final codigo = codigoController.text.trim();
                              if (codigo.length != 4) {
                                _mostrarMensaje("El código debe tener 4 dígitos", isError: true);
                                return;
                              }

                              setModalState(() => isValidating = true);

                              final result = await AuthService.validarCodigoRecuperacion(email, codigo);

                              setModalState(() => isValidating = false);

                              if (result['ok']) {
                                Navigator.pop(context); // Cerramos el modal
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NuevaContrasena(email: email, codigo: codigo),
                                  ),
                                );
                              } else {
                                _mostrarMensaje(result['error'] ?? "Código inválido", isError: true);
                              }
                            },
                      child: isValidating
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Validar Código'),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
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
                    Text('¿Olvidaste tu contraseña?', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text('Ingresa tu correo para recibir\nun código de recuperación', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(height: size.height * 0.035),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline_rounded)),
                    ),
                    SizedBox(height: size.height * 0.03),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _solicitarCodigo,
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Enviar código'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 13),
                          children: [
                            const TextSpan(text: '¿Recuerdas tu contraseña? '),
                            TextSpan(text: 'Inicia sesión', style: GoogleFonts.montserrat(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
}