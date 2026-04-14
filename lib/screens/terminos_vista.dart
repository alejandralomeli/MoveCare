import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class TerminosVista extends StatelessWidget {
  const TerminosVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(titulo: 'Términos y condiciones'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última actualización: Febrero 2026',
                    style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildSeccion(
                    '1. Aceptación de los términos',
                    'Al descargar, instalar o utilizar MoveCare, aceptas estar sujeto a estos Términos y Condiciones. Si no estás de acuerdo, no podrás utilizar nuestros servicios.',
                  ),
                  _buildSeccion(
                    '2. Descripción del servicio',
                    'MoveCare es una plataforma que facilita la conexión entre usuarios que requieren asistencia de movilidad médica no de emergencia (pasajeros) y conductores independientes registrados.',
                  ),
                  _buildSeccion(
                    '3. Responsabilidades del usuario',
                    '• Proveer información precisa y verídica durante el registro.\n• Mantener la confidencialidad de sus credenciales de acceso.\n• Tratar con respeto a los conductores y personal de apoyo.\n• Pagar las tarifas correspondientes por los servicios solicitados.',
                  ),
                  _buildSeccion(
                    '4. Limitación de responsabilidad',
                    'MoveCare no proporciona servicios médicos ni actúa como proveedor de atención médica. Los conductores son contratistas independientes. En caso de emergencia, contacta al 911.',
                  ),
                  _buildSeccion(
                    '5. Pagos y cancelaciones',
                    'Los pagos se procesan a través de proveedores de terceros. MoveCare puede aplicar cargos por cancelación si un viaje se cancela después de que un conductor ha sido asignado.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            contenido,
            style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 6),
          const Divider(color: AppColors.border),
        ],
      ),
    );
  }
}

class PrivacidadVista extends StatelessWidget {
  const PrivacidadVista({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(titulo: 'Aviso de privacidad'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última actualización: Febrero 2026',
                    style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _buildSeccion(
                    '1. Información que recopilamos',
                    'Para brindar nuestros servicios, MoveCare recopila: nombre, correo electrónico, teléfono, ubicación GPS en tiempo real e información básica sobre necesidades de movilidad.',
                  ),
                  _buildSeccion(
                    '2. Uso de la información',
                    '• Conectar pasajeros con conductores.\n• Procesar pagos de manera segura.\n• Mejorar la seguridad y confiabilidad de la plataforma.\n• Brindar soporte y notificaciones sobre tus viajes.',
                  ),
                  _buildSeccion(
                    '3. Protección de datos sensibles',
                    'Cualquier información sobre necesidades de movilidad se comparte estrictamente con el conductor asignado para fines logísticos, cumpliendo con los estándares de seguridad aplicables.',
                  ),
                  _buildSeccion(
                    '4. Compartir información',
                    'No vendemos ni alquilamos tu información personal a terceros. Podemos compartir datos con proveedores de servicios (como pasarelas de pago) o cuando sea requerido por ley.',
                  ),
                  _buildSeccion(
                    '5. Tus derechos',
                    'Tienes derecho a acceder, rectificar, cancelar u oponerte al tratamiento de tus datos personales. Contáctanos a través de la aplicación para ejercer estos derechos.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            contenido,
            style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 6),
          const Divider(color: AppColors.border),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final String titulo;
  const _HeaderDelegate({required this.titulo});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primaryLight,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            bottom: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                titulo,
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override double get maxExtent => 80;
  @override double get minExtent => 80;
  @override bool shouldRebuild(covariant _HeaderDelegate old) => old.titulo != titulo;
}
