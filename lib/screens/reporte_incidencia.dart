import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReporteIncidencia extends StatefulWidget {
  const ReporteIncidencia({super.key});

  @override
  State<ReporteIncidencia> createState() => _ReporteIncidenciaState();
}

class _ReporteIncidenciaState extends State<ReporteIncidencia> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color buttonLightBlue = Color(0xFF64A1F4);

  // Función de escalado idéntica a tus otras vistas
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 14, required BuildContext context}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
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
                      'Bandeja de Reportes',
                      style: GoogleFonts.montserrat(
                        fontSize: sp(20, context),
                        fontWeight: FontWeight.w900,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- CUERPO ---
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) => _buildReportCard(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reporte #120$index', style: mExtrabold(size: 15, context: context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'URGENTE',
                  style: mExtrabold(color: Colors.white, size: 10, context: context),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha: 24 Octubre 2025',
            style: GoogleFonts.montserrat(fontSize: sp(12, context), fontWeight: FontWeight.w600),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: primaryBlue, thickness: 0.5),
          ),
          Text(
            'Descripción:',
            style: mExtrabold(size: 13, context: context, color: primaryBlue),
          ),
          const SizedBox(height: 5),
          Text(
            'El usuario reporta que el vehículo no contaba con la rampa hidráulica mencionada en el perfil del conductor.',
            style: GoogleFonts.montserrat(fontSize: sp(12, context)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _actionBtn('Descartar', Colors.white, Colors.black54, context),
              const SizedBox(width: 10),
              _actionBtn('Bloquear', statusRed, Colors.white, context),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bgColor, Color textColor, BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: bgColor == Colors.white ? const BorderSide(color: Colors.black26) : BorderSide.none,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          style: mExtrabold(color: textColor, size: 11, context: context),
        ),
      ),
    );
  }
}