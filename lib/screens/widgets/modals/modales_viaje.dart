import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app_theme.dart'; // Ajusta la ruta

class ModalesViaje {
  
  // ── MODAL DE PIN ──
  static void mostrarModalPin(
      BuildContext context, Function(String) onPinIngresado) {
    final TextEditingController pinController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresa el PIN del pasajero',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onPinIngresado(pinController.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Validar PIN',
                  style: GoogleFonts.montserrat(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── MODAL FIN DE VIAJE (DINÁMICO) ──
  static void mostrarFinViaje({
    required BuildContext context,
    required String idMetodo,
    required double costo,
    required VoidCallback onFinalizar,
  }) {
    // Si el id_metodo es 'efectivo' o viene nulo, asumimos efectivo.
    bool esEfectivo = idMetodo.toLowerCase() == 'efectivo' || idMetodo.isEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Ícono y color dinámico según el método de pago
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: esEfectivo 
                    ? Colors.orange.withValues(alpha: 0.1) 
                    : AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                esEfectivo ? Icons.payments_outlined : Icons.credit_card_rounded,
                color: esEfectivo ? Colors.orange : AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            
            // Textos dinámicos
            Text(
              esEfectivo ? 'Cobro en Efectivo' : 'Viaje Completado',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              esEfectivo 
                  ? 'Por favor, cobra \$${costo.toStringAsFixed(2)} MXN al pasajero.' 
                  : 'El cobro de \$${costo.toStringAsFixed(2)} MXN se realizará automáticamente a su tarjeta.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.montserrat(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Cierra el modal
                      onFinalizar(); // Ejecuta la función de cierre
                    },
                    style: ElevatedButton.styleFrom(
                      // Botón naranja para efectivo, verde para tarjeta
                      backgroundColor: esEfectivo ? Colors.orange : AppColors.success,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirmar',
                      style: GoogleFonts.montserrat(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}