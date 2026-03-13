import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io'; // Para File (solo móvil)
import 'package:image_picker/image_picker.dart';

import '../services/acompanante/acompanante_service.dart';
import '../core/utils/auth_helper.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class RegistrarAcompanante extends StatefulWidget {
  const RegistrarAcompanante({super.key});

  @override
  State<RegistrarAcompanante> createState() => _RegistrarAcompananteState();
}

class _RegistrarAcompananteState extends State<RegistrarAcompanante> {
  // --- CONTROLADORES Y ESTADO ---
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _otroController = TextEditingController();
  String? selectedParentesco;
  bool _isLoading = false;
  bool _isVoiceActive = false;

  // --- IMÁGENES (XFile para compatibilidad Web/Móvil) ---
  XFile? _imageFrente;
  XFile? _imageReverso;
  final ImagePicker _picker = ImagePicker();

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
  void dispose() {
    _nombreController.dispose();
    _otroController.dispose();
    super.dispose();
  }

  // --- ESTILOS DE TEXTO ---
  TextStyle mBold({Color color = AppColors.primary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  TextStyle mSemibold({Color color = AppColors.primary, double size = 13}) {
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
      backgroundColor: AppColors.white,
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
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildInfoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: AppColors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Ingrese los datos para registrar',
            style: mBold(color: AppColors.white, size: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMainForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          _buildTextField(
            'Nombre completo',
            icon: Icons.person,
            controller: _nombreController,
          ),
          const SizedBox(height: 15),
          _buildParentescoDropdown(),
          if (selectedParentesco == 'Otro') ...[
            const SizedBox(height: 10),
            _buildTextField(
              'Especifique parentesco',
              icon: Icons.people,
              controller: _otroController,
            ),
          ],
          const SizedBox(height: 25),
          Text(
            'Foto de INE / Identificación oficial',
            style: mBold(size: 13, color: AppColors.textPrimary),
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
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : Text('Registrar', style: mBold(color: AppColors.white, size: 16)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(color: AppColors.primaryLight),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 15,
            bottom: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: Text(
              'Registrar acompañante',
              style: mBold(size: 19, color: AppColors.textPrimary),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -26,
            child: MicButton(
              isActive: _isVoiceActive,
              onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
              size: 52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required IconData icon,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      style: mBold(size: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: mSemibold(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildParentescoDropdown() {
    return Container(
      padding: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.people, color: AppColors.textSecondary),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedParentesco,
                hint: Text(
                  'Parentesco',
                  style: mSemibold(color: AppColors.textSecondary),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _getImageWidget(imageFile, assetPath),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: mBold(size: 12, color: AppColors.primary)),
      ],
    );
  }

  Widget _getImageWidget(XFile? file, String assetPath) {
    if (file == null) return Image.asset(assetPath, fit: BoxFit.contain);
    if (kIsWeb) return Image.network(file.path, fit: BoxFit.cover);
    return Image.file(File(file.path), fit: BoxFit.cover);
  }

}
