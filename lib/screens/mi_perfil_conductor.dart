import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth/auth_service.dart';
import '../providers/user_provider.dart';
import 'widgets/modals/terminos_modal.dart';

class MiPerfilConductor extends StatefulWidget {
  const MiPerfilConductor({super.key});

  @override
  State<MiPerfilConductor> createState() => _MiPerfilConductorState();
}

class _MiPerfilConductorState extends State<MiPerfilConductor> {
  // Paleta de colores consistente
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color navBarBg = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color statusGreen = Color(0xFF4CAF50);

  int _selectedIndex = 3;

  // Función de escalado
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({
    Color color = Colors.black,
    double size = 14,
    required BuildContext context,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    
    // 1. Obtención de datos del Provider
    final user = context.watch<UserProvider>().user;
    final String nombreUsuario = user?.nombre ?? "Conductor.";
    final bool isActivo = user?.activo ?? false;

    // 2. Manejo de imagen de perfil
    ImageProvider imagenPerfil = const AssetImage('assets/conductor.png');
    if (user != null && user.fotoPerfil.isNotEmpty) {
      try {
        String base64String = user.fotoPerfil;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        imagenPerfil = MemoryImage(base64Decode(base64String));
      } catch (e) {
        debugPrint("Error decodificando foto de conductor: $e");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- HEADER CON BANNER Y AVATAR ---
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        color: lightBlueBg,
                        child: SafeArea(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: 20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              image: imagenPerfil,
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -45,
                        left: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreUsuario,
                              style: GoogleFonts.montserrat(
                                fontSize: sp(20, context),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Badge de Estado
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActivo ? statusGreen : statusRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActivo ? Icons.check_circle : Icons.error_outline,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActivo ? "Verificado" : "Pendiente",
                                    style: mExtrabold(color: Colors.white, size: 10, context: context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  // --- LISTA DE OPCIONES ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: Column(
                      children: [
                        _profileItem(
                          Icons.person,
                          "Información de Conductor",
                          context,
                          onTap: () => Navigator.pushNamed(context, '/completar_perfil_conductor'),
                        ),
                        _profileItem(
                          Icons.bar_chart,
                          "Mis Métricas y Ganancias",
                          context,
                          onTap: () => print("Navegar a Métricas"),
                        ),
                        _profileItem(
                          Icons.history,
                          "Historial de Viajes",
                          context,
                          onTap: () => Navigator.pushNamed(context, '/historial_viajes_conductor'),
                        ),
                        _profileItem(
                          Icons.notifications,
                          "Notificaciones",
                          context,
                        ),
                        _profileItem(
                          Icons.policy,
                          "Términos y Privacidad",
                          context,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const TerminosModal(),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildLogoutButton(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  Widget _profileItem(
    IconData icon,
    String title,
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(width: 15),
            Text(title, style: mExtrabold(size: 14, context: context)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await AuthService.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/bienvenido', (route) => false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: statusRed,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          'Cerrar sesión',
          style: mExtrabold(color: Colors.white, size: 16, context: context),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    return Container(
      height: sp(85, context),
      padding: EdgeInsets.symmetric(horizontal: sp(10, context)),
      decoration: const BoxDecoration(
        color: navBarBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, context),
          _navIcon(1, Icons.location_on, context),
          _navIcon(2, Icons.list_alt, context), // Cambiado a icono de lista para conductor
          _navIcon(3, Icons.person, context),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, BuildContext context) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (active) return;
        setState(() => _selectedIndex = index);
        if (index == 0) Navigator.pushReplacementNamed(context, '/principal_conductor');
      },
      child: Container(
        width: sp(45, context),
        height: sp(45, context),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: sp(26, context),
        ),
      ),
    );
  }
}