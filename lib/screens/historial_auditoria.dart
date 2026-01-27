import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialAuditoria extends StatelessWidget {
  const HistorialAuditoria({super.key});
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Historial de Staff', 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryBlue,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: fieldBlue,
            child: Text(
              'Registro de actividades administrativas',
              style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 15,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryBlue.withOpacity(0.1),
                  child: const Icon(Icons.admin_panel_settings, color: primaryBlue, size: 20),
                ),
                title: RichText(
                  text: TextSpan(
                    style: GoogleFonts.montserrat(color: Colors.black, fontSize: 13),
                    children: [
                      const TextSpan(text: 'Admin_Juan ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: index % 2 == 0 ? 'aceptó a ' : 'rechazó a '),
                      TextSpan(text: 'Usuario_$index', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                    ],
                  ),
                ),
                subtitle: Text('25 Oct 2025 - 10:45 AM', style: GoogleFonts.montserrat(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}