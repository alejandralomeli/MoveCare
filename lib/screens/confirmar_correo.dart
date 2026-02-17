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
  static const Color fieldBlue = Color(0xFFD6E8FF);
  static const Color lightBlueBtn = Color(0xFFADCFFF);

  Future<void> _confirmarCorreo() async {
    if (_uidController.text.trim().isEmpty) {
      _showMessage('Ingresa el UID que te enviamos por correo');
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.confirmarCorreo(_uidController.text.trim());
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sw = size.width;
    
    double sp(double pixels) => sw * (pixels / 375);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.40,
            child: Image.asset(
              'assets/ruta.png', // Asegúrate que este asset existe
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + sp(10),
            left: sp(10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, 
                color: primaryBlue, 
                size: sp(22), 
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.72, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sp(50)),
                  topRight: Radius.circular(sp(50)),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                ]
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sp(30)),
                child: Column(
                  children: [
                    SizedBox(height: sp(35)),

                    _buildLogo(sp),

                    SizedBox(height: sp(25)),

                    Text(
                      'Confirmar correo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: sp(24),
                      ),
                    ),

                    SizedBox(height: sp(15)),

                    Text(
                      'Ingresa la clave de validación que enviamos a tu bandeja de entrada',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: sp(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: sp(35)),

                    TextField(
                      controller: _uidController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: sp(18),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Clave de validación',
                        labelStyle: TextStyle(color: primaryBlue.withOpacity(0.6)),
                        filled: true,
                        fillColor: fieldBlue.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sp(20)),
                          borderSide: const BorderSide(color: primaryBlue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(sp(20)),
                          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
                        ),
                      ),
                    ),

                    SizedBox(height: sp(40)),

                    SizedBox(
                      width: sw * 0.8,
                      height: sp(55),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmarCorreo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightBlueBtn,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: primaryBlue)
                            : Text(
                                'Confirmar registro',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w900,
                                  fontSize: sp(16),
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: sp(30)),
                    
                    _buildResendFooter(sp),
                    SizedBox(height: sp(30)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double Function(double) sp) {
    return Center(
      child: Container(
        width: sp(85), 
        height: sp(85),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(sp(22)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Padding(
          padding: EdgeInsets.all(sp(15)),
          child: Image.asset('assets/movecare.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildResendFooter(double Function(double) sp) {
    return Column(
      children: [
        Text(
          '¿No recibiste el código?',
          style: GoogleFonts.montserrat(
            color: Colors.black54,
            fontSize: sp(13),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Reenviar código',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: sp(14),
            ),
          ),
        ),
      ],
    );
  }
}