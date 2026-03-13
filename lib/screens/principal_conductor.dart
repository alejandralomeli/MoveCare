import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

// --- TUS IMPORTS REALES ---
import '../app_theme.dart'; 
import 'widgets/modals/viaje_detalles_modal.dart';
import 'widgets/home_map_preview.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../core/utils/auth_helper.dart';

class PrincipalConductor extends StatefulWidget {
  const PrincipalConductor({super.key});

  @override
  State<PrincipalConductor> createState() => _PrincipalConductorState();
}

class _PrincipalConductorState extends State<PrincipalConductor> with TickerProviderStateMixin {
  
  // --- VARIABLES DE ESTADO Y LÓGICA ---
  bool _loadingHome = true;
  String _selectedDate = '';
  DateTime _weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  List<DateTime> _calendarDates = [];
  
  Map<String, dynamic>? _viajeProximo;
  List<dynamic> _historialViajes = [];
  
  // Variables para la animación de voz
  bool _isVoiceActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadHome();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _loadHome() async {
    try {
      final homeData = await HomeService.getHome(role: "conductor");
      if (!mounted) return;
      
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
      setState(() => _loadingHome = false);
    } catch (e) {
      AuthHelper.manejarError(context, e);
      setState(() => _loadingHome = false);
    }
  }

  void _buildCalendarDates(DateTime baseDate) {
    final monday = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    _weekStart = monday;
    _selectedDate = baseDate.day.toString();
    _calendarDates = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
  }

  // --- ACCIONES ---
  Future<void> _hacerLlamada(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teléfono no disponible"))
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: telefono);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }
  
  String _dayLetter(DateTime d) {
    const days = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    return days[d.weekday - 1];
  }

  // --- RENDERIZADO PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    if (_loadingHome) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                _buildHeader(user),
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
                      
                      // Tu componente real del mapa
                      _buildRouteSection(), 
                      const SizedBox(height: 25),
                      
                      // Calendario (Diseño Repo + Lógica tuya)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Próximos viajes', style: mBold(size: 18)),
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
                                    setState(() {
                                      _weekStart = prev;
                                      _calendarDates = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
                                    });
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() {
                                  _weekStart = _weekStart.add(const Duration(days: 7));
                                  _calendarDates = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
                                }),
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
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _buildCalendarDates(picked));
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
                      _buildHistorySection(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: QUITE ESTO PARA EVITAR EL ERROR DEL IMPORT FALTANTE
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildHeader(dynamic user) {
    // Fusión: Estilo Stack del Repo, pero con tu lógica de avatar y botón animado
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
              backgroundImage: (user != null && user.fotoPerfil.isNotEmpty)
                  ? MemoryImage(base64Decode(user.fotoPerfil.split(',').last))
                  : const AssetImage('assets/conductor.png') as ImageProvider,
            ),
          ),
        ),
        Positioned(
          bottom: -25,
          left: 130,
          right: 20, // Agregado para alinear el botón de voz a la derecha
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
              // Tu botón animado de voz
              GestureDetector(
                onTap: () => setState(() {
                  _isVoiceActive = !_isVoiceActive;
                  _isVoiceActive
                      ? _pulseController.repeat(reverse: true)
                      : _pulseController.reset();
                }),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Image.asset(
                    _isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                    width: 45,
                    height: 45,
                  ),
                ),
              ),
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
          const Icon(Icons.check_circle_outline, color: AppColors.white, size: 12),
          const SizedBox(width: 4),
          Text('Conductor Activo', style: mBold(color: AppColors.white, size: 10)),
        ],
      ),
    );
  }

  Widget _buildCurrentTripCard() {
    if (_viajeProximo == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Text("Sin viajes próximos", style: mBold(color: AppColors.primary)),
        ),
      );
    }

    final fecha = DateTime.parse(_viajeProximo!['fecha_hora_inicio']);
    final hora = "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

    // Diseño del Repo, datos de tu Backend
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
                    Text('Hoy - ${fecha.day}/${fecha.month}', style: mBold(size: 13, color: AppColors.textSecondary ?? Colors.grey)),
                    const SizedBox(height: 2),
                    Text(_viajeProximo!['nombre_pasajero'] ?? 'Pasajero', style: mBold(size: 15)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(hora, style: mBold(color: AppColors.white, size: 12)),
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
                child: Text(_viajeProximo!['punto_inicio'] ?? 'Origen', style: mBold(color: AppColors.primary, size: 13), overflow: TextOverflow.ellipsis),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
              ),
              const Icon(Icons.flag_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(_viajeProximo!['destino'] ?? 'Destino', style: mBold(color: AppColors.primary, size: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _actionBtn('Ver detalles', AppColors.primary, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ViajeDetallesModal(
                    viaje: _viajeProximo!,
                    esConductor: true,
                  ),
                );
              }),
              const SizedBox(width: 10),
              _actionBtn('Contactar pasajero', AppColors.primary, () {
                 _hacerLlamada(_viajeProximo!['telefono_pasajero']);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bgColor, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label, textAlign: TextAlign.center, style: mBold(color: AppColors.white, size: 11)),
      ),
    );
  }

  Widget _buildRouteSection() {
    // Tu widget de mapa real inyectado perfectamente
    final latLngConductorActual = const LatLng(20.676667, -103.3475);

    return HomeMapPreview(
      viajeProximo: _viajeProximo,
      ubicacionConductor: latLngConductorActual,
      onOpenRoute: () {
        if (_viajeProximo == null) return;
        final idViaje = _viajeProximo!['id_viaje'] ?? _viajeProximo!['id'];
        Navigator.pushNamed(
          context,
          '/viaje_actual',
          arguments: {'id_viaje': idViaje},
        );
      },
    );
  }

  Widget _buildCalendarRow() {
    return Row(
      children: _calendarDates.map((date) => Expanded(child: _calendarDay(date))).toList(),
    );
  }

  Widget _calendarDay(DateTime date) {
    final today = DateTime.now();
    final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
    final isSelected = _selectedDate == date.day.toString();
    
    return Opacity(
      opacity: isPast ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isPast ? null : () => setState(() => _selectedDate = date.day.toString()),
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

  Widget _buildHistorySection() {
    if (_historialViajes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text("No hay viajes en el historial", style: mBold(color: Colors.grey)),
      );
    }
    
    return Column(
      children: _historialViajes.map((viaje) => _buildHistoryCard(viaje)).toList(),
    );
  }

  Widget _buildHistoryCard(dynamic viaje) {
    // Extracción segura de datos
    final pasajero = viaje['nombre_pasajero'] ?? 'Pasajero';
    final distancia = viaje['distancia'] ?? '--';
    final calificacion = viaje['calificacion'] ?? 0;
    
    String fechaStr = "Fecha";
    if (viaje['fecha'] != null) {
      try {
        final d = DateTime.parse(viaje['fecha']);
        final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
        fechaStr = "${meses[d.month - 1]} ${d.day}";
      } catch (_) {}
    }

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
                  Text('$fechaStr  —  $pasajero',
                      style: mBold(color: AppColors.primary, size: 13)),
                  const SizedBox(height: 4),
                  Text('Distancia: $distancia km',
                      style: mBold(size: 12, color: AppColors.textSecondary ?? Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        color: i < calificacion ? Colors.orange : AppColors.border,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navegar a detalles del historial
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Ver detalles', style: mBold(color: AppColors.white, size: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}