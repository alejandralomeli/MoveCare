import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialAuditoria extends StatelessWidget {
  const HistorialAuditoria({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 14, required BuildContext context}) {
    return GoogleFonts.montserrat(color: color, fontSize: sp(size, context), fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            color: lightBlueBg,
            child: Stack(
              children: [
                Positioned(
                  top: 35,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      'Historial de Movimientos',
                      style: GoogleFonts.montserrat(
                        fontSize: sp(18, context), 
                        fontWeight: FontWeight.w900, 
                        color: Colors.black, // Color negro según tu cambio
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                // Alternamos para el ejemplo entre Pasajero y Conductor
                String tipoUsuario = index % 2 == 0 ? 'Conductor' : 'Pasajero';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryBlue.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      // Icono de historial como el del menú
                      const Icon(Icons.history, color: primaryBlue),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(color: Colors.black, fontSize: sp(12, context)),
                                children: [
                                  const TextSpan(text: 'Admin_Carlos ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: index % 2 == 0 ? 'aprobó a ' : 'rechazó a '),
                                  TextSpan(
                                    text: '$tipoUsuario ', 
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)
                                  ),
                                  TextSpan(
                                    text: 'Usuario_$index', 
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Fecha y hora con letra más negrita
                            Text(
                              '28/01/2026 - 14:30 PM', 
                              style: GoogleFonts.montserrat(
                                fontSize: sp(10, context), 
                                color: Colors.black87,
                                fontWeight: FontWeight.w700, // Letra más negrita para fecha
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}