import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class SolicitudViaje extends StatefulWidget {
  final String? idViaje;
  const SolicitudViaje({super.key, this.idViaje});

  @override
  State<SolicitudViaje> createState() => _SolicitudViajeState();
}

class _SolicitudViajeState extends State<SolicitudViaje> {
  int _cantidadAcompanantes = 2;
  bool _isVoiceActive = false;

  // --- PANEL DE ESTADO (ACEPTADO / RECHAZADO) ---
  void _mostrarPanelEstado(BuildContext context, String mensaje, String imagen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mensaje,
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 180,
                width: 180,
                child: Image.asset(
                  'assets/$imagen',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      imagen == 'aceptado.png' ? Icons.check_circle : Icons.cancel,
                      size: 120,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleVoice() {
    setState(() => _isVoiceActive = !_isVoiceActive);
  }

  // Estilos de texto
  TextStyle mBold(double sw, {Color color = Colors.black, double size = 13}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mExtrabold(double sw, {Color color = Colors.black, double size = 16}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.w700,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _DynamicHeaderDelegate(
              maxHeight: 80,
              minHeight: 80,
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
              title: 'Solicitud de Viaje',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  _buildMapContainer(sw),
                  const SizedBox(height: 25),
                  _buildTripDetailsCard(sw),
                  const SizedBox(height: 25),
                  _buildCompanionSelector(sw),
                  const SizedBox(height: 25),
                  _buildUserInfoCard(sw),
                  const SizedBox(height: 30),
                  _buildActionButtons(sw, context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildMapContainer(double sw) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('assets/mapa.png', fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: AppColors.surface)),
      ),
    );
  }

  Widget _buildTripDetailsCard(double sw) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _locationItem(sw, Icons.location_on, 'Desde', 'Donde comenzará el viaje'),
          const Divider(height: 20, color: Colors.transparent),
          _locationItem(sw, Icons.location_on, 'Destino', 'Destino de llegada'),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.access_time_filled, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('10 : 30 am', style: mBold(sw, size: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _locationItem(double sw, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: mBold(sw, color: AppColors.primary, size: 12)),
            Text(subtitle, style: mBold(sw, size: 14).copyWith(fontWeight: FontWeight.normal)),
          ],
        )
      ],
    );
  }

  Widget _buildCompanionSelector(double sw) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => setState(() => _cantidadAcompanantes > 0 ? _cantidadAcompanantes-- : null),
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 35),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Text('$_cantidadAcompanantes', style: mExtrabold(sw, size: 26)),
            ),
            IconButton(
              onPressed: () => setState(() => _cantidadAcompanantes < 4 ? _cantidadAcompanantes++ : null),
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 35),
            ),
          ],
        ),
        Text('Con acompañante / Sin acompañante', style: mBold(sw, size: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildUserInfoCard(double sw) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/conductor.png')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: mBold(sw, size: 16)),
                Row(
                  children: [
                    ...List.generate(5, (i) => const Icon(Icons.star, color: Colors.orange, size: 16)),
                    Text(' 5.00', style: mBold(sw, size: 10, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          Image.asset('assets/silla_ruedas.png', width: 30, errorBuilder: (c,e,s) => const Icon(Icons.accessible)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double sw, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _btn(sw, 'Aceptar', () => _mostrarPanelEstado(context, '¡Viaje Aceptado!', 'aceptado.png'))
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _btn(sw, 'Rechazar', () => _mostrarPanelEstado(context, '¡Viaje Rechazado!', 'rechazado.png'))
        ),
      ],
    );
  }

  Widget _btn(double sw, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: sw * (15 / 375),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

}



class _DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;
  final double screenWidth;
  final String title;

  _DynamicHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.onVoiceTap,
    required this.screenWidth,
    required this.title,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: screenWidth * (16 / 375),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          right: 20,
          bottom: -26,
          child: MicButton(isActive: isVoiceActive, onTap: onVoiceTap, size: 52),
        ),
      ],
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}
