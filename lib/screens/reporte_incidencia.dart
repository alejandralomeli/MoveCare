import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReporteIncidencia extends StatelessWidget {
  const ReporteIncidencia({super.key});
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color statusRed = Color(0xFFEF5350);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bandeja de Reportes', 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: ExpansionTile(
            leading: const Icon(Icons.warning_amber_rounded, color: statusRed),
            title: Text('Reporte de Incidencia #$index', 
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Fecha: 24/10/2025', style: GoogleFonts.montserrat(fontSize: 11)),
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    const Text('El usuario reporta que el vehículo no contaba con la rampa hidráulica mencionada en el perfil.'),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Descartar', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: statusRed),
                          onPressed: () {},
                          child: const Text('Bloquear Usuario', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}