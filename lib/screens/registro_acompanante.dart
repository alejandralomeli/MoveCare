import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../services/acompanante/acompanante_service.dart';
// IMPORTANTE: Ajusta la ruta si tu AuthHelper está en otra carpeta (ej: utils o helpers)
import '../core/utils/auth_helper.dart'; 

class RegistrarAcompanante extends StatefulWidget {
  const RegistrarAcompanante({super.key});

  @override
  State<RegistrarAcompanante> createState() => _RegistrarAcompananteState();
}

class _RegistrarAcompananteState extends State<RegistrarAcompanante> {
  // Colores
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color textFieldBlue = Color(0xFF99C4FF);

  int _selectedIndex = 3;
  
  // --- CONTROLADORES Y ESTADO ---
  final TextEditingController _nombreController = TextEditingController(); 
  final TextEditingController _otroController = TextEditingController();
  String? selectedParentesco;
  
  // Variables para las imágenes
  File? _imageFrente;
  File? _imageReverso;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

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

  // --- LÓGICA DE FOTOS ---
  Future<void> _pickImage(bool isFrente) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (photo != null) {
        setState(() {
          if (isFrente) {
            _imageFrente = File(photo.path);
          } else {
            _imageReverso = File(photo.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  Future<String?> _convertImageToBase64(File? image) async {
    if (image == null) return null;
    List<int> imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes);
  }

  // --- LÓGICA DE REGISTRO (CON AUTH HELPER) ---
  Future<void> _registrar() async {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Definir parentesco final
      String parentescoFinal = selectedParentesco ?? '';
      if (selectedParentesco == 'Otro') {
        parentescoFinal = _otroController.text;
      }

      // 2. Convertir imágenes a Base64
      String? base64Frente = await _convertImageToBase64(_imageFrente);
      String? base64Reverso = await _convertImageToBase64(_imageReverso);

      // 3. Llamar al servicio
      // NOTA: El servicio ya usa HttpClient internamente, el cual inyecta el token.
      await AcompananteService.crearAcompanante(
        nombreCompleto: _nombreController.text,
        parentesco: parentescoFinal.isNotEmpty ? parentescoFinal : null,
        ineFrenteBase64: base64Frente,
        ineReversoBase64: base64Reverso,
      );

      // 4. Éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Acompañante registrado con éxito!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      // 5. MANEJO DE ERRORES CENTRALIZADO
      if (mounted) {
        // Aquí usamos el Helper. Si 'e' contiene "TOKEN_INVALIDO", el helper saca al usuario.
        AuthHelper.manejarError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (El resto de tu UI se mantiene exactamente igual)
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
                          // Campo Nombre Completo
                          _buildTextField('Nombre completo', circleColor: Colors.white, controller: _nombreController),
                          const SizedBox(height: 15),

                          // Menú Desplegable Parentesco
                          _buildParentescoDropdown(),
                          
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
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickImage(true), // Frente
                                  child: _buildFotoINE('Anverso', _imageFrente),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickImage(false), // Reverso
                                  child: _buildFotoINE('Reverso', _imageReverso),
                                ),
                              ),
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
                        onPressed: _isLoading ? null : _registrar, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 5,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Registrar', style: mBold(color: Colors.white, size: 16)),
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

  // ... (Tus widgets auxiliares _buildHeader, _buildTextField, etc. se quedan igual)
  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Registrar acompañante',
            style: mBold(size: 20, color: Colors.black),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: const Offset(10, 53),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/control_voz.png',
                  height: 60,
                  width: 60,
                  errorBuilder: (c, e, s) => const CircleAvatar(
                    backgroundColor: primaryBlue,
                    child: Icon(Icons.mic, color: Colors.white),
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
          // ignore: deprecated_member_use
          hintStyle: GoogleFonts.montserrat(
            color: primaryBlue.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
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
                  style: GoogleFonts.montserrat(
                    color: primaryBlue.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
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

  Widget _buildFotoINE(String label, File? imageFile) {
    return Column(
      children: [
        Container(
          height: 100,
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
            child: imageFile != null
                ? Image.file(imageFile, fit: BoxFit.cover)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: primaryBlue,
                          size: 30,
                        ),
                        Text(
                          "Tocar",
                          style: mBold(
                            size: 10,
                            color: primaryBlue.withOpacity(0.5),
                          ),
                        ),
                      ],
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