import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistorialViajesPasajero extends StatefulWidget {
  const HistorialViajesPasajero({super.key});

  @override
  State<HistorialViajesPasajero> createState() => _HistorialViajesPasajero();
}

class _HistorialViajesPasajero extends State<HistorialViajesPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  int _selectedIndex = 2; // Historial seleccionado en el menú inferior
  String _filterSelected = 'Todos';

  final List<String> filters = ['Todos', 'En proceso', 'Aceptados', 'Rechazados'];

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
            const SizedBox(height: 20),
            _buildFilterMenu(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildTripCard('En Curso', const Color(0xFF1559B2), '27 - Noviembre - 2025'),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('Historial de Viajes', style: mBold(size: 22, color: Colors.black)),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: const Offset(10, 45),
              child: Image.asset(
                'assets/control_voz.png',
                height: 65,
                width: 65,
                errorBuilder: (c, e, s) => const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.mic, color: primaryBlue, size: 40),
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
                style: mBold(
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
          // Badge de estado
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
                style: mBold(color: Colors.white, size: 11),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text('------------------------------------------------------------',
                    style: TextStyle(color: Colors.black26, fontSize: 10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Origen', style: mBold(size: 16, color: Colors.black)),
                    const Text('-----------------------', style: TextStyle(color: Colors.black26)),
                    Text('Destino', style: mBold(size: 16, color: Colors.black)),
                  ],
                ),
                Text('Fecha $date', style: mBold(size: 11, color: accentBlue)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: const AssetImage('assets/conductor.png'),
                      backgroundColor: containerBlue,
                      child: ClipOval(
                        child: Image.asset('assets/conductor.png', 
                          errorBuilder: (c,e,s) => const Icon(Icons.person, color: primaryBlue)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username', style: mBold(size: 14, color: Colors.black)),
                        Row(
                          children: [
                            ...List.generate(5, (index) => 
                              const Icon(Icons.star, color: Colors.orange, size: 14)),
                            const SizedBox(width: 5),
                            Text('4.5', style: mBold(size: 10, color: accentBlue)),
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
                              Text('Verificado', style: mBold(color: Colors.white, size: 10)),
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

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFE3F2FD)),
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