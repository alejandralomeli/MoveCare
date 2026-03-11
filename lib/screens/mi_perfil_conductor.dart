import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class MiPerfilConductor extends StatefulWidget {
  const MiPerfilConductor({super.key});

  @override
  State<MiPerfilConductor> createState() => MiPerfilConductorState();
}

class MiPerfilConductorState extends State<MiPerfilConductor> {
  bool _isListening = false;

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

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: AppColors.white.withValues(alpha: 0.1)),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sp(15, sw), vertical: sp(15, sw)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      MicButton(
                        isActive: _isListening,
                        onTap: () => setState(() => _isListening = !_isListening),
                        size: 52,
                      ),
                    ],
                  ),
                ),

                _buildProfileHeader(sw),

                SizedBox(height: sp(30, sw)),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sp(25, sw)),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: sp(20, sw)),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildMenuOption('Mi Historial', () => print("Historial"), sw),
                            _buildDivider(),
                            _buildMenuOption('Notificaciones', () => print("Notificaciones"), sw),
                            _buildDivider(),
                            _buildMenuOption('Configuración de Perfil', () => print("Configuración"), sw),
                            _buildDivider(),
                            _buildMenuOption('Mis Métricas', () => print("Métricas"), sw),
                            _buildDivider(),
                            _buildMenuOption('Privacidad', () => print("Privacidad"), sw),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildProfileHeader(double sw) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: sp(65, sw),
                backgroundColor: AppColors.primaryLight,
                backgroundImage: const AssetImage('assets/conductor.png'),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: AppColors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp(12, sw)),
        Text('Username', style: GoogleFonts.montserrat(fontSize: sp(22, sw), fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: sp(20, sw))),
            Text(' 5.00', style: mBold(color: AppColors.primary, size: 14, sw: sw)),
          ],
        ),
        SizedBox(height: sp(8, sw)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sp(12, sw), vertical: sp(4, sw)),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.white, size: sp(16, sw)),
              SizedBox(width: sp(6, sw)),
              Text('Verificado', style: mBold(color: AppColors.white, size: 12, sw: sw)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(String title, VoidCallback onTap, double sw) {
    return ListTile(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.2),
      contentPadding: EdgeInsets.symmetric(horizontal: sp(30, sw), vertical: sp(5, sw)),
      title: Text(title, style: GoogleFonts.montserrat(fontSize: sp(15, sw), fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary, size: sp(20, sw)),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1.5,
      indent: 20,
      endIndent: 20,
      color: AppColors.border,
    );
  }

}
