import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GestionUsuarios extends StatefulWidget {
  const GestionUsuarios({super.key});

  @override
  State<GestionUsuarios> createState() => _GestionUsuariosState();
}

class _GestionUsuariosState extends State<GestionUsuarios> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color buttonLightBlue = Color(0xFF64A1F4);

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

  void _mostrarDialogoRechazo(String usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rechazar a $usuario', style: mExtrabold(size: 18, context: context, color: primaryBlue)),
        content: TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Motivo del rechazo...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: primaryBlue)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: statusRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context),
            child: Text('Confirmar', style: mExtrabold(color: Colors.white, size: 12, context: context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              height: 135,
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
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                        'Gestión de Usuarios',
                        style: GoogleFonts.montserrat(fontSize: sp(20, context), fontWeight: FontWeight.w900, color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TabBar(
                      indicatorColor: primaryBlue,
                      labelColor: primaryBlue,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: mExtrabold(size: 13, context: context),
                      tabs: const [Tab(text: 'Conductores'), Tab(text: 'Pasajeros')],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(context, sw, 'Conductor'),
                  _buildList(context, sw, 'Pasajero'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, double sw, String tipo) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: cardBlue, borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryBlue.withOpacity(0.1))),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white, child: Icon(tipo == 'Conductor' ? Icons.directions_car : Icons.person, color: primaryBlue)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$tipo #${index + 1}', style: mExtrabold(size: 15, context: context)),
                      Text('Ver documentos pendientes', style: GoogleFonts.montserrat(fontSize: sp(11, context))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: primaryBlue),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                _btn('Rechazar', Colors.white, statusRed, context, () => _mostrarDialogoRechazo('$tipo #${index + 1}')),
                const SizedBox(width: 10),
                _btn('Aceptar', primaryBlue, Colors.white, context, () {}),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color bg, Color txt, BuildContext context, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: bg, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: bg == Colors.white ? const BorderSide(color: statusRed) : BorderSide.none)),
        child: Text(label, style: mExtrabold(color: txt, size: 11, context: context)),
      ),
    );
  }
}