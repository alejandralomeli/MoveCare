import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePassengerScreen extends StatelessWidget {
  const HomePassengerScreen({super.key});

  // Colores de la interfaz
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBgBlue = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFE57373);
  static const Color buttonBlue = Color(0xFF64A1F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 1. Header: Perfil y Bienvenida
              _buildHeader(context),
              
              const SizedBox(height: 20),
              // 2. Ubicación Actual (Mapa)
              _buildSectionTitle('Ubicación actual'),
              _buildMapSection(),

              const SizedBox(height: 20),
              // 3. Próximo Viaje
              _buildSectionTitle('Próximo viaje'),
              _buildNextTripCard(context),

              const SizedBox(height: 20),
              // 4. Historial de viajes
              _buildSectionTitle('Historial de viajes'),
              _buildTripHistory(),

              const SizedBox(height: 20),
              // 5. Botón Reportar Incidencia
              _buildReportButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS DE SECCIONES ---

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: lightBgBlue,
          child: ClipOval(
            // Asegúrate de que la ruta de la imagen sea correcta
            child: Image.asset('assets/conductor.png', fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Muestra un icono si la imagen no carga
                return const Icon(Icons.person, size: 40, color: primaryBlue);
              },
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido!',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Username',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              // Badge de completar perfil
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: buttonBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Completa tu perfil',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Icono Micrófono
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: lightBgBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: const Icon(Icons.mic_none, color: Colors.black, size: 30),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        // Asegúrate de que la ruta de la imagen sea correcta
        child: Image.asset('assets/mapa.png', fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
             return Container(
               color: Colors.grey[200],
               child: const Center(child: Text('Mapa no disponible', style: TextStyle(color: Colors.grey))),
             );
          },
        ),
      ),
    );
  }

  Widget _buildNextTripCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Martes 28 Octubre', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text('Chofer:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                  Text('Lugar:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text('9:30am', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // Botón Ver Detalles
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/booking_confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Ver detalles', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              // Botón Cancelar Cita
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/cancel_booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Cancelar cita', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tira de calendario con menos separación y cajas más gruesas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _calendarDay('D', '26', false),
              _calendarDay('L', '27', false),
              _calendarDay('M', '28', true), // Hoy
              _calendarDay('M', '29', false),
              _calendarDay('J', '30', false),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // Acción para agendar viaje
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text('Agendar viaje', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTripHistory() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _historyItem('Oct 13', 'Centro médico', 'En curso'),
          const Divider(height: 1, color: primaryBlue),
          _historyItem('Oct 1', 'Banco', 'Finalizado'),
          const Divider(height: 1, color: primaryBlue),
          _historyItem('Sep 28', 'Actividad social', 'Finalizado'),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/report_issue'),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        label: Text('Reportar incidencia', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF5350),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

  // Widget de calendario ajustado: Más ancho y menos espacio
  Widget _calendarDay(String day, String num, bool selected) {
    return Container(
      width: 75, // Más ancho
      margin: const EdgeInsets.symmetric(horizontal: 2), // Menos separación
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Text(day, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(6), // Un poco más de padding vertical
            child: Column(
              children: [
                Text(num, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Texto más grande
                if (selected) const Icon(Icons.circle, size: 6, color: Colors.red),
                const Text('Oct', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyItem(String date, String place, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Text(date, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place, style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold)),
                Text('Conductor:', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(status, style: GoogleFonts.montserrat(color: statusRed, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryBlue,
      unselectedItemColor: primaryBlue.withOpacity(0.5),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      // Iconos más grandes (size: 35)
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 35), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined, size: 35), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.history, size: 35), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 35), label: ''),
      ],
    );
  }
}