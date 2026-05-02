import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- DEPENDENCIAS ACTUALES ---
import '../app_theme.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../core/utils/auth_helper.dart';

class PrincipalAdministrador extends StatefulWidget {
  const PrincipalAdministrador({super.key});

  @override
  State<PrincipalAdministrador> createState() => _PrincipalAdministradorState();
}

class _PrincipalAdministradorState extends State<PrincipalAdministrador> {
  bool _loadingHome = true;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      // Llamada al servicio con el rol de admin
      final homeData = await HomeService.getHome(role: "administrador");

      if (mounted) {
        // Guardamos la info en el provider
        final userProvider = context.read<UserProvider>();
        userProvider.setUserFromJson(homeData["usuario"]);

        setState(() => _loadingHome = false);
      }
    } catch (e) {
      if (mounted) AuthHelper.manejarError(context, e);
      if (mounted) setState(() => _loadingHome = false);
    }
  }

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHome) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Leemos el usuario del provider para inyectarlo en la vista
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user), // Pasamos el modelo completo de usuario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text('Panel de control', style: mBold(size: 18)),
                  const SizedBox(height: 6),
                  Text(
                    'Gestiona los usuarios y revisa la actividad de la plataforma.',
                    style: mBold(size: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // --- RUTAS CONECTADAS ---
                  _buildNavCard(
                    context,
                    icon: Icons.people_rounded,
                    title: 'Gestión de Usuarios',
                    subtitle: 'Aprueba o rechaza conductores y pasajeros',
                    route: '/gestion_usuarios',
                  ),
                  const SizedBox(height: 14),
                  _buildNavCard(
                    context,
                    icon: Icons.flag_rounded,
                    title: 'Bandeja de Reportes',
                    subtitle: 'Revisa y gestiona las incidencias reportadas',
                    route: '/reporte_incidencia',
                  ),
                  const SizedBox(height: 14),
                  _buildNavCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Historial de Auditoría',
                    subtitle:
                        'Consulta el registro de acciones administrativas',
                    route: '/historial_auditorias',
                  ),

                  const SizedBox(height: 40),

                  // Botón de cerrar sesión con tu apariencia original de tarjeta
                  _buildLogoutButton(context),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }

  Widget _buildHeader(dynamic user) {
    // Verificación segura para evitar crashes si el backend manda "N/A" u otro texto inválido en vez de base64
    final bool tieneFoto =
        user != null &&
        user.fotoPerfil != null &&
        user.fotoPerfil.isNotEmpty &&
        user.fotoPerfil != "N/A";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          width: double.infinity,
          color: AppColors.primaryLight,
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: tieneFoto
                  ? MemoryImage(base64Decode(user.fotoPerfil.split(',').last))
                  : null,
              child: !tieneFoto
                  ? const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.primary,
                      size: 40,
                    )
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: -21,
          left: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.nombre ?? 'Bienvenido', // Nombre extraído del provider
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Administrador',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Restaurado a tu diseño original de tarjeta roja
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          AuthHelper.expulsarUsuario(context), // Funcionalidad conectada aquí
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cerrar Sesión',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Salir de la plataforma',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}