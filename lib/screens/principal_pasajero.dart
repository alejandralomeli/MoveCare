import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'widgets/map_widget.dart';
import 'widgets/mic_button.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../services/voz/voz_service.dart';
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
  bool _procesandoVoz = false;
  String _selectedDateNum = '';

  // Voz
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechDisponible = false;

  DateTime _weekStart = DateTime.now();
  Map<String, dynamic>? _viajeProximo;
  List<dynamic> _historialViajes = [];

  @override
  void initState() {
    super.initState();
    _loadHome();
    _inicializarVoz();
  }

  Future<void> _inicializarVoz() async {
    _speechDisponible = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.45);
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
  Future<void> _toggleListening() async {
    if (!_speechDisponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Micrófono no disponible en este dispositivo')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    await _speech.listen(
      localeId: 'es_MX',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) async {
        if (!result.finalResult) return;

        final texto = result.recognizedWords.trim();
        if (texto.isEmpty) {
          setState(() => _isListening = false);
          return;
        }

        setState(() {
          _isListening = false;
          _procesandoVoz = true;
        });

        try {
          final respuesta = await VozService.interpretarComando(texto);
          if (!mounted) return;
          setState(() => _procesandoVoz = false);

          await _tts.speak(respuesta['respuesta_voz'] ?? '');
          _manejarAccionVoz(respuesta);
        } catch (_) {
          if (!mounted) return;
          setState(() => _procesandoVoz = false);
          await _tts.speak('Lo siento, no pude conectar con el servidor');
        }
      },
    );
  }

  void _manejarAccionVoz(Map<String, dynamic> respuesta) {
    final intencion = respuesta['intencion'] as String? ?? 'no_reconocido';
    final entidades = respuesta['entidades'] as Map<String, dynamic>? ?? {};

    switch (intencion) {
      case 'solicitar_viaje':
        Navigator.pushNamed(context, '/agendar_viaje', arguments: entidades);
        break;
      case 'solicitar_viaje_multiple':
        Navigator.pushNamed(context, '/agendar_varios_destinos', arguments: entidades);
        break;
      case 'ver_historial':
        Navigator.pushNamed(context, '/historial_viajes_pasajero');
        break;
      case 'cancelar_viaje':
        _mostrarConfirmacionCancelar();
        break;
      case 'ver_viaje_actual':
        Navigator.pushNamed(context, '/viaje_actual');
        break;
      case 'crear_acompanante':
        Navigator.pushNamed(context, '/registro_acompanante', arguments: entidades);
        break;
      case 'ver_acompanantes':
        Navigator.pushNamed(context, '/registro_acompanante');
        break;
      case 'ver_pagos':
        Navigator.pushNamed(context, '/metodos_pago');
        break;
      case 'ver_home':
        // Ya estamos en home, no hace nada
        break;
      default:
        _mostrarNoReconocido(respuesta['transcripcion'] ?? '');
    }
  }

  void _mostrarConfirmacionCancelar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cancelar viaje', style: mExtrabold(size: 16)),
        content: Text('¿Confirmas cancelar tu viaje actual?', style: mExtrabold(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/viaje_actual');
            },
            child: Text('Cancelar viaje', style: mExtrabold(color: AppColors.white, size: 13)),
          ),
        ],
      ),
    );
  }

  void _mostrarNoReconocido(String texto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/rechazado.png', height: 64),
            const SizedBox(height: 16),
            Text('No entendí el comando', style: mExtrabold(size: 16)),
            const SizedBox(height: 8),
            Text(
              texto.isNotEmpty ? '"$texto"' : 'Intenta de nuevo',
              style: mExtrabold(color: AppColors.textSecondary, size: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Puedes decir:\n"Quiero un viaje al hospital"\n"Ver mi historial"\n"Agregar acompañante"',
              style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text('Entendido', style: mExtrabold(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
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
          if (_procesandoVoz)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/escuchando.png', height: 80),
                    const SizedBox(height: 16),
                    Text(
                      'Procesando comando...',
                      style: GoogleFonts.montserrat(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        Positioned(
          top: 60,
          right: 20,
          child: MicButton(
            isActive: _isListening,
            onTap: _toggleListening,
            size: 42,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill indicador
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Tipo de viaje',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '¿Cuántos destinos tiene tu viaje?',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          // BOTÓN 1: Un destino
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agendar_viaje');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Un destino',
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // BOTÓN 2: Varios destinos
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agendar_varios_destinos');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Dos o más destinos',
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

}
