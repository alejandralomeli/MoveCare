import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pagos/pagos_service.dart';
import '../core/utils/auth_helper.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class RegistroTarjetaScreen extends StatefulWidget {
  const RegistroTarjetaScreen({super.key});

  @override
  State<RegistroTarjetaScreen> createState() => _RegistroTarjetaScreenState();
}

class _RegistroTarjetaScreenState extends State<RegistroTarjetaScreen> {
  bool _isLoading = false;
  bool _isVoiceActive = false;

  final TextEditingController _numeroCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _expiraCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _nombreCtrl.dispose();
    _expiraCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _toggleVoice() => setState(() => _isVoiceActive = !_isVoiceActive);

  Future<void> _guardarTarjeta() async {
    final numero = _numeroCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();
    final expira = _expiraCtrl.text.trim();
    final cvv = _cvvCtrl.text.trim();

    if (numero.length < 16 || nombre.isEmpty || expira.isEmpty || cvv.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor verifica todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ultimos4 = numero.substring(numero.length - 4);
      final tokenSimulado = "tok_${DateTime.now().millisecondsSinceEpoch}";
      String marca = numero.startsWith("4")
          ? "visa"
          : (numero.startsWith("5") ? "mastercard" : "Desconocida");

      await PagosService.agregarTarjeta(
        token: tokenSimulado,
        ultimosCuatro: ultimos4,
        marca: marca,
        alias: "Tarjeta de $nombre",
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Tarjeta guardada con éxito!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.white, size: 17),
                        const SizedBox(width: 8),
                        Text(
                          'Ingrese los datos de su tarjeta',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/tarjeta.png',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.credit_card,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          'Número de la tarjeta',
                          icon: Icons.credit_card,
                          controller: _numeroCtrl,
                          inputType: TextInputType.number,
                          maxLength: 16,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          'Nombre Completo',
                          icon: Icons.person,
                          controller: _nombreCtrl,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                'Fecha Exp (MM/AA)',
                                icon: Icons.calendar_today,
                                controller: _expiraCtrl,
                                inputType: TextInputType.datetime,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                'CVV',
                                icon: Icons.lock,
                                controller: _cvvCtrl,
                                inputType: TextInputType.number,
                                maxLength: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarTarjeta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : Text(
                              'Agregar Tarjeta',
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
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildTextField(
    String hint, {
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
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
              'Agregar Tarjeta',
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
