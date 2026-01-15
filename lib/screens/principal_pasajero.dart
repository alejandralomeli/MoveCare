import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrincipalPasajero extends StatefulWidget {
  const PrincipalPasajero({super.key});

  @override
  State<PrincipalPasajero> createState() => _PrincipalPasajeroState();
}

class _PrincipalPasajeroState extends State<PrincipalPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color buttonLightBlue = Color(0xFF64A1F4);
  static const Color darkBlue = Color(0xFF0D47A1);

  int _selectedIndex = 0;
  String _selectedDate = '28'; // Estado para controlar la selección del calendario

  TextStyle mExtrabold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA (Altura exacta de completar perfil) ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: lightBlueBg,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
                    child: _buildHeader(),
                  ),
                ),
                Positioned(
                  top: 10,
                  bottom: 3,
                  right: 20,
                  child: Image.asset('assets/control_voz.png', width: 65, height: 65),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusButton(),
                  const SizedBox(height: 25),
                  Text('Ubicación actual', style: mExtrabold(size: 18)),
                  const SizedBox(height: 10),
                  _buildMapSection(),
                  const SizedBox(height: 25),
                  Text('Próximo viaje', style: mExtrabold(size: 18)),
                  const SizedBox(height: 10),
                  _buildNextTripCard(),
                  const SizedBox(height: 20),
                  
                  // --- CALENDARIO MENOS ESPACIADO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _calendarDay('D', '26'),
                      _calendarDay('L', '27'),
                      _calendarDay('M', '28'),
                      _calendarDay('M', '29'),
                      _calendarDay('J', '30'),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildAgendarButton(),
                  ),
                  const SizedBox(height: 25),
                  Text('Historial de viajes', style: mExtrabold(size: 18)),
                  const SizedBox(height: 10),
                  _buildTripHistory(),
                  const SizedBox(height: 30),
                  _buildReportButton(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF81D4FA),
            backgroundImage: AssetImage('assets/pasajero.png'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Username', style: mExtrabold(size: 22)),
              Row(
                children: [
                  ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 18)),
                  Text(' 5.00', style: mExtrabold(color: primaryBlue, size: 12)),
                ],
              ),
              const SizedBox(height: 8),
              _buildBadge(Icons.check_circle, 'Verificado'),
              const SizedBox(height: 4),
              _buildBadge(Icons.info, 'Pendiente de verificación'),
            ],
          ),
        ),
      ],
    );
  }

Widget _calendarDay(String day, String num) {
    bool isSelected = _selectedDate == num;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        // Ancho y alto ajustados para ser compactos (proporción app real)
        width: 55, 
        height: 62, 
        margin: const EdgeInsets.symmetric(horizontal: 3), // Margen mínimo para evitar desbordamiento
        decoration: BoxDecoration(
          // Color azul claro de fondo para las tarjetas no seleccionadas
          color: const Color(0xFFE3F2FD), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.transparent, 
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), 
              blurRadius: 4, 
              offset: const Offset(0, 3), // Sombra en el borde inferior
            )
          ],
        ),
        child: Column(
          children: [
            // Parte superior: Letra del día (Azul fuerte)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: primaryBlue, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                day, 
                textAlign: TextAlign.center, 
                style: GoogleFonts.montserrat(
                  color: Colors.white, 
                  fontSize: 11, 
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            // Parte inferior: Número, Punto y Mes
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    num, 
                    style: GoogleFonts.montserrat(
                      color: primaryBlue,
                      fontSize: 16, // Tamaño compacto
                      fontWeight: FontWeight.w800, // Extra Bold
                      height: 1.0,
                    ),
                  ),
                  // Punto indicador de selección
                  Icon(
                    Icons.circle, 
                    size: 4, 
                    color: isSelected ? Colors.red : Colors.transparent
                  ),
                  Text(
                    'Oct', 
                    style: GoogleFonts.montserrat(
                      color: Colors.black, 
                      fontSize: 9, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHistory() {
    return Container(
      clipBehavior: Clip.antiAlias, // Para que el efecto de clic no se salga de los bordes
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue, width: 1.5),
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

  Widget _historyItem(String date, String title, String status) {
    return InkWell(
      onTap: () {
        print("Click en viaje: $title");
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Text(date, style: mExtrabold(size: 13)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: mExtrabold(color: primaryBlue, size: 14)),
                  Text('Conductor:', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Text(status, style: mExtrabold(color: statusRed, size: 11)),
          ],
        ),
      ),
    );
  }

  // ... (Los demás widgets de soporte: _buildBadge, _buildStatusButton, etc., se mantienen igual que en el código anterior)
  
  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label, style: mExtrabold(color: Colors.white, size: 9)),
        ],
      ),
    );
  }

  Widget _buildStatusButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: statusRed, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text('Completar perfil', style: mExtrabold(color: Colors.white, size: 14)),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/mapa.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildNextTripCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Martes 28 Octubre', style: mExtrabold(size: 16)),
                  const SizedBox(height: 4),
                  Text('Chofer:', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text('Lugar:', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(15)),
                child: Text('9:30am', style: mExtrabold(color: Colors.white, size: 14)),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _tripActionBtn('Ver detalles'),
              const SizedBox(width: 10),
              _tripActionBtn('Cancelar cita'),
            ],
          )
        ],
      ),
    );
  }

  Widget _tripActionBtn(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonLightBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: mExtrabold(color: Colors.white, size: 12)),
      ),
    );
  }

  Widget _buildAgendarButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonLightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text('Agendar viaje', style: mExtrabold(color: Colors.black, size: 14)),
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.error, color: Colors.white),
        label: Text('Reportar incidencia', style: mExtrabold(color: Colors.white, size: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: statusRed,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
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
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}