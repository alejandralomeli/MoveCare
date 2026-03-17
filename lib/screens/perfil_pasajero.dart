import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import '../core/utils/auth_helper.dart';
import '../services/auth/auth_service.dart';
import '../providers/user_provider.dart';
import 'widgets/modals/terminos_modal.dart';
import 'widgets/mic_button.dart';

class PerfilPasajero extends StatefulWidget {
  const PerfilPasajero({super.key});

  @override
  State<PerfilPasajero> createState() => _PerfilPasajeroState();
}

class _PerfilPasajeroState extends State<PerfilPasajero> {
  bool _isListening = false;

  void _toggleListening() => setState(() => _isListening = !_isListening);

  @override
  Widget build(BuildContext context) {
    // 1. LEEMOS AL USUARIO DESDE EL PROVIDER
    final user = context.watch<UserProvider>().user;
    final String nombreUsuario = user?.nombre ?? "Mi Perfil";
    final bool isActivo = user?.activo ?? false;

    // 2. PREPARAMOS LA FOTO DE PERFIL (Manejo de Base64)
    ImageProvider imagenPerfil = const AssetImage('assets/pasajero.png');

    if (user != null && user.fotoPerfil.isNotEmpty) {
      try {
        String base64String = user.fotoPerfil;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        imagenPerfil = MemoryImage(base64Decode(base64String));
      } catch (e) {
        debugPrint("Error decodificando foto de perfil: $e");
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

                  // Avatar
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: imagenPerfil,
                  ),

                  const SizedBox(height: 14),

                  // Nombre (DInámico)
                  Text(
                    nombreUsuario,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Estrellas + rating
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

                  // Badge verificado (Dinámico)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActivo
                          ? const Color(0xFF4CAF50)
                          : AppColors.error,
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
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          label: 'Información personal',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/completar_perfil_pasajero',
                            );
                          },
                        ),
                        _buildDivider(),
                        // _buildMenuItem(
                        //   icon: Icons.person_outline,
                        //   label: 'Configuración de Perfil',
                        //   onTap: () {},
                        // ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notificaciones',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.credit_card_outlined,
                          label: 'Métodos de pago',
                          onTap: () {
                            Navigator.pushNamed(context, '/metodos_pago_lista');
                          },
                        ),
                        _buildDivider(),
                        // _buildMenuItem(
                        //   icon: Icons.lock_outline,
                        //   label: 'Seguridad',
                        //   onTap: () {},
                        // ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.policy_outlined,
                          label: 'Términos y Privacidad',
                          onTap: () {
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
                      onTap: () async {
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/bienvenido',
                            (route) => false,
                          );
                        }
                      },
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
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 3),
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
              'Perfil',
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
        Positioned(
          right: 15,
          bottom: -20,
          child: MicButton(
            isActive: isVoiceActive,
            onTap: onVoiceTap,
            size: 42,
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
