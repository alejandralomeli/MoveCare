import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ViajeConfirmado extends StatefulWidget {
  const ViajeConfirmado({super.key});

  @override
  State<ViajeConfirmado> createState() => _ViajeConfirmadoState();
}
class _ViajeConfirmadoState extends State<ViajeConfirmado> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  TextStyle mBold({Color color = primaryBlue, double size = 14, FontWeight weight = FontWeight.w800}) {
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
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/ruta.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            Positioned(
              top: 20,
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
                    height: 65,
                    width: 65,
                    errorBuilder: (c, e, s) => CircleAvatar(
                      backgroundColor: _isVoiceActive ? Colors.red : Colors.white,
                      radius: 32,
                      child: Icon(
                        _isVoiceActive ? Icons.graphic_eq : Icons.mic,
                        color: _isVoiceActive ? Colors.white : primaryBlue,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Título central
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Viaje confirmado',
                  style: mBold(size: 22, color: Colors.black, weight: FontWeight.w900),
                ),
              ),
            ),

            // 5. Card de Detalles 
            Align(
              alignment: Alignment.center,
              child: _buildInfoCard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: accentBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalles del viaje', style: mBold(size: 18, color: primaryBlue)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildLocationRow(Icons.location_on, 'Desde', 'Donde comenzará el viaje', hasLine: true),
                    _buildLocationRow(Icons.location_on, 'Destino', 'Destino de llegada'),
                    const SizedBox(height: 25),
                    _buildDetailRow(Icons.access_time_filled, '10 : 30 am'),
                    _buildDetailRow(Icons.location_on, 'Destino'),
                    _buildDetailRow(Icons.monetization_on, 'Costo'),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60), 
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: "ID_VIAJE_MOVECARE",
                        version: QrVersions.auto,
                        size: 110.0,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String title, String subtitle, {bool hasLine = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: primaryBlue, size: 28),
            if (hasLine)
              Container(
                width: 1.5,
                height: 35,
                color: Colors.black,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: mBold(size: 11, color: accentBlue)),
              Text(subtitle, style: mBold(size: 13, color: Colors.black87, weight: FontWeight.w600)),
              if (hasLine) ...[
                const SizedBox(height: 5),
                const Text('-------------------------------------', 
                  style: TextStyle(letterSpacing: -1.5, color: Colors.black26, fontSize: 10)),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentBlue, size: 26),
          const SizedBox(width: 12),
          Text(text, style: mBold(size: 13, color: Colors.black87, weight: FontWeight.w600)),
        ],
      ),
    );
  }

Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, '/agendar_viaje'),
          _navIcon(2, Icons.history, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, '/perfil_pasajero'),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, String routeName) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
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