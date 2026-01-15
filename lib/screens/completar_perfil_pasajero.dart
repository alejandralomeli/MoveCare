import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletarPerfilPasajero extends StatefulWidget {
  const CompletarPerfilPasajero({super.key});

  @override
  State<CompletarPerfilPasajero> createState() => _CompletarPerfilPasajeroState();
}

class _CompletarPerfilPasajeroState extends State<CompletarPerfilPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color statusRed = Color(0xFFEF5350);

  final Set<String> _selectedNeeds = {};
  int _selectedIndex = 0; // Para el menú inferior

  void _toggleNeed(String label) {
    setState(() {
      if (_selectedNeeds.contains(label)) {
        _selectedNeeds.remove(label);
      } else {
        _selectedNeeds.add(label);
      }
    });
  }

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
            // --- CABECERA QUE SE MUEVE (AZUL + HEADER + MICRO) ---
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
                // Micrófono: mitad en azul, mitad en blanco, se mueve con el scroll
                Positioned(
                  top: 10,
                  bottom: 3,
                  right: 20,
                  child: Image.asset('assets/control_voz.png', width: 65, height: 65),
                ),
              ],
            ),

            const SizedBox(height: 0), // Espacio para el micrófono que sobresale

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusButton(),
                  const SizedBox(height: 20),
                  Text('Foto de INE', style: mExtrabold(size: 18)),
                  const SizedBox(height: 12),
                  
                  // Tarjetas INE con Sombra
                  Row(
                    children: [
                      Expanded(child: _buildDocCard('Anverso', 'assets/ine_anverso.png')),
                      const SizedBox(width: 15),
                      Expanded(child: _buildDocCard('Reverso', 'assets/ine_reverso.png')),
                    ],
                  ),

                  const SizedBox(height: 35),
                  Text('¿Presenta alguna necesidad especial?', style: mExtrabold(size: 17)),
                  Text('Seleccione las casillas que se ajusten a su necesidad', 
                    style: mExtrabold(color: Colors.red, size: 10)),
                  
                  const SizedBox(height: 25),
                  
                  // NECESIDADES EN DOS RENGLONES - MÁS GRANDES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNeedItem('Tercera Edad', 'assets/tercera_edad.png'),
                      _buildNeedItem('Movilidad reducida', 'assets/silla_ruedas.png'),
                      _buildNeedItem('Discapacidad auditiva', 'assets/auditiva.png'),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNeedItem('Obesidad', 'assets/obesidad.png'),
                      const SizedBox(width: 25),
                      _buildNeedItem('Discapacidad visual', 'assets/visual.png'),
                    ],
                  ),

                  const SizedBox(height: 40),
                  
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Registrar un acompañante', 
                      style: mExtrabold(color: Colors.white, size: 16)),
                  ),
                  const SizedBox(height: 40),
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

  Widget _buildDocCard(String label, String imagePath) {
    return GestureDetector(
      onTap: () => print("Abrir selector para $label"),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentBlue, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(imagePath, fit: BoxFit.contain), 
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: mExtrabold(color: primaryBlue, size: 15)),
        ],
      ),
    );
  }

  Widget _buildNeedItem(String label, String imagePath) {
    bool isSelected = _selectedNeeds.contains(label);

    return GestureDetector(
      onTap: () => _toggleNeed(label),
      child: Column(
        children: [
          Container(
            height: 110, // Más grande
            width: 110,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? primaryBlue : accentBlue, 
                width: isSelected ? 4.0 : 2.0
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),
          // Recuadro azul claro para la palabra
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: lightBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label, 
              textAlign: TextAlign.center, 
              style: mExtrabold(
                color: isSelected ? primaryBlue : Colors.black, 
                size: 9
              )
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildCustomBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)), // Sin redondeo
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home_rounded),
          _navIcon(1, Icons.location_on_rounded),
          _navIcon(2, Icons.history_rounded),
          _navIcon(3, Icons.person_rounded),
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
          color: active ? primaryBlue : Colors.white, // Círculo cambia de color
          shape: BoxShape.circle,
          boxShadow: [
            if (!active)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ]
        ),
        child: Icon(
          icon, 
          color: active ? Colors.white : primaryBlue, 
          size: 30
        ),
      ),
    );
  }
}