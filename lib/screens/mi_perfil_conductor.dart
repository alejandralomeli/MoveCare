import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Importaciones de tu lógica
import '../services/auth/auth_service.dart';
import '../providers/user_provider.dart';
import 'widgets/modals/terminos_modal.dart';

// Importaciones visuales del repo
import '../app_theme.dart';
import '../core/utils/auth_helper.dart';
import 'widgets/mic_button.dart';

class MiPerfilConductor extends StatefulWidget {
  const MiPerfilConductor({super.key});

  @override
  State<MiPerfilConductor> createState() => _MiPerfilConductorState();
}

class _MiPerfilConductorState extends State<MiPerfilConductor> {
  // --- ESTADOS Y VARIABLES ---
  bool _isListening = false;
  int _selectedIndex = 3;

  // Colores de estado que tenías en tu código
  static const Color statusRed = Color(0xFFEF5350);
  static const Color statusGreen = Color(0xFF4CAF50);
  static const Color navBarBg = Color(0xFFD6E8FF);

  // Función de escalado (Conservada de tu lógica)
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  void _toggleListening() => setState(() => _isListening = !_isListening);

  @override
  Widget build(BuildContext context) {
    // --- 1. LÓGICA DE DATOS Y PROVIDER (Conservada de tu código) ---
    final user = context.watch<UserProvider>().user;
    final String nombreUsuario = user?.nombre ?? "Conductor";
    final bool isActivo = user?.activo ?? false;

    // Manejo de imagen de perfil en Base64
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

    // --- 2. ESTRUCTURA VISUAL (Del repo) ---
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: _isListening,
              onVoiceTap: _toggleListening,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // AVATAR CON IMAGEN DINÁMICA
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: imagenPerfil, // <-- LÓGICA APLICADA AQUÍ
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: AppColors.white, size: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // NOMBRE DE USUARIO DINÁMICO
                  Text(
                    nombreUsuario, // <-- LÓGICA APLICADA AQUÍ
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // RATING (Se mantiene del repo visualmente)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (i) => const Icon(Icons.star, color: Colors.orange, size: 16)),
                      const SizedBox(width: 5),
                      Text(
                        '5.00',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // BADGE DE ESTADO VERIFICADO/PENDIENTE LÓGICO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActivo ? statusGreen : statusRed, // <-- LÓGICA APLICADA AQUÍ
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActivo ? Icons.check_circle : Icons.error_outline,
                          color: Colors.white, 
                          size: 14
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isActivo ? 'Verificado' : 'Pendiente', // <-- LÓGICA APLICADA AQUÍ
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // MENÚ DE OPCIONES CON TUS RUTAS ORIGINALES
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.history,
                          label: 'Historial de Viajes',
                          onTap: () => Navigator.pushNamed(context, '/historial_viajes_conductor'), // Tu ruta
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notificaciones',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          label: 'Información de Conductor',
                          onTap: () => Navigator.pushNamed(context, '/completar_perfil_conductor'), // Tu ruta
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.policy_outlined,
                          label: 'Términos y Privacidad',
                          onTap: () {
                            // Tu lógica del Modal de Términos
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const TerminosModal(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CERRAR SESIÓN CON TU LÓGICA DE AUTH_SERVICE
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: ListTile(
                      onTap: () async {
                        // Tu lógica estricta de cerrado de sesión
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/bienvenido', (route) => false);
                        }
                      },
                      splashColor: AppColors.error.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: const Icon(Icons.logout, color: AppColors.error, size: 20),
                      title: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
      // CONSERVAMOS TU BOTTOM NAV ORIGINAL PARA GARANTIZAR NAVEGACIÓN
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildMenuItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20, color: AppColors.border);
  }

  // TU LÓGICA DE NAVEGACIÓN INFERIOR INTACTA
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
          _navIcon(2, Icons.list_alt, context), 
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
          color: active ? AppColors.primary : Colors.white, // Ajustado a AppColors
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
          color: active ? Colors.white : AppColors.primary, // Ajustado a AppColors
          size: sp(26, context),
        ),
      ),
    );
  }
}

// --- DELEGADO DEL SLIVER HEADER (Del repo visual) ---
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              'Mi Perfil',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}