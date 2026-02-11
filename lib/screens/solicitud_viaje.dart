import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SolicitudViaje extends StatefulWidget {
  const SolicitudViaje({super.key});

  @override
  State<SolicitudViaje> createState() => _SolicitudViajeState();
}

class _SolicitudViajeState extends State<SolicitudViaje> with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);

  int _selectedIndex = 1;
  int _cantidadAcompanantes = 2;
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
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed && _isVoiceActive) {
          _pulseController.forward();
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
            color: lightBlueBg.withOpacity(0.9),
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
                  color: Colors.black,
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
                      color: primaryBlue,
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

  // Estilos de texto
  TextStyle mBold(double sw, {Color color = Colors.black, double size = 16}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.bold, // Negrita estándar
    );
  }

  TextStyle mExtrabold(double sw, {Color color = Colors.black, double size = 20}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.w900, // Máxima negrita
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
              maxHeight: 110,
              minHeight: 85,
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
              pulseAnimation: _pulseController,
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
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildMapContainer(double sw) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset('assets/mapa.png', fit: BoxFit.cover, 
          errorBuilder: (c, e, s) => Container(color: Colors.grey[300])),
      ),
    );
  }

  Widget _buildTripDetailsCard(double sw) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlue.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _locationItem(sw, Icons.location_on, 'Desde', 'Donde comenzará el viaje'),
          const Divider(height: 20, color: Colors.transparent),
          _locationItem(sw, Icons.location_on, 'Destino', 'Destino de llegada'),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.access_time_filled, color: primaryBlue),
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
        Icon(icon, color: primaryBlue, size: 28),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: mBold(sw, color: primaryBlue, size: 12)),
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
              icon: const Icon(Icons.remove_circle_outline, color: primaryBlue, size: 35),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
              decoration: BoxDecoration(color: lightBlueBg, borderRadius: BorderRadius.circular(15)),
              child: Text('$_cantidadAcompanantes', style: mExtrabold(sw, size: 26)),
            ),
            IconButton(
              onPressed: () => setState(() => _cantidadAcompanantes < 4 ? _cantidadAcompanantes++ : null),
              icon: const Icon(Icons.add_circle_outline, color: primaryBlue, size: 35),
            ),
          ],
        ),
        Text('Con acompañante / Sin acompañante', style: mBold(sw, size: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildUserInfoCard(double sw) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlue.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
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
                    Text(' 5.00', style: mBold(sw, size: 10, color: primaryBlue)),
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
        backgroundColor: lightBlueBg,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0, 
      ),
      child: Text(
        label, 
        style: GoogleFonts.montserrat(
          fontSize: sw * (18 / 375), 
          fontWeight: FontWeight.bold, 
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: cardBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [0, 1, 2, 3].map((i) => _navIcon(i, i == 0 ? Icons.home : i == 1 ? Icons.location_on : i == 2 ? Icons.bar_chart : Icons.person)).toList(),
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
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
  final Animation<double> pulseAnimation;
  final String title;

  _DynamicHeaderDelegate({
    required this.maxHeight, 
    required this.minHeight, 
    required this.isVoiceActive, 
    required this.onVoiceTap, 
    required this.screenWidth,
    required this.pulseAnimation,
    required this.title,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = shrinkOffset / maxHeight;
    final double opacity = 1.0 - percent.clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFB3D4FF)),
          child: Opacity(
            opacity: opacity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * (20 / 375), 
                    fontWeight: FontWeight.w900, 
                    color: Colors.black
                  ),
                ),
              ),
            ),
          ),
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
          right: 20,
          bottom: -28,
          child: GestureDetector(
            onTap: onVoiceTap,
            child: ScaleTransition(
              scale: pulseAnimation,
              child: SizedBox(
                height: 65, width: 65,
                child: Image.asset(
                  isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}