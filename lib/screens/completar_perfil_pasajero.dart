import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class CompletarPerfilPasajero extends StatefulWidget {
  const CompletarPerfilPasajero({super.key});

  @override
  State<CompletarPerfilPasajero> createState() =>
      _CompletarPerfilPasajeroState();
}

class _CompletarPerfilPasajeroState extends State<CompletarPerfilPasajero> {
  final Set<String> _selectedNeeds = {};
  bool _isListening = false;

  File? _ineAnverso;
  File? _ineReverso;
  final ImagePicker _picker = ImagePicker();

  void _toggleListening() => setState(() => _isListening = !_isListening);

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
              isVoiceActive: _isListening,
              onVoiceTap: _toggleListening,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),

            // Badge de estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white, size: 17),
                  const SizedBox(width: 7),
                  Text('Completar perfil',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sección INE
            Row(
              children: [
                Text('Foto de ',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                Text('INE',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
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
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildDocCard('Anverso', _ineAnverso, 'assets/ine_anverso.png', 'anverso')),
                const SizedBox(width: 15),
                Expanded(child: _buildDocCard('Reverso', _ineReverso, 'assets/ine_reverso.png', 'reverso')),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 28),

            // Sección necesidades
            RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                children: const [
                  TextSpan(text: '¿Presenta alguna '),
                  TextSpan(
                    text: 'necesidad especial',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Selecciona '),
                  TextSpan(
                    text: 'todas',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' las que apliquen a tu caso'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildNeedsGrid(),

            const SizedBox(height: 36),

            // Botón acompañante
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(
                  'Registrar un acompañante',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Guardar',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildDocCard(String label, File? file, String placeholder, String type) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: file != null ? AppColors.primary : AppColors.border,
                width: file != null ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: file != null
                  ? Image.file(file, fit: BoxFit.cover)
                  : Image.asset(placeholder, fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.add_a_photo_outlined, size: 32, color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 7),
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

  Widget _buildNeedsGrid() {
    final needs = [
      {'label': 'Tercera Edad', 'icon': 'assets/tercera_edad.png'},
      {'label': 'Movilidad reducida', 'icon': 'assets/silla_ruedas.png'},
      {'label': 'Disc. auditiva', 'icon': 'assets/auditiva.png'},
      {'label': 'Obesidad', 'icon': 'assets/obesidad.png'},
      {'label': 'Disc. visual', 'icon': 'assets/visual.png'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 14,
      children: needs.map((n) => _buildNeedItem(n['label']!, n['icon']!)).toList(),
    );
  }

  Widget _buildNeedItem(String label, String iconPath) {
    final isSelected = _selectedNeeds.contains(label);
    final itemWidth = (MediaQuery.of(context).size.width - 44 - 12 * 2) / 3;

    return GestureDetector(
      onTap: () => setState(() =>
          isSelected ? _selectedNeeds.remove(label) : _selectedNeeds.add(label)),
      child: SizedBox(
        width: itemWidth,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.07)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(iconPath,
                  height: 52,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.accessible, size: 52, color: AppColors.primary)),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
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
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

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
              'Completar Perfil',
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

  @override double get maxExtent => 80;
  @override double get minExtent => 80;
  @override bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}
