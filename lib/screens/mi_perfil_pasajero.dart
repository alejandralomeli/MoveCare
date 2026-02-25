import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiPerfilPasajero extends StatefulWidget {
  const MiPerfilPasajero({super.key});

  @override
  State<MiPerfilPasajero> createState() => MiPerfilPasajeroState();
}

class MiPerfilPasajeroState extends State<MiPerfilPasajero> with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color dividerColor = Color(0xFFD6E8FF);
  static const Color containerBlue = Color(0xFFD6E8FF);

  int _selectedIndex = 3; // Índice para "Perfil"
  bool _isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed && _isListening) {
          _pulseController.forward();
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo de imagen con opacidad
          Positioned.fill(
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: lightBlueBg),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header con botón volver y voz
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sp(15, sw), vertical: sp(15, sw)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      _buildVoiceButton(sw),
                    ],
                  ),
                ),

                _buildProfileHeader(sw),

                SizedBox(height: sp(30, sw)),

                // Contenedor de opciones de menú
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sp(25, sw)),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: sp(20, sw)),
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
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildMenuOption('Mi Historial', () => Navigator.pushNamed(context, '/historial_viajes_pasajero'), sw),
                            _buildDivider(),
                            _buildMenuOption('Notificaciones', () => print("Notificaciones"), sw),
                            _buildDivider(),
                            _buildMenuOption('Configuración de Perfil', () => print("Configuración"), sw),
                            _buildDivider(),
                            _buildMenuOption('Privacidad', () => print("Privacidad"), sw),
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
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildVoiceButton(double sw) {
    return GestureDetector(
      onTap: _toggleListening,
      child: ScaleTransition(
        scale: _pulseController,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Image.asset(
            _isListening ? 'assets/escuchando.png' : 'assets/controlvoz.png',
            key: ValueKey<bool>(_isListening),
            width: sp(60, sw),
            height: sp(60, sw),
            errorBuilder: (c, e, s) => CircleAvatar(
              backgroundColor: _isListening ? Colors.red : primaryBlue,
              radius: sp(30, sw),
              child: Icon(_isListening ? Icons.graphic_eq : Icons.mic, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(double sw) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
            ],
          ),
          child: CircleAvatar(
            radius: sp(65, sw),
            backgroundColor: const Color(0xFF81D4FA),
            backgroundImage: const AssetImage('assets/pasajero.png'),
          ),
        ),
        SizedBox(height: sp(12, sw)),
        Text('Username', style: mBold(size: 24, sw: sw)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: sp(20, sw))),
            Text(' 5.00', style: mBold(color: primaryBlue, size: 14, sw: sw)),
          ],
        ),
        SizedBox(height: sp(8, sw)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sp(12, sw), vertical: sp(4, sw)),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: sp(16, sw)),
              SizedBox(width: sp(6, sw)),
              Text('Verificado', style: mBold(color: Colors.white, size: 12, sw: sw)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(String title, VoidCallback onTap, double sw) {
    return ListTile(
      onTap: onTap,
      splashColor: primaryBlue.withOpacity(0.2),
      contentPadding: EdgeInsets.symmetric(horizontal: sp(30, sw), vertical: sp(5, sw)),
      title: Text(title, style: mBold(size: 17, sw: sw)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.3), size: sp(20, sw)),
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

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: sp(75, sw),
      decoration: const BoxDecoration(color: containerBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, sw, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, sw, '/agendar_viaje'),
          _navIcon(2, Icons.history, sw, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, sw, '/perfil_pasajero'),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, double sw, String routeName) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Container(
        padding: EdgeInsets.all(sp(10, sw)),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: sp(28, sw),
        ),
      ),
    );
  }
}