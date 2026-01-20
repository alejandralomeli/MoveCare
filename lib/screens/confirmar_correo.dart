import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth/auth_service.dart';

class ConfirmarCorreoScreen extends StatefulWidget {
  const ConfirmarCorreoScreen({super.key});

  @override
  State<ConfirmarCorreoScreen> createState() => _ConfirmarCorreoScreenState();
}

class _ConfirmarCorreoScreenState extends State<ConfirmarCorreoScreen> {
  final TextEditingController _uidController = TextEditingController();
  bool _loading = false;

  static const Color primaryBlue = Color(0xFF1559B2);

  Future<void> _confirmarCorreo() async {
    if (_uidController.text.trim().isEmpty) {
      _showMessage('Ingresa el UID que te enviamos por correo');
      return;
    }

    setState(() => _loading = true);

    final result =
        await AuthService.confirmarCorreo(_uidController.text.trim());

    setState(() => _loading = false);

    if (result["ok"]) {
      _showMessage(result["mensaje"]);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/iniciar_sesion');
      });
    } else {
      _showMessage(result["error"]);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar correo'),
        backgroundColor: primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Ingresa la clave que te enviamos por correo',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _uidController,
              decoration: InputDecoration(
                labelText: 'Clave de validación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmarCorreo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Confirmar correo',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
