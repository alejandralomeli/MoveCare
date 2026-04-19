import 'dart:convert'; // Restaurado para Base64
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart'; // Restaurado para las rutas
import '../services/voz/voz_singleton.dart';

import 'chat_viaje.dart';
import 'widgets/map_widget.dart';
import 'widgets/route_map_widget.dart'; // Restaurado
import 'widgets/modals/viaje_detalles_modal.dart'; // Restaurado
import 'widgets/mic_button.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../services/viaje/viaje_service.dart'; // Restaurado
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

  // Voz (instancia compartida via singleton)

  DateTime _weekStart = DateTime.now();
  Map<String, dynamic>? _viajeProximo;
  List<dynamic> _historialViajes = [];

  // Variables restauradas para la ruta
  LatLng? _startCoord;
  LatLng? _endCoord;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _loadHome();
    _inicializarVoz();
  }

  Future<void> _inicializarVoz() async {
    await VozSingleton.inicializar();
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

        // Restaurada lógica de decodificación de ruta
        if (_viajeProximo!['ruta'] != null) {
          try {
            List<dynamic> rutaJson = _viajeProximo!['ruta'];
            _routePoints = rutaJson.map((punto) {
              if (punto is Map) {
                return LatLng(
                  (punto['lat'] ?? punto[1]) * 1.0,
                  (punto['lng'] ?? punto['lon'] ?? punto[0]) * 1.0,
                );
              } else if (punto is List) {
                return LatLng(punto[0] * 1.0, punto[1] * 1.0);
              }
              return const LatLng(0, 0);
            }).toList();

            if (_routePoints.isNotEmpty) {
              _startCoord = _routePoints.first;
              _endCoord = _routePoints.last;
            }
          } catch (e) {
            debugPrint("Error al decodificar la ruta del viaje próximo: $e");
          }
        }
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

  // Restaurada lógica de Cancelación (Adaptada a la nueva estética)
  void _mostrarDialogoCancelacion(String idViaje) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Cancelar viaje",
            style: mExtrabold(size: 18, color: AppColors.textPrimary),
          ),
          content: Text(
            "¿Desea cancelar el viaje? Esta acción no se puede deshacer.",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("Volver", style: mExtrabold(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error ?? const Color.fromARGB(255, 219, 26, 26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _procesarCancelacion(idViaje);
              },
              child: Text(
                "Sí, cancelar",
                style: mExtrabold(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _procesarCancelacion(String idViaje) async {
    setState(() => _loadingHome = true);
    try {
      await ViajeService.cancelarViaje(idViaje);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viaje cancelado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadHome();
    } catch (e) {
      setState(() => _loadingHome = false);
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

  // --- INTERFAZ DE VOZ ---
  Future<void> _toggleListening() async {
    final speech = VozSingleton.speech;
    final tts = VozSingleton.tts;

    if (!speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Micrófono no disponible en este dispositivo')),
      );
      return;
    }

    if (speech.isListening) {
      await speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    try {
      await speech.listen(
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

            await tts.speak(respuesta['respuesta_voz'] ?? '');
            _manejarAccionVoz(respuesta);
          } catch (_) {
            if (!mounted) return;
            setState(() => _procesandoVoz = false);
            await tts.speak('Lo siento, no pude conectar con el servidor');
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isListening = false);
      debugPrint('Voz: error al escuchar — $e');
      await VozSingleton.reinicializar();
    }
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

    // Restaurada la decodificación de la foto de perfil en Base64
    ImageProvider imagenPerfil = const AssetImage('assets/pasajero.png'); 
    
    if (user != null && user.fotoPerfil.isNotEmpty) {
      try {
        String base64String = user.fotoPerfil;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        imagenPerfil = MemoryImage(base64Decode(base64String));
      } catch (e) {
        debugPrint("Error decodificando foto de perfil: $e");
      }
    }

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
                _buildHeader(user?.nombre ?? 'Usuario', imagenPerfil),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
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
                      if (_viajeProximo != null) ...[
                        _buildContactarConductorButton(),
                        const SizedBox(height: 12),
                      ],
                      // _buildReportButton(),
                      // const SizedBox(height: 30),
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

  // Modificado para aceptar el ImageProvider
  Widget _buildHeader(String name, ImageProvider imagenPerfil) {
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
              backgroundImage: imagenPerfil, // Restaurado
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
                'Bienvenido',
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
        // Restaurada lógica de RouteMapWidget
        child: (_viajeProximo != null && _routePoints.isNotEmpty)
            ? RouteMapWidget(
                startCoord: _startCoord,
                endCoord: _endCoord,
                routePoints: _routePoints,
                isLoading: false,
              )
            : const MapWidget(),
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
              // Restaurada la acción Ver Detalles
              _actionBtn('Ver detalles', onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ViajeDetallesModal(viaje: _viajeProximo!, esConductor: false),
                );
              }),
              const SizedBox(width: 10),
              // Restaurada la acción Cancelar y añadida opción de color
              _actionBtn('Cancelar', color: AppColors.error ?? const Color.fromARGB(255, 219, 26, 26), onPressed: () {
                _mostrarDialogoCancelacion(_viajeProximo!['id_viaje'].toString());
              }),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatViaje(
                      nombreContacto: _viajeProximo!['nombre_conductor'] ?? 'Conductor',
                      esConductor: false,
                    ),
                  ),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.message_rounded, color: AppColors.primary, size: 20),
                ),
              ),
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
      // Mapeamos los viajes y usamos .asMap() para no poner Divider en el último
      child: Column(
        children: _historialViajes.take(3).toList().asMap().entries.map((entry) {
          int index = entry.key;
          dynamic viaje = entry.value;
          bool isLast = index == (_historialViajes.take(3).length - 1);
          
          return Column(
            children: [
              _historyItem(viaje),
              if (!isLast) 
                const Divider(height: 1, thickness: 1, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _historyItem(dynamic viaje) {
    // 1. Formatear la fecha dinámicamente igual que en el conductor
    String fechaTexto = "Fecha N/A";
    if (viaje['fecha_hora_inicio'] != null) {
      try {
        final f = DateTime.parse(viaje['fecha_hora_inicio']);
        // Asegúrate de tener el método _monthName disponible en esta clase también
        fechaTexto = "${_monthName(f.month).substring(0, 3)} ${f.day}";
      } catch (e) {
        fechaTexto = "Fecha N/A";
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                fechaTexto, // 👈 Fecha real extraída del backend
                style: mExtrabold(size: 12),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  viaje['destino'] ?? 'Viaje sin destino',
                  style: mExtrabold(color: AppColors.primary, size: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Para que no se desborde si es muy largo
                ),
              ),
              Text(
                viaje['estado'] ?? 'Finalizado',
                style: mExtrabold(color: AppColors.error, size: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 🚀 AQUÍ ESTÁ EL BOTÓN DE REPORTE CON TODA LA LÓGICA
          GestureDetector(
            onTap: () {
              if (viaje['id_viaje'] != null) {
                Navigator.pushNamed(
                  context,
                  '/reporte_incidencia_pasajero', // 👈 Tu ruta de pasajero
                  arguments: viaje['id_viaje'],   // 👈 Se envía el ID del viaje
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error: Este viaje no tiene ID asociado"),
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
                  style: mExtrabold(color: AppColors.error, size: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modificado para aceptar onPressed y color opcional
  Widget _actionBtn(String label, {required VoidCallback onPressed, Color? color}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed, // Restaurado
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
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

  Widget _buildContactarConductorButton() {
    final nombreConductor = _viajeProximo?['nombre_conductor'] ?? 'Conductor';
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatViaje(
              nombreContacto: nombreConductor,
              esConductor: false,
            ),
          ),
        ),
        icon: const Icon(Icons.message_rounded, color: AppColors.white),
        label: Text(
          'Contactar conductor',
          style: mExtrabold(color: AppColors.white, size: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Widget _buildReportButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton.icon(
  //       onPressed: () => Navigator.pushNamed(context, '/reporte_incidencia_pasajero'),
  //       icon: const Icon(Icons.error, color: AppColors.white),
  //       label: Text(
  //         'Reportar incidencia',
  //         style: mExtrabold(color: AppColors.white, size: 15),
  //       ),
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color.fromARGB(255, 219, 26, 26),
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //       ),
  //     ),
  //   );
  // }

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