import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';
import '../services/voz/voz_mixin.dart';

class ViajeConfirmado extends StatefulWidget {
  const ViajeConfirmado({super.key});

  @override
  State<ViajeConfirmado> createState() => _ViajeConfirmadoState();
}

class _ViajeConfirmadoState extends State<ViajeConfirmado> with VozMixin {
  @override
  String get vozEjemplos => '"Estado de mi viaje", "Inicio", "Atrás"';

  @override
  void initState() {
    super.initState();
    inicializarVoz();
  }

  TextStyle mBold({Color color = AppColors.primary, double size = 14, FontWeight weight = FontWeight.w800}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/ruta.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            Positioned(
              top: 20,
              right: 20,
              child: MicButton(
                isActive: vozEscuchando || vozProcesando,
                onTap: () => escucharComando({
                  'ir_atras': (_) => Navigator.pop(context),
                  'cancelar_viaje': (_) => Navigator.pop(context),
                }),
                size: 52,
              ),
            ),

            // 4. Título central
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Viaje confirmado',
                  style: mBold(size: 22, color: AppColors.textPrimary, weight: FontWeight.w900),
                ),
              ),
            ),

            // 5. Card de Detalles
            Align(
              alignment: Alignment.center,
              child: _buildInfoCard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalles del viaje', style: mBold(size: 18, color: AppColors.primary)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildLocationRow(Icons.location_on, 'Desde', 'Donde comenzará el viaje', hasLine: true),
                    _buildLocationRow(Icons.location_on, 'Destino', 'Destino de llegada'),
                    const SizedBox(height: 25),
                    _buildDetailRow(Icons.access_time_filled, '10 : 30 am'),
                    _buildDetailRow(Icons.location_on, 'Destino'),
                    _buildDetailRow(Icons.monetization_on, 'Costo'),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: "ID_VIAJE_MOVECARE",
                        version: QrVersions.auto,
                        size: 110.0,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String title, String subtitle, {bool hasLine = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            if (hasLine)
              Container(
                width: 1.5,
                height: 35,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: mBold(size: 11, color: AppColors.primary)),
              Text(subtitle, style: mBold(size: 13, color: AppColors.textPrimary, weight: FontWeight.w600)),
              if (hasLine) ...[
                const SizedBox(height: 5),
                const Text('-------------------------------------',
                  style: TextStyle(letterSpacing: -1.5, color: AppColors.border, fontSize: 10)),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Text(text, style: mBold(size: 13, color: AppColors.textPrimary, weight: FontWeight.w600)),
        ],
      ),
    );
  }

}
