import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrincipalConductor extends StatefulWidget {
  const PrincipalConductor({super.key});

  @override
  State<PrincipalConductor> createState() => _PrincipalConductorState();
}

class _PrincipalConductorState extends State<PrincipalConductor> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color buttonLightBlue = Color(0xFF64A1F4);
  static const Color darkBlue = Color(0xFF0D47A1);

  int _selectedIndex = 0;
  String _selectedDate = '28';
  bool _isVoiceActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  TextStyle mBold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(height: 120, width: double.infinity, color: lightBlueBg),
                // --- BOTÓN VOLVER ---
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, size.height * 0.08, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // --- IMAGEN SIN BORDE BLANCO ---
                            const CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.transparent, // Eliminado borde blanco
                              backgroundImage: AssetImage('assets/conductor.png'),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bienvenido!', style: mBold(size: 26)),
                                  Text('Username', style: mBold(size: 22, color: Colors.black87)),
                                  _buildBadgeStatus(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 90,
                  right: 20,
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
                        width: 65,
                        height: 65,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Text('Viaje actual', style: mBold(size: 18)),
                  const SizedBox(height: 10),
                  _buildCurrentTripCard(),
                  const SizedBox(height: 20),
                  _buildRouteSection(),
                  const SizedBox(height: 25),
                  Text('Próximos viajes', style: mBold(size: 18)),
                  const SizedBox(height: 15),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _calendarDay('D', '26'),
                        _calendarDay('L', '27'),
                        _calendarDay('M', '28'),
                        _calendarDay('M', '29'),
                        _calendarDay('J', '30'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  Text('Historial de viajes', style: mBold(size: 18)),
                  const SizedBox(height: 10),
                  _buildHistoryCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildBadgeStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: buttonLightBlue, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text('Completa tu perfil', style: mBold(color: Colors.white, size: 10)),
        ],
      ),
    );
  }

  Widget _buildCurrentTripCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Martes 28 Octubre\nNombre del pasajero:', style: mBold(size: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
                child: Text('9:30am', style: mBold(color: Colors.white, size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Origen', style: mBold(color: primaryBlue, size: 18)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.arrow_forward, color: Colors.red, size: 30),
              ),
              Text('Destino', style: mBold(color: primaryBlue, size: 18)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Image.asset('assets/movecare.png', width: 40, height: 40),
              const SizedBox(width: 10),
              Text('Necesidades especiales', style: mBold(size: 14)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _actionBtn('Ver detalles', primaryBlue),
              const SizedBox(width: 15),
              _actionBtn('Contactar pasajero', primaryBlue),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(label, textAlign: TextAlign.center, style: mBold(color: Colors.white, size: 13)),
        ),
      ),
    );
  }

  Widget _buildRouteSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: buttonLightBlue,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text('Abrir ruta', style: mBold(color: Colors.black, size: 12)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Image.asset('assets/mapa.png', fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarDay(String day, String num) {
    bool isSelected = _selectedDate == num;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        width: 65,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
          border: isSelected ? Border.all(color: primaryBlue, width: 2) : null,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(13)), // Ajustado para encajar
              ),
              child: Text(day, textAlign: TextAlign.center, style: mBold(color: Colors.white, size: 13)),
            ),
            const SizedBox(height: 8),
            Text(num, style: mBold(color: primaryBlue, size: 16)),
            Icon(Icons.circle, size: 6, color: isSelected ? Colors.red : Colors.transparent),
            const SizedBox(height: 4),
            Text('Oct', style: mBold(size: 9, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryBlue.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Oct 13   Nombre del pasajero', style: mBold(color: primaryBlue, size: 14)),
                    const SizedBox(height: 4),
                    Text('Distancia: 10km', style: mBold(size: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) => Icon(Icons.star, color: index < 4 ? Colors.orange : Colors.grey[300], size: 18)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)),
                child: Text('Ver detalles', style: mBold(color: Colors.white, size: 11)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 18),
              const SizedBox(width: 5),
              Text('Reportar incidencia', style: mBold(color: Colors.red, size: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: cardBlue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home),
          _navIcon(1, Icons.location_on),
          _navIcon(2, Icons.bar_chart),
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
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 25),
      ),
    );
  }
}