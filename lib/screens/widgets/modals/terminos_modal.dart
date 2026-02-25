import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../terminos_vista.dart';
import '../../privacidad_vista.dart';

class TerminosModal extends StatelessWidget {
  const TerminosModal({super.key});

  // Reutilizamos los colores de tu app
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFF0F7FF);

  TextStyle mExtrabold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de arrastre superior (la rayita gris)
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.policy, color: primaryBlue, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Términos y Privacidad",
                  style: mExtrabold(size: 20, color: primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "En MoveCare estamos comprometidos con la transparencia y el cuidado de tus datos. Conoce nuestros lineamientos:",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),

            // Opciones del modal
            _buildDocItem(
              icon: Icons.description_outlined,
              title: "Términos y Condiciones",
              onTap: () {
                // 🔥 Navegar a la vista de Términos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TerminosVista(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildDocItem(
              icon: Icons.privacy_tip_outlined,
              title: "Aviso de Privacidad",
              onTap: () {
                // 🔥 Navegar a la vista de Privacidad
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacidadVista(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Botón para cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Entendido",
                  style: mExtrabold(color: Colors.white, size: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Helper para pintar las opciones limpiamente
  Widget _buildDocItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lightBlueBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),
      title: Text(title, style: mExtrabold(size: 14, color: Colors.black87)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: primaryBlue,
      ),
      onTap: onTap,
    );
  }
}
