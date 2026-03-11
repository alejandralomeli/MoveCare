import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class ViajeActualMapa extends StatefulWidget {
  const ViajeActualMapa({super.key});

  @override
  State<ViajeActualMapa> createState() => _ViajeActualMapaState();
}

class _ViajeActualMapaState extends State<ViajeActualMapa> {
  bool _isVoiceActive = false;

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sp(10, sw), vertical: sp(5, sw)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Viaje Actual', style: mBold(size: 20, sw: sw)),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: sp(15, sw)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/mapa.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.turn_right, color: AppColors.white, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'En 300m gire a la derecha por Av. Central',
                                  style: mBold(color: AppColors.white, size: 13, sw: sw),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 100,
                        right: 15,
                        child: MicButton(
                          isActive: _isVoiceActive,
                          onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
                          size: 52,
                        ),
                      ),

                      Positioned(
                        bottom: 15,
                        left: 15,
                        right: 15,
                        child: _buildRouteCard(sw),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(double sw) {
    return Container(
      padding: EdgeInsets.all(sp(15, sw)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('15 min', style: mBold(size: 22, color: Colors.green, sw: sw)),
                  Text('4.2 km - Llegada 10:45', style: mBold(size: 13, color: AppColors.textSecondary, sw: sw)),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('DETENER', style: mBold(color: AppColors.white, size: 12, sw: sw)),
                ),
              )
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              const CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/conductor.png')),
              const SizedBox(width: 10),
              Text('Juan Pérez', style: mBold(size: 14, sw: sw)),
              const Spacer(),
              const Icon(Icons.message, color: AppColors.primary),
              const SizedBox(width: 15),
              const Icon(Icons.phone, color: AppColors.primary),
            ],
          )
        ],
      ),
    );
  }
}
