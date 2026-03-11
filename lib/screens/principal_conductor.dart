import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart';

class PrincipalConductor extends StatefulWidget {
  const PrincipalConductor({super.key});

  @override
  State<PrincipalConductor> createState() => _PrincipalConductorState();
}

class _PrincipalConductorState extends State<PrincipalConductor> {
  String _selectedDate = '';
  bool _isVoiceActive = false;
  List<DateTime> _calendarDates = [];

  @override
  void initState() {
    super.initState();
    _buildCalendarDates(DateTime.now());
  }

  void _buildCalendarDates(DateTime baseDate) {
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    setState(() {
      _calendarDates = List.generate(5, (i) => monday.add(Duration(days: i)));
      _selectedDate = baseDate.day.toString();
    });
  }

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text('Viaje actual', style: mBold(size: 18)),
                      const SizedBox(height: 10),
                      _buildCurrentTripCard(),
                      const SizedBox(height: 20),
                      _buildRouteSection(),
                      const SizedBox(height: 25),
                      Text('Próximos viajes', style: mBold(size: 18)),
                      const SizedBox(height: 10),
                      _buildCalendarRow(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              _buildCalendarDates(picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_month_outlined, size: 16),
                          label: const Text('Ver más'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Historial de viajes', style: mBold(size: 18)),
                      const SizedBox(height: 10),
                      _buildHistoryCard(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildVoiceButton(),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 0),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: 80, width: double.infinity, color: AppColors.primaryLight),
        Positioned(
          bottom: -50,
          left: 20,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.white,
            child: const CircleAvatar(
              radius: 46,
              backgroundImage: AssetImage('assets/conductor.png'),
            ),
          ),
        ),
        Positioned(
          bottom: -25,
          left: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido!',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildBadgeStatus(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceButton() {
    return Positioned(
      top: 14,
      right: 20,
      child: MicButton(
        isActive: _isVoiceActive,
        onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
        size: 52,
      ),
    );
  }

  Widget _buildBadgeStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: AppColors.white, size: 12),
          const SizedBox(width: 4),
          Text('Completa tu perfil', style: mBold(color: AppColors.white, size: 10)),
        ],
      ),
    );
  }

  // ── VIAJE ACTUAL ──────────────────────────────────────────────────────────

  Widget _buildCurrentTripCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Martes 28 Octubre', style: mBold(size: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('Nombre del pasajero', style: mBold(size: 15)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('9:30 AM', style: mBold(color: AppColors.white, size: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text('Origen', style: mBold(color: AppColors.primary, size: 14)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 20),
              ),
              const Icon(Icons.flag_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: 4),
              Text('Destino', style: mBold(color: AppColors.primary, size: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset('assets/movecare.png', width: 32, height: 32),
              const SizedBox(width: 8),
              Text('Necesidades especiales', style: mBold(size: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _actionBtn('Ver detalles'),
              const SizedBox(width: 10),
              _actionBtn('Contactar pasajero'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label, textAlign: TextAlign.center, style: mBold(color: AppColors.white, size: 11)),
      ),
    );
  }

  // ── MAPA / RUTA ────────────────────────────────────────────────────────────

  Widget _buildRouteSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: AppColors.primary,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.white),
                    ),
                    child: Text('Abrir ruta', style: mBold(color: AppColors.white, size: 12)),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Image.asset('assets/mapa.png', fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }

  // ── CALENDARIO ─────────────────────────────────────────────────────────────

  Widget _buildCalendarRow() {
    return Row(
      children: _calendarDates.map((date) => Expanded(child: _calendarDay(date))).toList(),
    );
  }

  Widget _calendarDay(DateTime date) {
    bool isSelected = _selectedDate == date.day.toString();
    String dayLetter = ['D', 'L', 'M', 'M', 'J', 'V', 'S'][date.weekday % 7];
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date.day.toString()),
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                dayLetter,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: GoogleFonts.montserrat(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HISTORIAL ──────────────────────────────────────────────────────────────

  Widget _buildHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oct 13  —  Nombre del pasajero',
                      style: mBold(color: AppColors.primary, size: 13)),
                  const SizedBox(height: 4),
                  Text('Distancia: 10 km',
                      style: mBold(size: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        color: i < 4 ? Colors.orange : AppColors.border,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 14),
                        const SizedBox(width: 4),
                        Text('Reportar incidencia',
                            style: mBold(color: AppColors.error, size: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Ver detalles', style: mBold(color: AppColors.white, size: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
