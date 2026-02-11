import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletarPerfilConductor extends StatefulWidget {
  const CompletarPerfilConductor({super.key});

  @override
  State<CompletarPerfilConductor> createState() => _CompletarPerfilConductorState();
}

class _CompletarPerfilConductorState extends State<CompletarPerfilConductor> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  
  int _selectedIndex = 3;
  bool _isVoiceActive = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _pulseController.reverse();
        if (status == AnimationStatus.dismissed && _isVoiceActive) _pulseController.forward();
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceActive = !_isVoiceActive;
      if (_isVoiceActive) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
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
            delegate: _ConductorHeaderDelegate(
              maxHeight: 110,
              minHeight: 85,
              isVoiceActive: _isVoiceActive,
              pulseAnimation: _pulseController,
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

                  Text('Foto de INE', style: mBold(sw, size: 16)),
                  SizedBox(height: sp(10, sw)),
                  Row(
                    children: [
                      Expanded(child: _buildDocumentCard(sw, 'Anverso', 'Agregar_Ine', 'ine_anverso.png')),
                      SizedBox(width: sp(15, sw)),
                      Expanded(child: _buildDocumentCard(sw, 'Reverso', 'Agregar_Ine', 'ine_reverso.png')),
                    ],
                  ),

                  SizedBox(height: sp(25, sw)),

                  Text('Foto de Licencia de Conducir', style: mBold(sw, size: 16)),
                  SizedBox(height: sp(10, sw)),
                  Row(
                    children: [
                      Expanded(child: _buildDocumentCard(sw, 'Anverso', 'Agregar_Licencia', 'ine_anverso.png')),
                      SizedBox(width: sp(15, sw)),
                      Expanded(child: _buildDocumentCard(sw, 'Reverso', 'Agregar_Licencia', 'ine_reverso.png')),
                    ],
                  ),

                  SizedBox(height: sp(25, sw)),

                  Text('Póliza de Seguro', style: mBold(sw, size: 16)),
                  SizedBox(height: sp(10, sw)),
                  
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, 'Agregar_Poliza'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: sp(20, sw), vertical: sp(8, sw)),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('PDF', style: mBold(sw, color: primaryBlue, size: 14)),
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
      bottomNavigationBar: _buildCustomBottomNav(sw),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentBlue.withOpacity(0.3)),
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
          Text(label, style: mBold(sw, color: primaryBlue, size: 14)),
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
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(label, style: mBold(sw, color: Colors.white, size: 16)),
      ),
    );
  }

  Widget _buildCompleteProfileBanner(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFEF5350), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text('Completar perfil', style: mBold(sw, color: Colors.white, size: 14)),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(sw, 0, Icons.home),
          _navIcon(sw, 1, Icons.location_on),
          _navIcon(sw, 2, Icons.history),
          _navIcon(sw, 3, Icons.person),
        ],
      ),
    );
  }

  Widget _navIcon(double sw, int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 45, 
        height: 45,
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white, 
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 25),
      ),
    );
  }
}

class _ConductorHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final Animation<double> pulseAnimation;
  final VoidCallback onVoiceTap;
  final double sw;
  final TextStyle Function(double, {Color color, double size}) mBold;

  _ConductorHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.pulseAnimation,
    required this.onVoiceTap,
    required this.sw,
    required this.mBold,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = shrinkOffset / maxHeight;
    final double opacity = (1.0 - percent * 2.5).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFB3D4FF)),
        ),

        Positioned(
          left: 10,
          bottom: 35,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1559B2), size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        Positioned(
          left: sw * (135 / 375),
          top: sw * (100 / 375) - shrinkOffset, 
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: mBold(sw, size: 20)),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(Icons.star, color: Colors.orange, size: sw * (16/375))),
                    Text(' 5.00', style: mBold(sw, size: 12, color: const Color(0xFF1559B2))),
                  ],
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: sw * (50 / 375) - shrinkOffset,
          left: sw * (20 / 375),
          child: Opacity(
            opacity: opacity,
            child: CircleAvatar(
              radius: sw * (50 / 375),
              backgroundImage: const AssetImage('assets/conductor.png'),
            ),
          ),
        ),

        Positioned(
          top: sw * (75 / 375) - (shrinkOffset * 0.4),
          right: sw * (25 / 375),
          child: GestureDetector(
            onTap: onVoiceTap,
            child: ScaleTransition(
              scale: pulseAnimation,
              child: Image.asset(
                isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                width: 65,
                height: 65,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _ConductorHeaderDelegate oldDelegate) => true;
}