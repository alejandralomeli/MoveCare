import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart'; 

// Widgets propios
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
  // Paleta de colores oficial
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color buttonLightBlue = Color(0xFF64A1F4);

  bool _loadingHome = true;
  int _selectedIndex = 0; // Home es 0
  String _selectedDateNum = '';
  bool _isVoiceActive = false;

  List<DateTime> _calendarDates = [];
  List<dynamic> _historialViajes = [];
  Map<String, dynamic>? _viajeProximo;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
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
    _calendarDates = List.generate(5, (i) => baseDate.add(Duration(days: i - 2)));
    _selectedDateNum = baseDate.day.toString();
  }

  // --- ACCIONES ---
  Future<void> _hacerLlamada(String? telefono) async {
    if (telefono == null || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Teléfono no disponible")));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: telefono);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  TextStyle mBold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(color: color, fontSize: size, fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHome) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryBlue)));
    }

    final user = context.watch<UserProvider>().user;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(size, user),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Text('Viaje actual', style: mBold(size: 18)),
                  const SizedBox(height: 10),
                  _buildCurrentTripCard(), 
                  const SizedBox(height: 20),
                  _buildRouteSection(), 
                  const SizedBox(height: 25),
                  Text('Próximos viajes', style: mBold(size: 18)),
                  const SizedBox(height: 15),
                  _buildCalendarRow(),
                  const SizedBox(height: 25),
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
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  // --- COMPONENTES ---

  Widget _buildHeader(Size size, dynamic user) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: 120, width: double.infinity, color: lightBlueBg),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: (user != null && user.fotoPerfil.isNotEmpty)
                      ? MemoryImage(base64Decode(user.fotoPerfil.split(',').last))
                      : const AssetImage('assets/conductor.png') as ImageProvider,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido!', style: mBold(size: 26)),
                      Text(user?.nombre ?? 'Conductor', style: mBold(size: 20, color: Colors.black87)),
                      _buildBadgeStatus(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 90, right: 20,
          child: GestureDetector(
            onTap: () => setState(() {
              _isVoiceActive = !_isVoiceActive;
              _isVoiceActive ? _pulseController.repeat(reverse: true) : _pulseController.reset();
            }),
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Image.asset(_isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png', width: 65, height: 65),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTripCard() {
    if (_viajeProximo == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardBlue, borderRadius: BorderRadius.circular(30)),
        child: Center(child: Text("Sin viajes próximos", style: mBold(color: primaryBlue))),
      );
    }

    final fecha = DateTime.parse(_viajeProximo!['fecha_hora_inicio']);
    final hora = "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBlue, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Hoy - ${fecha.day}/${fecha.month}\nPasajero: ${_viajeProximo!['nombre_pasajero']}', style: mBold(size: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
                child: Text(hora, style: mBold(color: Colors.white, size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text(_viajeProximo!['punto_inicio'] ?? 'Origen', textAlign: TextAlign.center, style: mBold(color: primaryBlue, size: 13))),
              const Icon(Icons.arrow_forward, color: Colors.red, size: 24),
              Expanded(child: Text(_viajeProximo!['destino'] ?? 'Destino', textAlign: TextAlign.center, style: mBold(color: primaryBlue, size: 13))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _expandedBtn('Ver detalles', primaryBlue, () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ViajeDetallesModal(viaje: _viajeProximo!, esConductor: true),
                );
              }),
              const SizedBox(width: 10),
              _expandedBtn('Contactar', primaryBlue, () => _hacerLlamada(_viajeProximo!['telefono_pasajero'])),
            ],
          )
        ],
      ),
    );
  }

  Widget _expandedBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: onTap,
        child: Text(label, style: mBold(color: Colors.white, size: 12), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildRouteSection() {
    // Si tu backend manda coordenadas, las usamos. Si no, mandamos nulo para el centro por defecto.
    LatLng? start;
    LatLng? end;
    if (_viajeProximo != null && _viajeProximo!['lat_inicio'] != null) {
      start = LatLng(_viajeProximo!['lat_inicio'], _viajeProximo!['lng_inicio']);
      end = LatLng(_viajeProximo!['lat_destino'], _viajeProximo!['lng_destino']);
    }

    return HomeMapPreview(
      startCoord: start,
      endCoord: end,
      routePoints: const [], // Puedes integrar un servicio de rutas aquí después
      onOpenRoute: () => Navigator.pushReplacementNamed(context, '/viaje_actual'),
    );
  }

  Widget _buildCalendarRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(children: _calendarDates.map((date) => _calendarDay(date)).toList()),
    );
  }

  Widget _calendarDay(DateTime date) {
    bool isSelected = _selectedDateNum == date.day.toString();
    return Container(
      width: 65, margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(15),
        border: isSelected ? Border.all(color: primaryBlue, width: 2) : null,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
            child: Text(['D','L','M','M','J','V','S'][date.weekday % 7], textAlign: TextAlign.center, style: mBold(color: Colors.white, size: 12)),
          ),
          const SizedBox(height: 8),
          Text(date.day.toString(), style: mBold(color: primaryBlue, size: 16)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_historialViajes.isEmpty) return const Text("Sin historial");
    return Column(children: _historialViajes.take(3).map((v) => _historyCard(v)).toList());
  }

  Widget _historyCard(dynamic viaje) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryBlue.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(viaje['nombre_pasajero'] ?? 'Pasajero', style: mBold(color: primaryBlue)),
              Text(viaje['destino'] ?? 'Destino', style: mBold(size: 12, color: Colors.grey)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: primaryBlue),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ViajeDetallesModal(viaje: viaje, esConductor: true),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadgeStatus() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: buttonLightBlue, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text('Conductor Activo', style: mBold(color: Colors.white, size: 10)),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    return Container(
      height: 70, decoration: const BoxDecoration(color: cardBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home),
          _navIcon(1, Icons.location_on),
          _navIcon(2, Icons.list_alt),
          _navIcon(3, Icons.person),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (active) return;
        String route = '';
        switch (index) {
          case 0: route = '/principal_conductor'; break;
          case 2: route = '/viajes_conductor'; break;
          case 3: route = '/mi_perfil_conductor'; break;
        }
        if (route.isNotEmpty) Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 25),
      ),
    );
  }
}