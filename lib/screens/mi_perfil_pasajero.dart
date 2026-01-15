import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiPerfilPasajero extends StatefulWidget {
  const MiPerfilPasajero({super.key});

  @override
  State<MiPerfilPasajero> createState() => MiPerfilPasajeroState();
}

class MiPerfilPasajeroState extends State<MiPerfilPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color dividerColor = Color(0xFFD6E8FF);
  
  int _selectedIndex = 3;
  TextStyle mBold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: Image.asset('assets/control_voz.png', width: 60, height: 60),
                  ),
                ),
                _buildProfileHeader(),
                const SizedBox(height: 30),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            _buildMenuOption('Mi Historial', () => print("Historial")),
                            _buildDivider(),
                            _buildMenuOption('Notificaciones', () => print("Notificaciones")),
                            _buildDivider(),
                            _buildMenuOption('Ubicaciones guardadas', () => print("Ubicaciones")),
                            _buildDivider(),
                            _buildMenuOption('Configuración de Perfil', () => print("Configuración")),
                            _buildDivider(),
                            _buildMenuOption('Privacidad', () => print("Privacidad")),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: const CircleAvatar(
            radius: 65,
            backgroundColor: Color(0xFF81D4FA),
            backgroundImage: AssetImage('assets/pasajero.png'),
          ),
        ),
        const SizedBox(height: 12),
        Text('Username', style: mBold(size: 24)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 20)),
            Text(' 5.00', style: mBold(color: primaryBlue, size: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text('Verificado', style: mBold(color: Colors.white, size: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      // Efecto de sombreado azul transparente al dar clic
      splashColor: primaryBlue.withOpacity(0.2), 
      hoverColor: primaryBlue.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      title: Text(
        title,
        style: mBold(size: 18),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.transparent),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1.5,
      indent: 20,
      endIndent: 20,
      color: dividerColor,
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFFD6E8FF),
      ),
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