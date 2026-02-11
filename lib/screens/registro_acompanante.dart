import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrarAcompanante extends StatefulWidget {
  const RegistrarAcompanante({super.key});

  @override
  State<RegistrarAcompanante> createState() => _RegistrarAcompananteState();
}

class _RegistrarAcompananteState extends State<RegistrarAcompanante> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color textFieldBlue = Color(0xFF99C4FF);

  int _selectedIndex = 3;
  String? selectedParentesco;
  bool _isVoiceActive = false;
  final TextEditingController _otroController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> parentescos = [
    'Mamá', 'Papá', 'Hijo/Hija', 'Hermano/Hermana', 'Tío/Tía', 'Pareja', 'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _otroController.dispose();
    super.dispose();
  }

  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  TextStyle mSemibold({Color color = Colors.black, double size = 13}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }


  void _showImagePicker(String titulo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryBlue),
                title: Text('Galería', style: mSemibold()),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryBlue),
                title: Text('Cámara', style: mSemibold()),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: primaryBlue),
                title: Text('Archivos', style: mSemibold()),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
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
              child: Center( 
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
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
                          children: [
                            _buildTextField('Nombre completo', circleColor: Colors.white),
                            const SizedBox(height: 15),
                            _buildParentescoDropdown(),
                            if (selectedParentesco == 'Otro') ...[
                              const SizedBox(height: 10),
                              _buildTextField('Especifique parentesco', circleColor: primaryBlue, controller: _otroController),
                            ],
                            const SizedBox(height: 25),
                            Text('Foto de INE / Identificación oficial', 
                              style: mBold(size: 13, color: Colors.black)),
                            const SizedBox(height: 15),
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
      height: 110, 
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Positioned(
            left: 15,
            bottom: 30,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          Center(
            child: Text('Registrar acompañante', 
              style: mBold(size: 19, color: Colors.black)),
          ),
          
          Positioned(
            right: 20,
            bottom: -32, 
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
                  _isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                  height: 65, width: 65,
                  errorBuilder: (c, e, s) => CircleAvatar(
                    backgroundColor: _isVoiceActive ? Colors.red : primaryBlue, 
                    radius: 32,
                    child: Icon(_isVoiceActive ? Icons.graphic_eq : Icons.mic, color: Colors.white, size: 30)
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
          hintStyle: mSemibold(color: primaryBlue.withOpacity(0.6)),
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
                hint: Text('Parentesco', style: mSemibold(color: primaryBlue.withOpacity(0.6))),
                icon: const Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                isExpanded: true,
                items: parentescos.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: mBold(size: 14)),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => selectedParentesco = newValue),
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
        GestureDetector(
          onTap: () => _showImagePicker(label), 
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(Icons.add_a_photo, color: primaryBlue, size: 40),
              ),
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
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}