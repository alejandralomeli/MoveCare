import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class ReporteIncidencia extends StatefulWidget {
  const ReporteIncidencia({super.key});

  @override
  State<ReporteIncidencia> createState() => _ReporteIncidenciaState();
}

class _ReporteIncidenciaState extends State<ReporteIncidencia> {
  bool _isListening = false;

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 14, required BuildContext context}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: _isListening,
              onVoiceTap: () => setState(() => _isListening = !_isListening),
            ),
          ),
          SliverFillRemaining(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) => _buildReportCard(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reporte #120$index', style: mExtrabold(size: 15, context: context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'URGENTE',
                  style: mExtrabold(color: AppColors.white, size: 10, context: context),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha: 24 Octubre 2025',
            style: GoogleFonts.montserrat(fontSize: sp(12, context), fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border, thickness: 1),
          ),
          Text(
            'Descripción:',
            style: mExtrabold(size: 13, context: context, color: AppColors.primary),
          ),
          const SizedBox(height: 5),
          Text(
            'El usuario reporta que el vehículo no contaba con la rampa hidráulica mencionada en el perfil del conductor.',
            style: GoogleFonts.montserrat(fontSize: sp(12, context)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _actionBtn('Descartar', AppColors.white, AppColors.textSecondary, context),
              const SizedBox(width: 10),
              _actionBtn('Bloquear', AppColors.error, AppColors.white, context),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bgColor, Color textColor, BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: bgColor == AppColors.white ? const BorderSide(color: AppColors.border) : BorderSide.none,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          style: mExtrabold(color: textColor, size: 11, context: context),
        ),
      ),
    );
  }
}

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
              'Bandeja de Reportes',
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
