import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacidadVista extends StatelessWidget {
  const PrivacidadVista({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);

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

  TextStyle mNormal({double size = 14, required BuildContext context}) {
    return GoogleFonts.montserrat(
      color: Colors.black87,
      fontSize: sp(size, context),
      height: 1.6,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 120,
            width: double.infinity,
            color: lightBlueBg,
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Text(
                      'Aviso de Privacidad',
                      style: GoogleFonts.montserrat(fontSize: sp(18, context), fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Última actualización: Febrero 2026", style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  
                  Text("1. Información que Recopilamos", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("Para brindar nuestros servicios, MoveCare recopila información personal como: nombre, dirección de correo electrónico, número de teléfono, ubicación geográfica (GPS) en tiempo real, e información básica sobre necesidades de movilidad para asegurar un vehículo adecuado.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("2. Uso de la Información", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("Utilizamos su información para:\n• Conectar pasajeros con conductores.\n• Procesar pagos de manera segura.\n• Mejorar la seguridad y confiabilidad de nuestra plataforma.\n• Brindar soporte al cliente y notificaciones sobre sus viajes.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("3. Protección de Datos Sensibles", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("En MoveCare tomamos la privacidad médica muy en serio. Cualquier información relacionada con sus necesidades de movilidad se comparte estrictamente con el conductor asignado para fines logísticos del viaje, cumpliendo con los estándares de seguridad aplicables.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("4. Compartir Información", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("No vendemos ni alquilamos su información personal a terceros. Podemos compartir datos con proveedores de servicios (como pasarelas de pago) o si es requerido por ley o autoridades competentes.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("5. Sus Derechos", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("Usted tiene derecho a acceder, rectificar, cancelar u oponerse al tratamiento de sus datos personales. Para ejercer estos derechos, puede contactar a nuestro equipo de soporte a través de la aplicación.", style: mNormal(context: context)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}