import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrarAcompanante extends StatefulWidget {
  const RegistrarAcompanante({super.key});

  @override
  State<RegistrarAcompanante> createState() => _RegistrarAcompananteState();
}

class _RegistrarAcompananteState extends State<RegistrarAcompanante> {
  // Colores unificados con las interfaces anteriores
  static const Color primaryBlue = Color(0xFF1559B2); // Azul oscuro
  static const Color lightBlueBg = Color(0xFFB3D4FF); // Header
  static const Color containerBlue = Color(0xFFD6E8FF); // Fondo contenedor
  static const Color accentBlue = Color(0xFF64A1F4); // Botón y badge
  static const Color textFieldBlue = Color(0xFF99C4FF); // Campos de texto

  int _selectedIndex = 3; // Suponiendo que perfil/registro es la última opción
  String? selectedParentesco;
  final TextEditingController _otroController = TextEditingController();

  final List<String> parentescos = [
    'Mamá', 'Papá', 'Hijo/Hija', 'Hermano/Hermana', 'Tío/Tía', 'Pareja', 'Otro'
  ];

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  children: [
                    // Badge Informativo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('Ingrese los datos para registrar', 
                            style: mBold(color: Colors.white, size: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // CONTENEDOR PRINCIPAL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: containerBlue,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo Nombre Completo (Círculo Blanco)
                          _buildTextField('Nombre completo', circleColor: Colors.white),
                          const SizedBox(height: 15),

                          // Menú Desplegable Parentesco (Círculo Azul)
                          _buildParentescoDropdown(),
                          
                          // Campo extra si selecciona "Otro"
                          if (selectedParentesco == 'Otro') ...[
                            const SizedBox(height: 10),
                            _buildTextField('Especifique parentesco', circleColor: primaryBlue, controller: _otroController),
                          ],

                          const SizedBox(height: 25),
                          Text('Foto de INE / Identificación oficial', 
                            style: mBold(size: 13, color: Colors.black)),
                          const SizedBox(height: 15),

                          // FOTOS INE
                          Row(
                            children: [
                              Expanded(child: _buildFotoINE('Anverso', 'assets/ine_anverso.png')),
                              const SizedBox(width: 15),
                              Expanded(child: _buildFotoINE('Reverso', 'assets/ine_reverso.png')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // BOTÓN REGISTRAR
                    SizedBox(
                      width: 180,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 5,
                        ),
                        child: Text('Registrar', style: mBold(color: Colors.white, size: 16)),
                      ),
                    ),
                  ],
                ),
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
          Text('Registrar acompañante', style: mBold(size: 20, color: Colors.black)),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: const Offset(10, 53), // Espacio del micrófono bajado
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  //color: lightBlueBg,
                 //shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/control_voz.png',
                  height: 60, width: 60,
                  errorBuilder: (c, e, s) => const CircleAvatar(
                    backgroundColor: primaryBlue, 
                    child: Icon(Icons.mic, color: Colors.white)
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {required Color circleColor, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: textFieldBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        style: mBold(size: 14),
        decoration: InputDecoration(
          hintText: hint,
          // ignore: deprecated_member_use
          hintStyle: GoogleFonts.montserrat(color: primaryBlue.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: CircleAvatar(backgroundColor: circleColor, radius: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildParentescoDropdown() {
    return Container(
      padding: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: textFieldBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircleAvatar(backgroundColor: primaryBlue, radius: 10),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedParentesco,
                hint: Text('Parentesco', style: GoogleFonts.montserrat(color: primaryBlue.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 13)),
                icon: const Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                isExpanded: true,
                items: parentescos.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: mBold(size: 14)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => selectedParentesco = newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoINE(String label, String assetPath) {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image, color: primaryBlue, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: mBold(size: 12, color: primaryBlue)),
      ],
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: containerBlue),
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