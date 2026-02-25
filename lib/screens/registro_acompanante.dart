import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io'; // Para File (solo móvil)
import 'package:image_picker/image_picker.dart';

import '../services/acompanante/acompanante_service.dart';
import '../core/utils/auth_helper.dart';

class RegistrarAcompanante extends StatefulWidget {
  const RegistrarAcompanante({super.key});

  @override
  State<RegistrarAcompanante> createState() => _RegistrarAcompananteState();
}

class _RegistrarAcompananteState extends State<RegistrarAcompanante>
    with TickerProviderStateMixin {
  // --- COLORES Y ESTILO ---
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color textFieldBlue = Color(0xFFB3D4FF);

  // --- CONTROLADORES Y ESTADO ---
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _otroController = TextEditingController();
  String? selectedParentesco;
  int _selectedIndex = 3;
  bool _isLoading = false;
  bool _isVoiceActive = false;

  // --- IMÁGENES (XFile para compatibilidad Web/Móvil) ---
  XFile? _imageFrente;
  XFile? _imageReverso;
  final ImagePicker _picker = ImagePicker();

  // --- ANIMACIONES ---
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> parentescos = [
    'Mamá',
    'Papá',
    'Hijo/Hija',
    'Hermano/Hermana',
    'Tío/Tía',
    'Pareja',
    'Otro',
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
    _nombreController.dispose();
    _otroController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- ESTILOS DE TEXTO ---
  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  TextStyle mSemibold({Color color = primaryBlue, double size = 13}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  // --- LÓGICA DE IMÁGENES ---
  Future<void> _pickImage(bool isFrente) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (photo != null) {
        setState(() {
          if (isFrente)
            _imageFrente = photo;
          else
            _imageReverso = photo;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<String?> _convertImageToBase64(XFile? image) async {
    if (image == null) return null;
    List<int> imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes);
  }

  // --- LÓGICA DE REGISTRO ---
  Future<void> _registrar() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String parentescoFinal = (selectedParentesco == 'Otro')
          ? _otroController.text
          : (selectedParentesco ?? '');
      String? base64Frente = await _convertImageToBase64(_imageFrente);
      String? base64Reverso = await _convertImageToBase64(_imageReverso);

      await AcompananteService.crearAcompanante(
        nombreCompleto: _nombreController.text,
        parentesco: parentescoFinal.isNotEmpty ? parentescoFinal : null,
        ineFrenteBase64: base64Frente,
        ineReversoBase64: base64Reverso,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Acompañante registrado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AuthHelper.manejarError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildInfoBadge(),
                    const SizedBox(height: 25),
                    _buildMainForm(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
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

  Widget _buildInfoBadge() {
    return Container(
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
          Text(
            'Ingrese los datos para registrar',
            style: mBold(color: Colors.white, size: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMainForm() {
    return Container(
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
          _buildTextField(
            'Nombre completo',
            circleColor: Colors.white,
            controller: _nombreController,
          ),
          const SizedBox(height: 15),
          _buildParentescoDropdown(),
          if (selectedParentesco == 'Otro') ...[
            const SizedBox(height: 10),
            _buildTextField(
              'Especifique parentesco',
              circleColor: primaryBlue,
              controller: _otroController,
            ),
          ],
          const SizedBox(height: 25),
          Text(
            'Foto de INE / Identificación oficial',
            style: mBold(size: 13, color: Colors.black),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickImage(true),
                  child: _buildFotoINE(
                    'Anverso',
                    _imageFrente,
                    'assets/ine_anverso.png',
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickImage(false),
                  child: _buildFotoINE(
                    'Reverso',
                    _imageReverso,
                    'assets/ine_reverso.png',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 180,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Registrar', style: mBold(color: Colors.white, size: 16)),
      ),
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: primaryBlue,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Text(
              'Registrar acompañante',
              style: mBold(size: 19, color: Colors.black),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -32,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isVoiceActive = !_isVoiceActive;
                  _isVoiceActive
                      ? _pulseController.repeat(reverse: true)
                      : _pulseController.reset();
                });
              },
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  _isVoiceActive
                      ? 'assets/escuchando.png'
                      : 'assets/controlvoz.png',
                  height: 65,
                  width: 65,
                  errorBuilder: (c, e, s) => CircleAvatar(
                    backgroundColor: _isVoiceActive ? Colors.red : primaryBlue,
                    radius: 32,
                    child: Icon(
                      _isVoiceActive ? Icons.graphic_eq : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required Color circleColor,
    TextEditingController? controller,
  }) {
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
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
                hint: Text(
                  'Parentesco',
                  style: mSemibold(color: primaryBlue.withOpacity(0.6)),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                isExpanded: true,
                items: parentescos
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: mBold(size: 14)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedParentesco = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoINE(String label, XFile? imageFile, String assetPath) {
    return Column(
      children: [
        Container(
          height: 110,
          width: double.infinity,
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
            child: _getImageWidget(imageFile, assetPath),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: mBold(size: 12, color: primaryBlue)),
      ],
    );
  }

  Widget _getImageWidget(XFile? file, String assetPath) {
    if (file == null) return Image.asset(assetPath, fit: BoxFit.contain);
    if (kIsWeb) return Image.network(file.path, fit: BoxFit.cover);
    return Image.file(File(file.path), fit: BoxFit.cover);
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: containerBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, '/agendar_viaje'),
          _navIcon(2, Icons.history, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, '/perfil_pasajero'),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, String routeName) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _selectedIndex != index
          ? Navigator.pushReplacementNamed(context, routeName)
          : null,
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
