import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EstimacionViaje extends StatefulWidget {
  const EstimacionViaje({super.key});

  @override
  State<EstimacionViaje> createState() => _EstimacionViajeState();
}

class _EstimacionViajeState extends State<EstimacionViaje>
    with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
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

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({
    Color color = primaryBlue,
    double size = 14,
    required double sw,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.w800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/ruta.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                ),
              ),
            ),

            Positioned(
              top: sh * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Estimación',
                  style: GoogleFonts.montserrat(
                    fontSize: sp(22, sw),
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            Positioned(
              top: sh * 0.23,
              left: sw * 0.07,
              right: sw * 0.07,
              child: _buildInfoCard(sw, sh),
            ),

            Positioned(
              top: sh * 0.68,
              left: sw * 0.2,
              right: sw * 0.2,
              child: _buildConfirmButton(sw),
            ),

            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryBlue,
                  size: sp(20, sw),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
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
                    _isVoiceActive
                        ? 'assets/escuchando.png'
                        : 'assets/controlvoz.png',
                    height: sp(60, sw),
                    width: sp(60, sw),
                    errorBuilder: (c, e, s) => CircleAvatar(
                      backgroundColor: _isVoiceActive
                          ? Colors.red
                          : primaryBlue,
                      radius: sp(30, sw),
                      child: Icon(
                        _isVoiceActive ? Icons.graphic_eq : Icons.mic,
                        color: Colors.white,
                        size: sp(28, sw),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildInfoCard(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sp(22, sw)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentBlue, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Detalles del viaje', style: mBold(size: 18, sw: sw)),
          ),
          SizedBox(height: sp(20, sw)),
          _buildLocationRow(Icons.location_on, 'Desde', 'Punto de partida', sw),
          SizedBox(height: sp(15, sw)),
          _buildLocationRow(
            Icons.location_on,
            'Destino',
            'Punto de llegada',
            sw,
          ),
          Divider(height: sp(35, sw), color: Colors.black12, thickness: 1),
          _buildDetailRow(Icons.access_time_filled, '10 : 30 am', sw),
          _buildDetailRow(Icons.monetization_on, 'Costo Estimado', sw),
          _buildDetailRow(Icons.payment, 'Método de pago', sw),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String title,
    String subtitle,
    double sw,
  ) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: sp(24, sw)),
        SizedBox(width: sp(12, sw)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: mBold(size: 10, color: accentBlue, sw: sw),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: sp(13, sw),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(10, sw)),
      child: Row(
        children: [
          Icon(icon, color: accentBlue, size: sp(22, sw)),
          SizedBox(width: sp(12, sw)),
          Text(
            text,
            style: mBold(size: 13, color: Colors.black87, sw: sw),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double sw) {
    return SizedBox(
      height: sp(55, sw),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        child: Text(
          'Confirmar',
          style: mBold(color: Colors.white, size: 17, sw: sw),
        ),
      ),
    );
  }

  // --- SECCIÓN CORREGIDA (Fusión de funcionalidades) ---

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: sp(75, sw),
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Se pasa tanto la ruta (HEAD) como el ancho (Main)
          _navIcon(0, Icons.home, '/principal_pasajero', sw),
          _navIcon(1, Icons.location_on, '/agendar_viaje', sw),
          _navIcon(2, Icons.history, '/historial_viajes_pasajero', sw),
          _navIcon(3, Icons.person, '/perfil_pasajero', sw),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, String routeName, double sw) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          // Lógica de navegación restaurada
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Container(
        padding: EdgeInsets.all(sp(10, sw)), // Responsividad restaurada
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: sp(26, sw),
        ), // Responsividad restaurada
      ),
    );
  }
}
