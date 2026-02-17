import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CompletarPerfilPasajero extends StatefulWidget {
  const CompletarPerfilPasajero({super.key});

  @override
  State<CompletarPerfilPasajero> createState() =>
      _CompletarPerfilPasajeroState();
}

class _CompletarPerfilPasajeroState extends State<CompletarPerfilPasajero>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color statusRed = Color(0xFFEF5350);

  final Set<String> _selectedNeeds = {};
  int _selectedIndex = 3;
  bool _isListening = false;

  late AnimationController _pulseController;
  File? _ineAnverso;
  File? _ineReverso;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          _pulseController.reverse();
        else if (status == AnimationStatus.dismissed && _isListening)
          _pulseController.forward();
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

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mBold(BuildContext context,
          {Color color = Colors.black, double size = 11}) =>
      GoogleFonts.montserrat(
          color: color,
          fontSize: sp(size, context),
          fontWeight: FontWeight.bold);

  TextStyle mExtrabold(BuildContext context,
          {Color color = Colors.black, double size = 14}) =>
      GoogleFonts.montserrat(
          color: color,
          fontSize: sp(size, context),
          fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 110),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusButton(context),
                      const SizedBox(height: 25),
                      Text('Foto de INE', style: mExtrabold(context, size: 18)),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDocCard(
                                  context,
                                  'Anverso',
                                  _ineAnverso,
                                  'assets/ine_anverso.png',
                                  'anverso')),
                          const SizedBox(width: 15),
                          Expanded(
                              child: _buildDocCard(
                                  context,
                                  'Reverso',
                                  _ineReverso,
                                  'assets/ine_reverso.png',
                                  'reverso')),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Text('¿Presenta alguna necesidad especial?',
                          style: mExtrabold(context, size: 17)),
                      Text(
                          'Seleccione las casillas que se ajusten a su necesidad',
                          style: mBold(context, color: Colors.red, size: 10)),
                      const SizedBox(height: 25),
                      _buildNeedsGrid(context),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('Registrar un acompañante',
                              style:
                                  mBold(context, color: Colors.white, size: 12)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 87.5,
            right: 20,
            child: GestureDetector(
              onTap: _toggleListening,
              child: ScaleTransition(
                scale: _pulseController,
                child: Image.asset(
                  _isListening
                      ? 'assets/escuchando.png'
                      : 'assets/controlvoz.png',
                  width: 65,
                  height: 65,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          color: lightBlueBg,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 35),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: primaryBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/pasajero.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Username',
                  style: GoogleFonts.montserrat(
                      fontSize: 22, fontWeight: FontWeight.w900)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 5),
                  Text('5.00',
                      style: mBold(context, color: primaryBlue, size: 12)),
                ],
              ),
              const SizedBox(height: 4),
              _buildBadge("Verificado", Icons.check_circle_outline),
              const SizedBox(height: 4),
              _buildBadge("Pendiente de verificación", Icons.error_outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(text, style: mBold(context, color: Colors.white, size: 10)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: statusRed, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('Completar perfil',
              style: mBold(context, color: Colors.white, size: 14)),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, String label, File? file,
      String placeholder, String type) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(type),
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: accentBlue.withOpacity(0.5), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: file != null
                  ? Image.file(file, fit: BoxFit.cover)
                  : Image.asset(placeholder, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: mBold(context, color: primaryBlue, size: 14)),
      ],
    );
  }

  Widget _buildNeedsGrid(BuildContext context) {
    final needs = [
      {'label': 'Tercera\nEdad', 'icon': 'assets/tercera_edad.png'},
      {'label': 'Movilidad\nreducida', 'icon': 'assets/silla_ruedas.png'},
      {'label': 'Discapacidad\nauditiva', 'icon': 'assets/auditiva.png'},
      {'label': 'Obesidad', 'icon': 'assets/obesidad.png'},
      {'label': 'Discapacidad\nvisual', 'icon': 'assets/visual.png'},
    ];

    return Center( 
      child: Wrap(
        alignment: WrapAlignment.center, 
        runAlignment: WrapAlignment.center,
        spacing: 15,    
        runSpacing: 20, 
        children: needs
            .map((n) => _buildNeedItem(context, n['label']!, n['icon']!))
            .toList(),
      ),
    );
  }

  Widget _buildNeedItem(BuildContext context, String label, String iconPath) {
    bool isSelected = _selectedNeeds.contains(label);
    return GestureDetector(
      onTap: () => setState(() => isSelected
          ? _selectedNeeds.remove(label)
          : _selectedNeeds.add(label)),
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              height: 90,
              width: 90,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: isSelected ? primaryBlue : accentBlue,
                    width: isSelected ? 3 : 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(iconPath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                  color: accentBlue, borderRadius: BorderRadius.circular(10)),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: mBold(context, color: Colors.white, size: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (type == 'anverso')
          _ineAnverso = File(image.path);
        else
          _ineReverso = File(image.path);
      });
    }
  }

  // --- SECCIÓN CORREGIDA ---

  Widget _buildCustomBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home_rounded, '/principal_pasajero'),
          _navIcon(1, Icons.location_on_rounded, '/agendar_viaje'),
          _navIcon(2, Icons.history_rounded, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person_rounded, '/mi_perfil_pasajero'),
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
          boxShadow: [
            if (!active)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: 30,
        ),
      ),
    );
  }
}