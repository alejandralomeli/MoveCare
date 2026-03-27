import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- SERVICIOS Y MODALES RECUPERADOS ---
import '../providers/user_provider.dart';
import 'widgets/modals/terminos_modal.dart';

// --- DEPENDENCIAS ACTUALES ---
import '../app_theme.dart';
import '../core/utils/auth_helper.dart';
import 'widgets/font_size_sheet.dart';

class MiPerfilConductor extends StatefulWidget {
  const MiPerfilConductor({super.key});

  @override
  State<MiPerfilConductor> createState() => MiPerfilConductorState();
}

class MiPerfilConductorState extends State<MiPerfilConductor> {
  bool _isListening = false;

  void _toggleListening() => setState(() => _isListening = !_isListening);

  @override
  Widget build(BuildContext context) {
    // 1. OBTENCIÓN DE DATOS DEL PROVIDER (Lógica del código viejo)
    final user = context.watch<UserProvider>().user;
    final String nombreUsuario = user?.nombre ?? "Conductor";
    final bool isActivo = user?.activo ?? false;

    // 2. MANEJO DE IMAGEN DE PERFIL (Lógica del código viejo)
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

                  // Avatar (UI nueva con imagen de base de datos)
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: imagenPerfil, // <-- Imagen inyectada
                      ),
                      // Positioned(
                      //   bottom: 2,
                      //   right: 2,
                      //   // child: Container(
                      //   //   padding: const EdgeInsets.all(5),
                      //   //   decoration: const BoxDecoration(
                      //   //     color: AppColors.primary,
                      //   //     shape: BoxShape.circle,
                      //   //   ),
                      //   //   // child: const Icon(Icons.edit, color: AppColors.white, size: 14),
                      //   // ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Nombre (UI nueva con nombre real de BD)
                  Text(
                    nombreUsuario, // <-- Nombre inyectado
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Estrellas + rating (UI nueva respetada)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
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

                  // Badge verificado / pendiente (Lógica inyectada respetando UI nueva)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActivo
                          ? Colors.green
                          : AppColors.error, // Color según estado
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActivo ? Icons.check_circle : Icons.error_outline,
                          color: AppColors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isActivo ? 'Verificado' : 'Pendiente',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Menú de opciones
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
                        // NUEVO APARTADO: Mis Viajes
                        _buildMenuItem(
                          icon: Icons
                              .map_outlined, // Puedes cambiarlo a Icons.directions_car_outlined si prefieres
                          label: 'Mis Viajes',
                          onTap: () =>
                              Navigator.pushNamed(context, '/viajes_conductor'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.history,
                          label: 'Mi Historial',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/historial_viajes_conductor',
                          ),
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
                          label: 'Configuración de Perfil',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/completar_perfil_conductor',
                          ),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          label: 'Privacidad',
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const TerminosModal(),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.text_fields_rounded,
                          label: 'Tamaño de letra',
                          onTap: () => showFontSizeSheet(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Cerrar sesión
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: ListTile(
                      onTap: () => AuthHelper.expulsarUsuario(context),
                      splashColor: AppColors.error.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 20,
                      ),
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
      // AQUÍ ESTÁ EL MENÚ DE NAVEGACIÓN INFERIOR AL QUE HACES REFERENCIA
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 4),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: AppColors.border,
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 20,
            ),
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
