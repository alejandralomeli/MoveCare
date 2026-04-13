import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

// --- WIDGETS Y SERVICIOS RECUPERADOS ---
import 'widgets/modals/viaje_detalles_modal.dart';
import 'widgets/home_map_preview.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../core/utils/auth_helper.dart';

// --- DEPENDENCIAS ACTUALES ---
import '../app_theme.dart';

class PrincipalConductor extends StatefulWidget {
  const PrincipalConductor({super.key});

  @override
  State<PrincipalConductor> createState() => _PrincipalConductorState();
}

class _PrincipalConductorState extends State<PrincipalConductor> {
  // --- VARIABLES DE LÓGICA RECUPERADAS ---
  bool _loadingHome = true;
  List<dynamic> _historialViajes = [];
  Map<String, dynamic>? _viajeProximo;

  // --- VARIABLES DE UI ACTUALES ---
  String _selectedDate = '';
  bool _isVoiceActive = false;
  DateTime _weekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  // --- FUNCIÓN RECUPERADA: Carga de Datos ---
  Future<void> _loadHome() async {
    try {
      final homeData = await HomeService.getHome(role: "conductor");
      final userProvider = context.read<UserProvider>();
      userProvider.setUserFromJson(homeData["usuario"]);

      if (homeData['viaje_proximo'] != null) {
        _viajeProximo = homeData['viaje_proximo'];
        final fechaViaje = DateTime.parse(_viajeProximo!['fecha_hora_inicio']);
        _buildCalendarDates(fechaViaje);
      } else {
        _buildCalendarDates(DateTime.now());
      }

      _historialViajes = homeData['historial'] ?? [];
      if (mounted) setState(() => _loadingHome = false);
    } catch (e) {
      if (mounted) AuthHelper.manejarError(context, e);
      if (mounted) setState(() => _loadingHome = false);
    }
  }

  // --- FUNCIÓN RECUPERADA: Llamadas ---
  Future<void> _hacerLlamada(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Teléfono no disponible")));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: telefono);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // --- Lógica del calendario actual ---
  void _buildCalendarDates(DateTime baseDate) {
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    _weekStart = monday;
    _selectedDate = baseDate.day.toString();
  }

  String _dayLetter(DateTime d) {
    const days = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    return days[d.weekday - 1];
  }

  String _dayNameFull(int d) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[d - 1];
  }

  String _monthName(int m) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[m - 1];
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
    // --- MANEJO DEL LOADER RECUPERADO ---
    if (_loadingHome) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
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
                _buildHeader(user), // Se inyecta el usuario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text('Viaje actual', style: mBold(size: 18)),
                      const SizedBox(height: 10),
                      _buildCurrentTripCard(), // Lógica inyectada
                      const SizedBox(height: 20),

                      // 🚀 LA INTEGRACIÓN CORRECTA DEL MAPA AQUÍ
                      _buildRouteSection(),

                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Próximos viajes', style: mBold(size: 18)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: AppColors.primary,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  final now = DateTime.now();
                                  final currentWeekStart = now.subtract(
                                    Duration(days: now.weekday - 1),
                                  );
                                  final prev = _weekStart.subtract(
                                    const Duration(days: 7),
                                  );
                                  if (!prev.isBefore(currentWeekStart)) {
                                    setState(() => _weekStart = prev);
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.primary,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(
                                  () => _weekStart = _weekStart.add(
                                    const Duration(days: 7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setState(() => _buildCalendarDates(picked));
                            }
                          },
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                          ),
                          label: const Text('Ver más'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Historial de viajes', style: mBold(size: 18)),
                      const SizedBox(height: 10),
                      _buildHistorySection(), // Iteración recuperada
                      // ¡AQUÍ SE ELIMINÓ EL BOTÓN ROJO GRANDE!
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Botón del micrófono sin animación respetando tu UI
          // Positioned(
          //   right: 20,
          //   top: 55,
          //   child: MicButton(
          //     isActive: _isVoiceActive,
          //     onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
          //     size: 45,
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 0),
    );
  }

  // ── HEADER (Con datos reales y diseño actual) ──────────────────────────────

  Widget _buildHeader(dynamic user) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          width: double.infinity,
          color: AppColors.primaryLight,
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundImage:
                  (user != null &&
                      user.fotoPerfil != null &&
                      user.fotoPerfil.isNotEmpty)
                  ? MemoryImage(base64Decode(user.fotoPerfil.split(',').last))
                  : const AssetImage('assets/conductor.png') as ImageProvider,
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
                user?.nombre ?? 'Bienvenido', // Nombre real inyectado
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
          Text(
            'Completa tu perfil',
            style: mBold(color: AppColors.white, size: 10),
          ),
        ],
      ),
    );
  }

  // ── VIAJE ACTUAL (Con datos reales, lógica de modales y diseño actual) ───────

  Widget _buildCurrentTripCard() {
    if (_viajeProximo == null) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Text(
            "Sin viajes próximos",
            style: mBold(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final fecha = DateTime.parse(_viajeProximo!['fecha_hora_inicio']);
    final hora =
        "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')} ${fecha.hour >= 12 ? 'PM' : 'AM'}";
    final fechaStr =
        "${_dayNameFull(fecha.weekday)} ${fecha.day} de ${_monthName(fecha.month)}";

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
                      fechaStr,
                      style: mBold(size: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _viajeProximo!['nombre_pasajero'] ?? 'Pasajero',
                      style: mBold(size: 15),
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
                  hora,
                  style: mBold(color: AppColors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _viajeProximo!['punto_inicio'] ?? 'Origen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mBold(color: AppColors.primary, size: 12),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const Icon(Icons.flag_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _viajeProximo!['destino'] ?? 'Destino',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mBold(color: AppColors.primary, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset('assets/movecare.png', width: 32, height: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _viajeProximo!['necesidad_especial'] ??
                      'Sin necesidades especiales',
                  style: mBold(size: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _actionBtn(
                'Ver detalles',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ViajeDetallesModal(
                      viaje: _viajeProximo!,
                      esConductor: true,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _actionBtn(
                'Contactar pasajero',
                onTap: () => _hacerLlamada(_viajeProximo!['telefono_pasajero']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, {required VoidCallback onTap}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: mBold(color: AppColors.white, size: 11),
        ),
      ),
    );
  }

  // ── MAPA / RUTA EXACTAMENTE COMO EN EL CÓDIGO VIEJO ────────────────────────

  Widget _buildRouteSection() {
    return HomeMapPreview(
      viajeProximo:
          _viajeProximo, // Sigue pasando el JSON completo para pintar el mapita
      onOpenRoute: () {
        // Verificamos que tengamos la información antes de navegar
        if (_viajeProximo != null && _viajeProximo!['id_viaje'] != null) {
          Navigator.pushReplacementNamed(
            context,
            '/viaje_actual',
            // 🚀 AQUÍ ENVIAMOS EL ID CORRECTO BASADO EN TU JSON
            arguments: _viajeProximo!['id_viaje'],
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se encontró el ID del viaje")),
          );
        }
      },
    );
  }

  // ── CALENDARIO ─────────────────────────────────────────────────────────────

  Widget _buildCalendarRow() {
    return Row(
      children: List.generate(
        7,
        (i) => _weekStart.add(Duration(days: i)),
      ).map((date) => Expanded(child: _calendarDay(date))).toList(),
    );
  }

  Widget _calendarDay(DateTime date) {
    final today = DateTime.now();
    final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
    final isSelected = _selectedDate == date.day.toString();
    return Opacity(
      opacity: isPast ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isPast
            ? null
            : () => setState(() => _selectedDate = date.day.toString()),
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
      ),
    );
  }

  // ── HISTORIAL (Lógica de mapeo y modales con diseño actual) ────────────────

  Widget _buildHistorySection() {
    if (_historialViajes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          "Aún no tienes historial de viajes",
          style: mBold(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: _historialViajes
          .take(3)
          .map((v) => _buildHistoryCard(v))
          .toList(),
    );
  }

  Widget _buildHistoryCard(dynamic viaje) {
    // Formatear la fecha si existe en el backend
    String fechaTexto = "Fecha N/A";
    if (viaje['fecha_hora_inicio'] != null) {
      final f = DateTime.parse(viaje['fecha_hora_inicio']);
      fechaTexto = "${_monthName(f.month).substring(0, 3)} ${f.day}";
    }

    // Distancia si existe en el backend
    String distancia = viaje['distancia_km'] != null
        ? "${viaje['distancia_km']} km"
        : "-- km";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  Text(
                    '$fechaTexto  —  ${viaje['nombre_pasajero'] ?? 'Pasajero'}',
                    style: mBold(color: AppColors.primary, size: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distancia: $distancia',
                    style: mBold(size: 12, color: AppColors.textSecondary),
                  ),
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
                    // 🚀 AQUÍ ENVIAMOS EL ID_VIAJE COMO ARGUMENTO
                    onTap: () {
                      if (viaje['id_viaje'] != null) {
                        Navigator.pushNamed(
                          context,
                          '/reporte_incidencia_conductor',
                          arguments: viaje['id_viaje'],
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Error: Este viaje no tiene ID asociado",
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reportar incidencia',
                          style: mBold(color: AppColors.error, size: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      ViajeDetallesModal(viaje: viaje, esConductor: true),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ver detalles',
                  style: mBold(color: AppColors.white, size: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
