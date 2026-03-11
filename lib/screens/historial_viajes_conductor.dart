import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class HistorialViajesConductor extends StatefulWidget {
  const HistorialViajesConductor({super.key});

  @override
  State<HistorialViajesConductor> createState() =>
      _HistorialViajesConductorState();
}

class _HistorialViajesConductorState extends State<HistorialViajesConductor> {
  String _filterSelected = 'Todos';
  bool _isVoiceActive = false;

  final List<String> filters = [
    'Todos',
    'En proceso',
    'Aceptados',
    'Rechazados',
  ];

  TextStyle mFont({
    Color color = AppColors.primary,
    double size = 14,
    FontWeight weight = FontWeight.w600,
  }) {
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
      appBar: AppHeader(
        title: 'Historial de Viajes',
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: MicButton(
            isActive: _isVoiceActive,
            onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
            size: 42,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFilterMenu(),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildTripCard(
                  'En Curso',
                  AppColors.primary,
                  'Origen ejemplo',
                  'Destino ejemplo',
                  'Nov 27, 2025',
                  'Pasajero Uno',
                  'auditiva.png',
                ),
                _buildTripCard(
                  'Aceptado',
                  const Color(0xFF16A34A),
                  'Hospital General',
                  'Col. Las Flores',
                  'Nov 20, 2025',
                  'Pasajero Dos',
                  'silla_ruedas.png',
                ),
                _buildTripCard(
                  'Rechazado',
                  AppColors.error,
                  'Centro Médico',
                  'Av. Insurgentes 420',
                  'Nov 15, 2025',
                  'Pasajero Tres',
                  'tercera_edad.png',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildFilterMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = _filterSelected == filter;
          return GestureDetector(
            onTap: () => setState(() => _filterSelected = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: mFont(
                  color: isSelected ? AppColors.white : AppColors.primary,
                  size: 13,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripCard(
    String status,
    Color statusColor,
    String origen,
    String destino,
    String date,
    String pasajero,
    String iconAsset,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 45,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                status,
                style: mFont(
                  color: AppColors.white,
                  size: 11,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        origen,
                        style: mFont(
                          size: 14,
                          color: AppColors.textPrimary,
                          weight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        destino,
                        textAlign: TextAlign.end,
                        style: mFont(
                          size: 14,
                          color: AppColors.textPrimary,
                          weight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fecha: $date',
                  style: mFont(
                    size: 12,
                    color: AppColors.primary,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: AssetImage('assets/$iconAsset'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pasajero,
                          style: mFont(
                            size: 14,
                            color: AppColors.textPrimary,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppColors.white, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: mFont(
                                      color: AppColors.white,
                                      size: 9,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
