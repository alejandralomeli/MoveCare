import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialViajesConductor extends StatefulWidget {
  const HistorialViajesConductor({super.key});

  @override
  State<HistorialViajesConductor> createState() => _HistorialViajesConductorState();
}

class _HistorialViajesConductorState extends State<HistorialViajesConductor> with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color statusGreen = Color(0xFF66BB6A);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color navBarBlue = Color(0xFFD6E8FF);

  int _selectedIndex = 2;
  String _activeFilter = 'Todos';
  bool _isVoiceActive = false;

  late AnimationController _pulseController;
  final List<String> _filters = ['Todos', 'En proceso', 'Aceptados', 'Rechazados'];

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

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(color: lightBlueBg),
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        'Historial de Viajes',
                        style: mBold(size: 18, color: Colors.black, sw: sw),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: sp(20, sw)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Positioned(
                bottom: -28, 
                right: 25,
                child: GestureDetector(
                  onTap: _toggleVoice,
                  child: ScaleTransition(
                    scale: _pulseController,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        _isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => CircleAvatar(
                          backgroundColor: _isVoiceActive ? Colors.red : primaryBlue,
                          child: Icon(_isVoiceActive ? Icons.graphic_eq : Icons.mic, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sp(45, sw)),

          SizedBox(
            height: sp(40, sw),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                return _buildFilterChip(_filters[index], sw);
              },
            ),
          ),

          const SizedBox(height: 15),
  
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _buildHistoryCard('En Curso', primaryBlue, 'auditiva.png', sw),
                _buildHistoryCard('Aceptada', statusGreen, 'silla_ruedas.png', sw),
                _buildHistoryCard('Rechazada', statusRed, 'silla_ruedas.png', sw),
                _buildHistoryCard('Rechazada', statusRed, 'tercera_edad.png', sw, secondIcon: 'auditiva.png'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildFilterChip(String label, double sw) {
    bool isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: sp(18, sw)),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : lightBlueBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: mBold(color: isSelected ? Colors.white : primaryBlue, size: 11, sw: sw),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String status, Color statusColor, String mainIcon, double sw, {String? secondIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(sp(15, sw)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status, style: mBold(color: Colors.white, size: 9, sw: sw)),
            ),
          ),
          
          const Text('--------------------------------------', 
            style: TextStyle(color: Colors.grey, letterSpacing: 2)),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Origen', style: mBold(size: 14, sw: sw)),
              const Text('----------', style: TextStyle(color: Colors.grey)),
              Text('Destino', style: mBold(size: 14, sw: sw)),
            ],
          ),
          
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: sp(25, sw), top: 5),
              child: Text('Fecha 27 - Noviembre - 2025', 
                style: mBold(color: accentBlue, size: 10, sw: sw)),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              CircleAvatar(
                radius: sp(22, sw),
                backgroundImage: const AssetImage('assets/conductor.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Username', style: mBold(size: 13, sw: sw)),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(Icons.star, color: Colors.orange, size: sp(12, sw))),
                        Text(' 5.00', style: mBold(size: 9, color: primaryBlue, sw: sw)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildVerifyBadge(sw),
                  ],
                ),
              ),
              _buildSmallNeedIcon(mainIcon, sw),
              if (secondIcon != null) ...[
                const SizedBox(width: 5),
                _buildSmallNeedIcon(secondIcon, sw),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyBadge(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: sp(10, sw)),
          const SizedBox(width: 4),
          Text('Verificado', style: mBold(color: Colors.white, size: 8, sw: sw)),
        ],
      ),
    );
  }

  Widget _buildSmallNeedIcon(String path, double sw) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset('assets/$path', width: sp(32, sw), height: sp(32, sw), 
        errorBuilder: (c, e, s) => Icon(Icons.accessibility, color: primaryBlue, size: sp(22, sw))),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 70, 
      decoration: const BoxDecoration(color: navBarBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, sw),
          _navIcon(1, Icons.location_on, sw),
          _navIcon(2, Icons.history, sw),
          _navIcon(3, Icons.person, sw),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, double sw) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 45, 
        height: 45, 
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 26),
      ),
    );
  }
}