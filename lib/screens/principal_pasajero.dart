import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/map_widget.dart';
import 'widgets/mic_button.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../core/utils/auth_helper.dart';
import '../app_theme.dart';

class PrincipalPasajero extends StatefulWidget {
  const PrincipalPasajero({super.key});

  @override
  State<PrincipalPasajero> createState() => _PrincipalPasajeroState();
}

class _PrincipalPasajeroState extends State<PrincipalPasajero> {
  // Estado lógico
  bool _loadingHome = true;
  bool _isListening = false;
  String _selectedDateNum = '';

  DateTime _weekStart = DateTime.now();
  Map<String, dynamic>? _viajeProximo;
  List<dynamic> _historialViajes = [];

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _loadHome() async {
    try {
      final homeData = await HomeService.getHome(role: "pasajero");
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      userProvider.setUserFromJson(homeData["usuario"]);

      if (homeData['viaje_proximo'] != null) {
        final fechaViaje = DateTime.parse(
          homeData['viaje_proximo']['fecha_hora_inicio'],
        );
        _viajeProximo = homeData['viaje_proximo'];
        _buildCalendarDates(fechaViaje);
      } else {
        _buildCalendarDates(DateTime.now());
      }

      _historialViajes = homeData['historial'] ?? [];
      setState(() => _loadingHome = false);
    } catch (e) {
      if (!mounted) return;
      AuthHelper.manejarError(context, e);
    }
  }

  void _buildCalendarDates(DateTime baseDate) {
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    _selectedDateNum = baseDate.day.toString();
    _weekStart = monday;
  }

  String _dayLetter(DateTime d) {
    const days = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    return days[d.weekday - 1];
  }

  // --- INTERFAZ DE VOZ ---
  void _toggleListening() {
    setState(() => _isListening = !_isListening);
  }

  // --- MODAL AGENDAR ---
  void _mostrarPanelAgendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _bottomSheetContent(context),
    );
  }

  // --- HELPERS DE ESTILO ---
  TextStyle mExtrabold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHome) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user?.nombre ?? 'Usuario'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 60,
                      ), // Espacio para el header flotante
                      Text('Ubicación actual', style: mExtrabold(size: 18)),
                      const SizedBox(height: 10),
                      _buildMapSection(),
                      const SizedBox(height: 25),
                      Text('Próximo viaje', style: mExtrabold(size: 18)),
                      const SizedBox(height: 10),
                      _buildNextTripCard(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Seleccionar fecha', style: mExtrabold(size: 16)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  final now = DateTime.now();
                                  final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
                                  final prev = _weekStart.subtract(const Duration(days: 7));
                                  if (!prev.isBefore(currentWeekStart)) {
                                    setState(() => _weekStart = prev);
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildCalendarRow(),
                      const SizedBox(height: 8),
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
                              setState(() {
                                _buildCalendarDates(picked);
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_outlined, size: 16),
                          label: const Text('Ver más'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ),
                      Center(child: _buildAgendarButton()),
                      const SizedBox(height: 25),
                      Text('Historial de viajes', style: mExtrabold(size: 18)),
                      const SizedBox(height: 10),
                      _buildTripHistory(),
                      const SizedBox(height: 30),
                      _buildReportButton(),
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
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 0),
    );
  }

  // --- WIDGETS COMPONENTES ---

  Widget _buildHeader(String name) {
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
            child: CircleAvatar(
              radius: 46,
              backgroundImage: AssetImage('assets/pasajero.png'),
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
              Text(name, style: mExtrabold(size: 15, color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceButton() {
    return Positioned(
      top: 60,
      right: 20,
      child: MicButton(
        isActive: _isListening,
        onTap: _toggleListening,
        size: 42,
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const MapWidget(),
      ),
    );
  }

  Widget _buildNextTripCard() {
    if (_viajeProximo == null) {
      return Text(
        "No tienes viajes programados",
        style: mExtrabold(color: AppColors.textSecondary),
      );
    }
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
                    Text(
                      _viajeProximo!['destino'] ?? 'Destino',
                      style: mExtrabold(size: 16),
                    ),
                    Text(
                      'Conductor: ${_viajeProximo!['nombre_conductor'] ?? 'Asignando...'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '9:30 AM',
                  style: mExtrabold(color: AppColors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionBtn('Ver detalles'),
              const SizedBox(width: 10),
              _actionBtn('Cancelar'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarRow() {
    return Row(
      children: List.generate(7, (i) => _weekStart.add(Duration(days: i))).map((date) => Expanded(
        child: _calendarDay(date),
      )).toList(),
    );
  }

  Widget _calendarDay(DateTime date) {
    final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final isSelected = _selectedDateNum == date.day.toString();

    return GestureDetector(
      onTap: isPast ? null : () => setState(() => _selectedDateNum = date.day.toString()),
      child: Opacity(
        opacity: isPast ? 0.4 : 1.0,
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
                  _dayLetter(date),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: mExtrabold(color: AppColors.primary, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripHistory() {
    if (_historialViajes.isEmpty) return const Text("Sin historial");
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: _historialViajes.take(3).map((v) => _historyItem(v)).toList(),
      ),
    );
  }

  Widget _historyItem(dynamic viaje) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(
            "Oct 28",
            style: mExtrabold(size: 12),
          ), // Deberías parsear viaje['fecha']
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              viaje['destino'] ?? 'Viaje',
              style: mExtrabold(color: AppColors.primary, size: 13),
            ),
          ),
          Text(
            viaje['estado'] ?? 'Finalizado',
            style: mExtrabold(color: AppColors.error, size: 10),
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
        ),
        child: Text(label, style: mExtrabold(color: AppColors.white, size: 11)),
      ),
    );
  }

  Widget _buildAgendarButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _mostrarPanelAgendar(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text('Agendar viaje', style: mExtrabold(color: AppColors.white)),
      ),
    );
  }

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.error, color: AppColors.white),
        label: Text(
          'Reportar incidencia',
          style: mExtrabold(color: AppColors.white, size: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 219, 26, 26),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _bottomSheetContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Tipo de Viaje',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 28),

          // BOTÓN 1: Un destino -> /agendar_viaje
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agendar_viaje');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Un destino',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // BOTÓN 2: Varios destinos -> /agendar_varios_destinos
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agendar_varios_destinos');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Dos o más destinos',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

}
