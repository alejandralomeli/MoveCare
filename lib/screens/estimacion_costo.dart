import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class EstimacionViaje extends StatefulWidget {
  const EstimacionViaje({super.key});

  @override
  State<EstimacionViaje> createState() => _EstimacionViajeState();
}

class _EstimacionViajeState extends State<EstimacionViaje> {
  bool _isVoiceActive = false;

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({
    Color color = AppColors.primary,
    double size = 14,
    required double sw,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.w700,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/ruta.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: AppColors.surface),
                ),
              ),
            ),

            Positioned(
              top: sh * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Estimación',
                  style: GoogleFonts.montserrat(
                    fontSize: sp(20, sw),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            Positioned(
              top: sh * 0.23,
              left: sw * 0.07,
              right: sw * 0.07,
              child: _buildInfoCard(sw, sh),
            ),

            Positioned(
              top: sh * 0.68,
              left: sw * 0.2,
              right: sw * 0.2,
              child: _buildConfirmButton(sw),
            ),

            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primary,
                  size: sp(20, sw),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
              child: MicButton(
                isActive: _isVoiceActive,
                onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
                size: sp(42, sw),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildInfoCard(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sp(22, sw)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Detalles del viaje', style: mBold(size: 18, sw: sw)),
          ),
          SizedBox(height: sp(20, sw)),
          _buildLocationRow(Icons.location_on, 'Desde', 'Punto de partida', sw),
          SizedBox(height: sp(15, sw)),
          _buildLocationRow(
            Icons.location_on,
            'Destino',
            'Punto de llegada',
            sw,
          ),
          Divider(height: sp(35, sw), color: AppColors.border, thickness: 1),
          _buildDetailRow(Icons.access_time_filled, '10 : 30 am', sw),
          _buildDetailRow(Icons.monetization_on, 'Costo Estimado', sw),
          _buildDetailRow(Icons.payment, 'Método de pago', sw),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String title,
    String subtitle,
    double sw,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: sp(24, sw)),
        SizedBox(width: sp(12, sw)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: mBold(size: 10, color: AppColors.primary, sw: sw),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: sp(13, sw),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(10, sw)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: sp(22, sw)),
          SizedBox(width: sp(12, sw)),
          Text(
            text,
            style: GoogleFonts.montserrat(fontSize: sp(13, sw), fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double sw) {
    return SizedBox(
      height: sp(55, sw),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
        ),
        child: Text(
          'Confirmar',
          style: mBold(color: AppColors.white, size: 17, sw: sw),
        ),
      ),
    );
  }

}
