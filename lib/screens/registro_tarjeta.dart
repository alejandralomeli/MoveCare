import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistroTarjetaScreen extends StatefulWidget {
  const RegistroTarjetaScreen({super.key});

  @override
  State<RegistroTarjetaScreen> createState() => _RegistroTarjetaScreenState();
}
class _RegistroTarjetaScreenState extends State<RegistroTarjetaScreen> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4); 
  static const Color textFieldBlue = Color(0xFFB3D4FF);
  int _selectedIndex = 1;
  bool _isVoiceActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

  void _toggleVoice() {
    setState(() {
      _isVoiceActive = !_isVoiceActive;
      if (_isVoiceActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20, top: 40),
                child: Column(
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Ingrese los datos de su tarjeta', 
                            style: mBold(color: Colors.white, size: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: containerBlue,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/tarjeta.png',
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => Container(
                                  height: 150, 
                                  color: Colors.white, 
                                  child: const Icon(Icons.credit_card, size: 50, color: primaryBlue)
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildTextField('Número de la tarjeta', circleColor: Colors.white),
                          const SizedBox(height: 12),
                          _buildTextField('Nombre Completo', circleColor: primaryBlue),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(flex: 3, child: _buildTextField('Fecha de Expiración', circleColor: Colors.white)),
                              const SizedBox(width: 10),
                              Expanded(flex: 2, child: _buildTextField('CCV', circleColor: primaryBlue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 5,
                        ),
                        child: Text(
                          'Agregar Tarjeta', 
                          style: mBold(color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildTextField(String hint, {required Color circleColor}) {
    return Container(
      decoration: BoxDecoration(
        color: textFieldBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        style: mBold(size: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: mSemibold(color: primaryBlue.withOpacity(0.6), size: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: CircleAvatar(
              backgroundColor: circleColor, 
              radius: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 110, 
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Positioned(
            left: -15,
            bottom: 25,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          Positioned(
            right: -15,
            bottom: -32, 
            child: GestureDetector(
              onTap: _toggleVoice,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isVoiceActive 
                            ? primaryBlue.withOpacity(0.4) 
                            : Colors.black12, 
                        blurRadius: 15, 
                        spreadRadius: _isVoiceActive ? 4 : 2
                      )
                    ],
                  ),
                  child: Image.asset(
                    _isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png', 
                    height: 65, 
                    width: 65, 
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: containerBlue),
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