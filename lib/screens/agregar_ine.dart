import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class AgregarIne extends StatefulWidget {
  const AgregarIne({super.key});

  @override
  State<AgregarIne> createState() => _AgregarIneState();
}

class _AgregarIneState extends State<AgregarIne> {
  bool _isVoiceActive = false;
  File? _ineAnverso;
  File? _ineReverso;

  final ImagePicker _picker = ImagePicker();

  void _toggleVoice() => setState(() => _isVoiceActive = !_isVoiceActive);

  Future<void> _pickImage(String tipo, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (tipo == 'anverso') _ineAnverso = File(image.path);
        if (tipo == 'reverso') _ineReverso = File(image.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context, String tipo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(tipo, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galería / Archivos'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(tipo, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              title: 'Agregar INE',
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  _buildCompleteProfileBanner(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Foto de ',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          )),
                      Text('INE',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Sube una foto clara del anverso y reverso',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      )),
                  const SizedBox(height: 20),
                  _buildIneCard(
                    'Anverso',
                    _ineAnverso,
                    'assets/ine_anverso.png',
                    () => _showImageSourceActionSheet(context, 'anverso'),
                  ),
                  const SizedBox(height: 20),
                  _buildIneCard(
                    'Reverso',
                    _ineReverso,
                    'assets/ine_reverso.png',
                    () => _showImageSourceActionSheet(context, 'reverso'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 4),
    );
  }

  Widget _buildIneCard(
      String label, File? image, String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: image != null ? AppColors.primary : AppColors.border,
                width: image != null ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: image != null
                  ? Image.file(image, fit: BoxFit.cover)
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(asset,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(
                              Icons.add_a_photo_outlined,
                              size: 36,
                              color: AppColors.primary)),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.error, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text('Completar perfil',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              )),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate(
      {required this.title,
      required this.isVoiceActive,
      required this.onVoiceTap});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          right: 15,
          bottom: -20,
          child: MicButton(isActive: isVoiceActive, onTap: onVoiceTap, size: 42),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}
