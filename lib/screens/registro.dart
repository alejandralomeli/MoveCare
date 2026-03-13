import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../core/utils/ui_helpers.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x55000000), Color(0xCC000000)],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            left: 4,
            top: MediaQuery.of(context).padding.top + 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Card
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: sp(24, context)),
                padding: EdgeInsets.symmetric(
                  horizontal: sp(24, context),
                  vertical: sp(32, context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(context),
                    SizedBox(height: sp(16, context)),
                    Text(
                      '¿Cómo quieres registrarte?',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: sp(6, context)),
                    Text(
                      'Selecciona tu tipo de cuenta',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sp(28, context)),

                    _buildRoleCard(
                      context: context,
                      label: 'Soy conductor',
                      subtitle: 'Ofrece servicios de traslado',
                      icon: Icons.directions_car_rounded,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/registro_conductor'),
                    ),

                    SizedBox(height: sp(12, context)),

                    _buildRoleCard(
                      context: context,
                      label: 'Soy pasajero',
                      subtitle: 'Solicita viajes accesibles',
                      icon: Icons.person_rounded,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/registro_pasajero'),
                    ),

                    SizedBox(height: sp(28, context)),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final size = sp(88, context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/movecare.png',
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Icon(
              Icons.local_hospital_rounded,
              size: size * 0.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/iniciar_sesion'),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.montserrat(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          children: [
            const TextSpan(text: '¿Ya tienes cuenta? '),
            TextSpan(
              text: 'Inicia Sesión',
              style: GoogleFonts.montserrat(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
