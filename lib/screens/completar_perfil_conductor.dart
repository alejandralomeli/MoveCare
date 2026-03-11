import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class CompletarPerfilConductor extends StatefulWidget {
  const CompletarPerfilConductor({super.key});

  @override
  State<CompletarPerfilConductor> createState() => _CompletarPerfilConductorState();
}

class _CompletarPerfilConductorState extends State<CompletarPerfilConductor> {
  bool _isVoiceActive = false;

  void _toggleVoice() {
    setState(() => _isVoiceActive = !_isVoiceActive);
  }

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mRegular(double sw, {Color color = AppColors.textSecondary, double size = 13}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.w500,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ConductorHeaderDelegate(
              maxHeight: 80,
              minHeight: 80,
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
              sw: sw,
              mBold: mBold,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sp(25, sw)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sp(80, sw)),

                  _buildCompleteProfileBanner(sw),

                  SizedBox(height: sp(25, sw)),

                  Text('Foto de INE', style: mBold(sw, size: 14)),
                  SizedBox(height: sp(10, sw)),
                  Row(
                    children: [
                      Expanded(child: _buildDocumentCard(sw, 'Anverso', 'Agregar_Ine', 'ine_anverso.png')),
                      SizedBox(width: sp(15, sw)),
                      Expanded(child: _buildDocumentCard(sw, 'Reverso', 'Agregar_Ine', 'ine_reverso.png')),
                    ],
                  ),

                  SizedBox(height: sp(25, sw)),

                  Text('Foto de Licencia de Conducir', style: mBold(sw, size: 14)),
                  SizedBox(height: sp(10, sw)),
                  Row(
                    children: [
                      Expanded(child: _buildDocumentCard(sw, 'Anverso', 'Agregar_Licencia', 'ine_anverso.png')),
                      SizedBox(width: sp(15, sw)),
                      Expanded(child: _buildDocumentCard(sw, 'Reverso', 'Agregar_Licencia', 'ine_reverso.png')),
                    ],
                  ),

                  SizedBox(height: sp(25, sw)),

                  Text('Póliza de Seguro', style: mBold(sw, size: 14)),
                  SizedBox(height: sp(10, sw)),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, 'Agregar_Poliza'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: sp(20, sw), vertical: sp(8, sw)),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('PDF', style: mBold(sw, color: AppColors.primary, size: 14)),
                    ),
                  ),

                  SizedBox(height: sp(40, sw)),

                  Center(
                    child: Column(
                      children: [
                        _buildActionButton(sw, 'Datos de mi Vehículo', 'Datos_Vehiculo'),
                        SizedBox(height: sp(15, sw)),
                        _buildActionButton(sw, 'Mi Historial', 'Historial_Viajes_Conductor'),
                      ],
                    ),
                  ),
                  SizedBox(height: sp(50, sw)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildDocumentCard(double sw, String label, String route, String assetName) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            height: sp(105, sw),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/$assetName', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.image)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: mBold(sw, color: AppColors.primary, size: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButton(double sw, String label, String route) {
    return SizedBox(
      width: sp(280, sw),
      height: sp(50, sw),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: mBold(sw, color: AppColors.white, size: 14)),
      ),
    );
  }

  Widget _buildCompleteProfileBanner(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text('Completar perfil', style: mBold(sw, color: AppColors.white, size: 12)),
        ],
      ),
    );
  }

}

class _ConductorHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;
  final double sw;
  final TextStyle Function(double, {Color color, double size}) mBold;

  _ConductorHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.onVoiceTap,
    required this.sw,
    required this.mBold,
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
          right: sw * (25 / 375),
          bottom: -26,
          child: MicButton(isActive: isVoiceActive, onTap: onVoiceTap, size: 52),
        ),
      ],
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _ConductorHeaderDelegate oldDelegate) => true;
}
