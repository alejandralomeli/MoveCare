import 'package:flutter/foundation.dart'; // NECESARIO PARA kIsWeb
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

class _RegistrarAcompananteState extends State<RegistrarAcompanante> {
  // --- COLORES RESTAURADOS (Estilo Tarjeta) ---
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4); // Botones
  static const Color textFieldBlue = Color(0xFFB3D4FF); // Inputs Claros

  int _selectedIndex = 3;

  // --- CONTROLADORES Y ESTADO ---
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _otroController = TextEditingController();
  String? selectedParentesco;

  // --- CAMBIO 1: Usamos XFile para compatibilidad Web/Móvil ---
  XFile? _imageFrente;
  XFile? _imageReverso;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> parentescos = [
    'Mamá',
    'Papá',
    'Hijo/Hija',
    'Hermano/Hermana',
    'Tío/Tía',
    'Pareja',
    'Otro',
  ];

  // Estilos de Texto
  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  TextStyle mSemibold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  // --- LÓGICA DE FOTOS (Web y Móvil) ---
  Future<void> _pickImage(bool isFrente) async {
    try {
      // Nota: imageQuality reduce el tamaño para que suba rápido
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (photo != null) {
        setState(() {
          if (isFrente) {
            _imageFrente = photo; // Guardamos como XFile directo
          } else {
            _imageReverso = photo;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  // --- CONVERSIÓN BASE64 (Compatible Web) ---
  Future<String?> _convertImageToBase64(XFile? image) async {
    if (image == null) return null;
    // readAsBytes funciona tanto en web como en móvil con XFile
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
      String parentescoFinal = selectedParentesco ?? '';
      if (selectedParentesco == 'Otro') {
        parentescoFinal = _otroController.text;
      }

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
      if (mounted) {
        AuthHelper.manejarError(context, e);
      }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    // Badge Informativo (Estilo Tarjeta)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ingrese los datos para registrar',
                            style: mBold(color: Colors.white, size: 13),
                          ),
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
                          _buildTextField(
                            'Nombre completo',
                            circleColor: Colors.white,
                            controller: _nombreController,
                          ),
                          const SizedBox(height: 15),

                          // Menú Desplegable Parentesco
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
                          Center(
                            child: Text(
                              'Foto de INE / Identificación oficial',
                              style: mBold(size: 13, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // FOTOS INE (Con imágenes personalizadas)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickImage(true), // Frente
                                  child: _buildFotoINE(
                                    'Anverso',
                                    _imageFrente,
                                    'assets/ine_anverso.png', // Tu imagen personalizada
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickImage(false), // Reverso
                                  child: _buildFotoINE(
                                    'Reverso',
                                    _imageReverso,
                                    'assets/ine_reverso.png', // Tu imagen personalizada
                                  ),
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
                      width: 200,
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Registrar',
                                style: mBold(color: Colors.white, size: 16),
                              ),
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
        color: textFieldBlue, // Color del estilo viejo
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        style: mBold(size: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: mSemibold(color: primaryBlue.withOpacity(0.6), size: 13),
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
                  style: mSemibold(
                    color: primaryBlue.withOpacity(0.6),
                    size: 13,
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

  // --- WIDGET DE FOTO ACTUALIZADO (Solución Web + Assets) ---
  Widget _buildFotoINE(String label, XFile? imageFile, String assetPath) {
    return Column(
      children: [
        Container(
          height: 110, // Un poco más alto para ver bien la INE
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

  // Función auxiliar para decidir qué imagen mostrar
  Widget _getImageWidget(XFile? file, String assetPath) {
    // 1. Si no hay foto seleccionada, mostrar la imagen por defecto (asset)
    if (file == null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.contain, // Contain para que se vea toda la guía de la INE
        errorBuilder: (context, error, stackTrace) {
          // Si fallara al cargar el asset, mostrar icono
          return const Center(
            child: Icon(Icons.camera_alt, size: 40, color: Colors.grey),
          );
        },
      );
    }

    // 2. Si hay foto y es WEB
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.cover);
    }

    // 3. Si hay foto y es MÓVIL (Android/iOS)
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
          _navIcon(3, Icons.person, '/mi_perfil_pasajero'),
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
              ),
          ],
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}
