import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EstimacionViaje extends StatefulWidget {
  const EstimacionViaje({super.key});

  @override
  State<EstimacionViaje> createState() => _EstimacionViajeState();
}

class _EstimacionViajeState extends State<EstimacionViaje> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  int _selectedIndex = 1;

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
        child: Stack(
          children: [
            // 1. Fondo de Mapa
            Positioned.fill(
              child: Image.asset(
                'assets/ruta.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
              ),
            ),

            // 2. Micrófono flotante
            Positioned(
              top: 20,
              right: 20,
              child: Image.asset(
                'assets/control_voz.png',
                height: 65,
                width: 65,
              ),
            ),

            // 3. Título "Estimación"
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Estimación',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // 4. Card de Detalles y Botón de Confirmar
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 30),
                  _buildConfirmButton(),
                ],
              ),
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
          _buildLocationRow(Icons.location_on, 'Desde', 'Donde comenzará el viaje', hasLine: true),
          _buildLocationRow(Icons.location_on, 'Destino', 'Destino de llegada'),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.access_time_filled, '10 : 30 am'),
          _buildDetailRow(Icons.location_on, 'Destino'),
          _buildDetailRow(Icons.monetization_on, 'Costo Estimado'),
          _buildDetailRow(Icons.monetization_on, 'Método de pago seleccionado'),
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
              Text(subtitle, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
              if (hasLine) ...[
                const SizedBox(height: 5),
                const Text('----------------------------------------------------', 
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
          Text(text, style: mBold(size: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        // Lógica para confirmar viaje
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      child: Text(
        'Confirmar Viaje',
        style: mBold(color: Colors.white, size: 16),
      ),
    );
  }

Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFE3F2FD)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, '/agendar_viaje'),
          _navIcon(2, Icons.history, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, '/mi_perfil_pasajero'),
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