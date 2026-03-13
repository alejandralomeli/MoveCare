import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class GestionUsuarios extends StatefulWidget {
  const GestionUsuarios({super.key});

  @override
  State<GestionUsuarios> createState() => _GestionUsuariosState();
}

class _GestionUsuariosState extends State<GestionUsuarios> {
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
        title: Text('Rechazar a $usuario', style: mExtrabold(size: 18, context: context, color: AppColors.primary)),
        content: TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Motivo del rechazo...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context),
            child: Text('Confirmar', style: mExtrabold(color: AppColors.white, size: 12, context: context)),
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
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Container(
              height: 80,
              width: double.infinity,
              color: AppColors.primaryLight,
              child: Stack(
                children: [
                  Positioned(
                    top: 35,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                        'Gestión de Usuarios',
                        style: GoogleFonts.montserrat(fontSize: sp(20, context), fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TabBar(
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.white, child: Icon(tipo == 'Conductor' ? Icons.directions_car : Icons.person, color: AppColors.primary)),
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
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
              ],
            ),
            const Divider(height: 25),
            Row(
              children: [
                _btn('Rechazar', AppColors.white, AppColors.error, context, () => _mostrarDialogoRechazo('$tipo #${index + 1}')),
                const SizedBox(width: 10),
                _btn('Aceptar', AppColors.primary, AppColors.white, context, () {}),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: bg == AppColors.white ? BorderSide(color: AppColors.error) : BorderSide.none,
          ),
        ),
        child: Text(label, style: mExtrabold(color: txt, size: 11, context: context)),
      ),
    );
  }
}
