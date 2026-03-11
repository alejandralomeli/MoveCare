import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth/auth_service.dart';
import '../app_theme.dart';

class ConfirmarCorreoScreen extends StatefulWidget {
  const ConfirmarCorreoScreen({super.key});

  @override
  State<ConfirmarCorreoScreen> createState() => _ConfirmarCorreoScreenState();
}

class _ConfirmarCorreoScreenState extends State<ConfirmarCorreoScreen> {
  final TextEditingController _uidController = TextEditingController();
  bool _loading = false;

  Future<void> _confirmarCorreo() async {
    if (_uidController.text.trim().isEmpty) {
      _showMessage('Ingresa el UID que te enviamos por correo');
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.confirmarCorreo(_uidController.text.trim());
    setState(() => _loading = false);

    if (!mounted) return;

    if (result["ok"]) {
      _showMessage(result["mensaje"]);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/iniciar_sesion');
      });
    } else {
      _showMessage(result["error"]);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.032),
                    _buildLogo(size),
                    SizedBox(height: size.height * 0.025),

                    Text(
                      'Confirmar correo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ingresa la clave de validación que\nenviamos a tu bandeja de entrada',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: size.height * 0.035),

                    // UID field
                    TextField(
                      controller: _uidController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Clave de validación',
                        prefixIcon: Icon(Icons.key_rounded),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmarCorreo,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Confirmar registro'),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildResendFooter(),
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
            errorBuilder: (c, e, s) => Icon(
              Icons.local_hospital_rounded,
              size: logoSize * 0.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendFooter() {
    return Column(
      children: [
        Text(
          '¿No recibiste el código?',
          style: GoogleFonts.montserrat(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Reenviar código',
            style: GoogleFonts.montserrat(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
