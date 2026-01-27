import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialViajesPasajero extends StatefulWidget {
  const HistorialViajesPasajero({super.key});

  @override
  State<HistorialViajesPasajero> createState() => _HistorialViajesPasajero();
}

class _HistorialViajesPasajero extends State<HistorialViajesPasajero> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  int _selectedIndex = 2; 
  String _filterSelected = 'Todos';
  bool _isVoiceActive = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> filters = ['Todos', 'En proceso', 'Aceptados', 'Rechazados'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  TextStyle mFont({
    Color color = primaryBlue, 
    double size = 14, 
    FontWeight weight = FontWeight.w800
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 35), 
            _buildFilterMenu(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildTripCard('En Curso', primaryBlue, '27 - Noviembre - 2025'),
                  _buildTripCard('En Curso', const Color(0xFFF44336), '27 - Noviembre - 2025'),
                  _buildTripCard('Finalizado', const Color(0xFFF44336), '27 - Noviembre - 2025'),
                  _buildTripCard('Finalizado', const Color(0xFFF44336), '27 - Noviembre - 2025'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            bottom: 35,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Center(
            child: Text(
              'Historial de Viajes', 
              style: mFont(size: 20, color: Colors.black, weight: FontWeight.w800)
            ),
          ),
          Positioned(
            right: 20,
            bottom: -32,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isVoiceActive = !_isVoiceActive;
                  if (_isVoiceActive) {
                    _pulseController.repeat(reverse: true);
                  } else {
                    _pulseController.stop();
                    _pulseController.reset();
                  }
                });
              },
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  _isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                  height: 65,
                  width: 65,
                  errorBuilder: (c, e, s) => CircleAvatar(
                    backgroundColor: _isVoiceActive ? Colors.red : primaryBlue,
                    radius: 32,
                    child: Icon(
                      _isVoiceActive ? Icons.graphic_eq : Icons.mic, 
                      color: Colors.white, 
                      size: 30
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = _filterSelected == filter;
          return GestureDetector(
            onTap: () => setState(() => _filterSelected = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : lightBlueBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: mFont(
                  color: isSelected ? Colors.white : primaryBlue,
                  size: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripCard(String status, Color statusColor, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                status,
                style: mFont(color: Colors.white, size: 11),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25), 
                _buildDottedLine(1.5, Colors.black45),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Origen', style: mFont(size: 16, color: Colors.black)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _buildDottedLine(2.0, primaryBlue.withOpacity(0.5)),
                      ),
                    ),
                    Text('Destino', style: mFont(size: 16, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fecha $date', 
                  style: mFont(size: 14, color: accentBlue, weight: FontWeight.w400)
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: containerBlue,
                      backgroundImage: const AssetImage('assets/conductor.png'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username', style: mFont(size: 14, color: Colors.black)),
                        Row(
                          children: [
                            ...List.generate(5, (index) => 
                              const Icon(Icons.star, color: Colors.orange, size: 14)),
                            const SizedBox(width: 5),
                            Text('4.5', style: mFont(size: 10, color: accentBlue)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text('Verificado', style: mFont(color: Colors.white, size: 10)),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedLine(double thickness, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: thickness,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home),
          _navIcon(1, Icons.location_on),
          _navIcon(2, Icons.history),
          _navIcon(3, Icons.person),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: 28,
        ),
      ),
    );
  }
}