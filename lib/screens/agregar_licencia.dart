import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AgregarLicencia extends StatefulWidget {
  const AgregarLicencia({super.key});

  @override
  State<AgregarLicencia> createState() => _AgregarLicenciaState();
}

class _AgregarLicenciaState extends State<AgregarLicencia> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  
  int _selectedIndex = 3;
  bool _isVoiceActive = false;
  File? _ineAnverso;
  File? _ineReverso;

  final ImagePicker _picker = ImagePicker();

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

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.bold,
    );
  }

  Future<void> _pickImage(String tipo, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (tipo == 'anverso') _ineAnverso = File(image.path);
        if (tipo == 'reverso') _ineReverso = File(image.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context, String tipo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: primaryBlue),
              title: const Text('Cámara'),
              onTap: () { Navigator.pop(context); _pickImage(tipo, ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: primaryBlue),
              title: const Text('Galería / Archivos'),
              onTap: () { Navigator.pop(context); _pickImage(tipo, ImageSource.gallery); },
            ),
          ],
        ),
      ),
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
            delegate: _ProfileHeaderDelegate(
              maxHeight: 110,
              minHeight: 110, 
              isVoiceActive: _isVoiceActive,
              pulseAnimation: _pulseController,
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
              mBold: mBold,
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sw * 0.35), 
                  
                  _buildCompleteProfileBanner(sw),
                  
                  const SizedBox(height: 20),
                  Text('Agregar Licencia de Conducir Tipo C', style: mBold(sw, size: 16)),
                  const SizedBox(height: 20),
                  
                  _buildIneCard(sw, 'Anverso', _ineAnverso, 'assets/ine_anverso.png', () => _showImageSourceActionSheet(context, 'anverso')),
                  const SizedBox(height: 25),
                  _buildIneCard(sw, 'Reverso', _ineReverso, 'assets/ine_reverso.png', () => _showImageSourceActionSheet(context, 'reverso')),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildIneCard(double sw, String label, File? image, String asset, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: sw * 0.45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentBlue.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: image != null 
                ? Image.file(image, fit: BoxFit.cover)
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(asset, fit: BoxFit.contain, 
                      errorBuilder: (c,e,s) => Icon(Icons.add_a_photo, size: sw * 0.15, color: accentBlue)),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: mBold(sw, color: primaryBlue, size: 16)),
      ],
    );
  }

  Widget _buildCompleteProfileBanner(double sw) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFEF5350), borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Completar perfil', style: mBold(sw, color: Colors.white, size: 12)),
          ],
        ),
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
          _navIcon(Icons.home, 0),
          _navIcon(Icons.location_on, 1),
          _navIcon(Icons.history, 2),
          _navIcon(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    bool active = _selectedIndex == index;
    return Container(
      width: 45, 
      height: 45,
      decoration: BoxDecoration(
        color: active ? primaryBlue : Colors.white, 
        shape: BoxShape.circle
      ),
      child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 24),
    );
  }
}

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final Animation<double> pulseAnimation;
  final VoidCallback onVoiceTap;
  final double screenWidth;
  final TextStyle Function(double, {Color color, double size}) mBold;

  _ProfileHeaderDelegate({
    required this.maxHeight, 
    required this.minHeight, 
    required this.isVoiceActive, 
    required this.pulseAnimation, 
    required this.onVoiceTap, 
    required this.screenWidth,
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
          top: screenWidth * (55 / 375), 
          left: 25,
          child: CircleAvatar(
            radius: screenWidth * (55 / 375),
            backgroundColor: Colors.purple[100],
            backgroundImage: const AssetImage('assets/conductor.png'),
          ),
        ),

        Positioned(
          top: screenWidth * (115 / 375),
          left: screenWidth * (145 / 375),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Username', style: mBold(screenWidth, size: 20)),
              Row(
                children: [
                  ...List.generate(5, (i) => Icon(Icons.star, color: Colors.orange, size: screenWidth * 0.04)),
                  Text(' 5.00', style: mBold(screenWidth, size: 10, color: const Color(0xFF1559B2))),
                ],
              ),
              const SizedBox(height: 5),
              _buildBadge('Verificado', Icons.check_circle),
              const SizedBox(height: 4),
              _buildBadge('Pendiente de verificación', Icons.info_outline),
            ],
          ),
        ),

        Positioned(
          top: 75,
          right: 25,
          child: GestureDetector(
            onTap: onVoiceTap,
            child: ScaleTransition(
              scale: pulseAnimation,
              child: Image.asset(
                isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                width: 65, height: 65,
                errorBuilder: (c,e,s) => CircleAvatar(
                  backgroundColor: isVoiceActive ? Colors.red : const Color(0xFF1559B2), 
                  radius: 32, 
                  child: Icon(Icons.mic, color: Colors.white)
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF1559B2), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) => true;
}