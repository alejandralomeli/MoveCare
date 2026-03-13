import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalizarViajeBottomSheet extends StatelessWidget {
  const FinalizarViajeBottomSheet({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Viaje Finalizado", style: mBold(size: 20, sw: sw)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra bottom sheet
              Navigator.pop(context); // Regresa al mapa/home principal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              minimumSize: Size(sw * 0.8, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("Aceptar y Salir", style: mBold(color: Colors.white, size: 16, sw: sw)),
          )
        ],
      ),
    );
  }
}