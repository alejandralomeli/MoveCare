import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/pagos/pagos_service.dart';
import '../core/utils/auth_helper.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';
// import 'widgets/passenger_bottom_nav.dart'; // Agregado porque se usa en el bottomNavigationBar

class RegistroTarjetaScreen extends StatefulWidget {
  const RegistroTarjetaScreen({super.key});

  @override
  State<RegistroTarjetaScreen> createState() => _RegistroTarjetaScreenState();
}

class _RegistroTarjetaScreenState extends State<RegistroTarjetaScreen> {
  bool _isLoading = false;
  bool _isVoiceActive = false;

  // Solo necesitamos el controlador para el nombre. Stripe maneja el resto.
  final TextEditingController _nombreCtrl = TextEditingController();
  
  // Variable para asegurar que el CardField esté completamente lleno
  bool _isCardComplete = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _toggleVoice() => setState(() => _isVoiceActive = !_isVoiceActive);

  Future<void> _guardarTarjeta() async {
    final nombre = _nombreCtrl.text.trim();

    // Validamos que haya un nombre y que Stripe nos diga que la tarjeta está completa
    if (nombre.isEmpty || !_isCardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verifica los campos. Llena todos los datos de la tarjeta."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Crear el método de pago real (Token)
      // Stripe leerá automáticamente los datos del CardField seguro
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: nombre),
          ),
        ),
      );

      // 2. Extraer datos para tu backend
      final tokenStripe = paymentMethod.id; 
      final ultimos4 = paymentMethod.card?.last4 ?? "****";
      final marca = paymentMethod.card?.brand ?? "Desconocida";

      // 3. Enviar a tu API
      await PagosService.agregarTarjeta(
        token: tokenStripe,
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
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.error.message ?? "Error validando la tarjeta en Stripe",
            ),
            backgroundColor: Colors.red,
          ),
        );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.white,
                          size: 17,
                        ),
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
                        
                        // Campo de Nombre
                        _buildTextField(
                          'Nombre Completo',
                          icon: Icons.person,
                          controller: _nombreCtrl,
                        ),
                        const SizedBox(height: 12),
                        
                        // WIDGET OFICIAL DE STRIPE (Con altura corregida)
                        Container(
                          height: 60, // Da espacio para que Stripe se renderice sin encimarse
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: CardField(
                            enablePostalCode: false, // Desactiva código postal para ahorrar espacio
                            onCardChanged: (card) {
                              setState(() {
                                _isCardComplete = card?.complete ?? false; 
                              });
                            },
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none, 
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: 'Número, Fecha y CVV',
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
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
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
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
      // Mantenemos tu índice en el BottomNav
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 5), 
    );
  }

  // Método auxiliar para el TextField del nombre
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
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          right: 15,
          bottom: -20,
          child: MicButton(
            isActive: isVoiceActive,
            onTap: onVoiceTap,
            size: 42,
          ),
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