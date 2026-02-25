import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminosVista extends StatelessWidget {
  const TerminosVista({super.key});

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
                      'Términos y Condiciones',
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
                  
                  Text("1. Aceptación de los Términos", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("Al descargar, instalar o utilizar la aplicación MoveCare, usted acepta estar sujeto a estos Términos y Condiciones. Si no está de acuerdo con alguna parte de los términos, no podrá utilizar nuestros servicios.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("2. Descripción del Servicio", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("MoveCare es una plataforma tecnológica que facilita la conexión entre usuarios que requieren asistencia de movilidad médica no de emergencia (pasajeros) y conductores independientes registrados en la plataforma.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("3. Responsabilidades del Usuario", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("• Proveer información precisa y verídica durante el registro.\n• Mantener la confidencialidad de sus credenciales de acceso.\n• Tratar con respeto a los conductores y personal médico de apoyo.\n• Pagar las tarifas correspondientes por los servicios solicitados.", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("4. Limitación de Responsabilidad", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("MoveCare no proporciona servicios médicos ni actúa como proveedor de atención médica. Los conductores son contratistas independientes. MoveCare no se hace responsable por emergencias médicas que ocurran durante el traslado; en caso de emergencia, el usuario debe contactar a los servicios de emergencia locales (ej. 911).", style: mNormal(context: context)),
                  const SizedBox(height: 20),

                  Text("5. Pagos y Cancelaciones", style: mExtrabold(context: context, size: 16, color: primaryBlue)),
                  const SizedBox(height: 10),
                  Text("Los pagos se procesan a través de proveedores de servicios de pago de terceros. MoveCare se reserva el derecho de aplicar cargos por cancelación si un viaje es cancelado después de que un conductor ha sido asignado y está en camino.", style: mNormal(context: context)),
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