import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPasajero extends StatelessWidget {
  const PerfilPasajero({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSectionTitle('Ubicación actual'),
              _buildMapSection(),
              const SizedBox(height: 20),
              _buildSectionTitle('Próximo viaje'),
              _buildNextTripCard(context),
              const SizedBox(height: 20),
              _buildSectionTitle('Historial de viajes'),
              _buildTripHistory(),
              const SizedBox(height: 20),
              _buildReportButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: lightBlueBg,
          backgroundImage: AssetImage('assets/usuario.png'), // Tu imagen de avatar
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bienvenido!', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Username', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(10)),
                child: Text('! Completa tu perfil', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        _buildMicButton(),
      ],
    );
  }

  Widget _buildMicButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: lightBlueBg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: const Icon(Icons.mic_none, color: Colors.black, size: 30),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMapSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset('assets/mapa.png', height: 130, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _buildNextTripCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: cardBlue, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Martes 28 Octubre', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Chofer:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Lugar:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(15)),
                child: Text('9:30am', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _smallActionBtn('Ver detalles', accentBlue, () {}),
              const SizedBox(width: 10),
              _smallActionBtn('Cancelar cita', accentBlue, () {}),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _calendarDay('D', '26', false),
              _calendarDay('L', '27', false),
              _calendarDay('M', '28', true),
              _calendarDay('M', '29', false),
              _calendarDay('J', '30', false),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text('Agendar viaje', style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _calendarDay(String day, String num, bool selected) {
    return Container(
      width: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Text(day, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Text(num, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryBlue)),
                if (selected) const Icon(Icons.circle, size: 6, color: Colors.red),
                const Text('Oct', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallActionBtn(String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white)),
          child: Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildTripHistory() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: primaryBlue), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _historyItem('Oct 13', 'Centro médico', 'En curso', true),
          const Divider(height: 1, color: primaryBlue),
          _historyItem('Oct 1', 'Banco', 'Finalizado', false),
          const Divider(height: 1, color: primaryBlue),
          _historyItem('Sep 28', 'Actividad social', 'Finalizado', false),
        ],
      ),
    );
  }

  Widget _historyItem(String date, String place, String status, bool active) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(date, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place, style: GoogleFonts.montserrat(color: primaryBlue, fontWeight: FontWeight.bold)),
                const Text('Conductor:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(status, style: GoogleFonts.montserrat(color: active ? Colors.redAccent : Colors.red.shade300, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.error, color: Colors.white),
      label: Text('Reportar incidencia', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF5350),
        minimumSize: const Size(220, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// Widget Global de Navegación para reutilizar
Widget _buildBottomNav(BuildContext context, int currentIndex) {
  return Container(
    decoration: const BoxDecoration(
      color: Color(0xFFD6E8FF),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD6E8FF),
        selectedItemColor: const Color(0xFF1559B2),
        unselectedItemColor: const Color(0xFF1559B2).withOpacity(0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 3) Navigator.pushNamed(context, '/profile');
          if (index == 0) Navigator.pushNamed(context, '/home_passenger');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 35), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on, size: 35), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history, size: 35), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 35), label: ''),
        ],
      ),
    ),
  );
}