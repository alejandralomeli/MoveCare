import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViajeDetallesModal extends StatelessWidget {
  final Map<String, dynamic> viaje;

  const ViajeDetallesModal({super.key, required this.viaje});

  // Reutilizamos los colores de tu app
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlueBg = Color(0xFFE3F2FD);

  TextStyle mExtrabold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle mRegular({Color color = Colors.black87, double size = 13}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w500,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formateo básico de la fecha (puedes ajustarlo si usas intl)
    DateTime fecha = DateTime.parse(viaje['fecha_hora_inicio']);
    String fechaStr = "${fecha.day}/${fecha.month}/${fecha.year} a las ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

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
            
            Text("Detalles de tu viaje", style: mExtrabold(size: 22, color: darkBlue)),
            const SizedBox(height: 25),

            // Sección: Conductor y Vehículo
            _buildSection(
              icon: Icons.person_pin,
              title: "Conductor",
              content: viaje['nombre_conductor'] ?? 'Buscando conductor...',
            ),
            const Divider(height: 30, color: lightBlueBg, thickness: 2),

            _buildSection(
              icon: Icons.directions_car,
              title: "Vehículo",
              content: "${viaje['vehiculo_marca']} ${viaje['vehiculo_modelo']} - ${viaje['vehiculo_color']}\nPlacas: ${viaje['vehiculo_placas']}",
            ),
            const Divider(height: 30, color: lightBlueBg, thickness: 2),

            // Sección: Ruta
            _buildSection(
              icon: Icons.my_location,
              title: "Punto de partida",
              content: viaje['punto_inicio'] ?? 'Ubicación actual',
            ),
            const SizedBox(height: 15),
            _buildSection(
              icon: Icons.location_on,
              title: "Destino",
              content: viaje['destino'] ?? 'Múltiples destinos',
            ),
            const Divider(height: 30, color: lightBlueBg, thickness: 2),

            // Sección: Fecha y Estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSection(
                    icon: Icons.calendar_month,
                    title: "Fecha agendada",
                    content: fechaStr,
                  ),
                ),
                Expanded(
                  child: _buildSection(
                    icon: Icons.info_outline,
                    title: "Estado",
                    content: viaje['estado'],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Botón para cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text("Cerrar", style: mExtrabold(color: Colors.white, size: 16)),
              ),
            ),
            // Espacio extra por si el modal se abre sobre el notch inferior de iOS/Android
            const SizedBox(height: 10), 
          ],
        ),
      ),
    );
  }

  // Helper para pintar cada fila con su ícono
  Widget _buildSection({required IconData icon, required String title, required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryBlue, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: mExtrabold(size: 14, color: Colors.grey[700]!)),
              const SizedBox(height: 4),
              Text(content, style: mRegular(size: 15)),
            ],
          ),
        ),
      ],
    );
  }
}