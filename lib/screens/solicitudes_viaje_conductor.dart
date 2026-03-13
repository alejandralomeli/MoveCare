import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/viaje/viaje_service.dart';
import '../core/utils/auth_helper.dart';
import '../providers/user_provider.dart';
import 'solicitud_viaje.dart';
import '../app_theme.dart';

class SolicitudesViajesConductor extends StatefulWidget {
  const SolicitudesViajesConductor({super.key});

  @override
  State<SolicitudesViajesConductor> createState() =>
      _SolicitudesViajesConductorState();
}

class _SolicitudesViajesConductorState
    extends State<SolicitudesViajesConductor> {
  // --- COLORES ---
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color statusGreen = Color(0xFF66BB6A);

  bool _isLoading = true;
  List<dynamic> _solicitudesPendientes = [];
  List<dynamic> _viajesAgendados = [];

  @override
  void initState() {
    super.initState();
    _cargarViajes();
  }

  Future<void> _cargarViajes() async {
    try {
      setState(() => _isLoading = true);

      final user = context.read<UserProvider>().user;

      if (user == null) {
        throw Exception('No se encontró la información del usuario.');
      }

      String idUsuario = user.idUsuario.toString();

      final resultados = await Future.wait<List<dynamic>>([
        ViajeService.obtenerViajesPorEstadoConductor(idUsuario, 'Pendiente'),
        ViajeService.obtenerViajesPorEstadoConductor(idUsuario, 'Agendado'),
      ]);

      if (mounted) {
        setState(() {
          _solicitudesPendientes = resultados[0];
          _viajesAgendados = resultados[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AuthHelper.manejarError(context, e);
      }
    }
  }

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({
    Color color = Colors.black,
    double size = 14,
    required BuildContext context,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  // --- MODALES DE CONFIRMACIÓN ---

  void _mostrarModalConfirmacion({
    required String titulo,
    required String mensaje,
    required Color colorPrimario,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titulo,
          style: mExtrabold(size: 16, context: context, color: colorPrimario),
        ),
        content: Text(mensaje, style: GoogleFonts.montserrat(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Regresar', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimario,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Confirmar',
              style: mExtrabold(
                color: Colors.white,
                size: 12,
                context: context,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE BOTONES ---

  Future<void> _procesarAccion(Future<void> Function() accion) async {
    try {
      setState(() => _isLoading = true);
      await accion();
      await _cargarViajes(); // Recarga las listas
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: statusRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              height: 135,
              width: double.infinity,
              color: lightBlueBg,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        'Mis Viajes',
                        style: GoogleFonts.montserrat(
                          fontSize: sp(20, context),
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TabBar(
                      indicatorColor: primaryBlue,
                      labelColor: primaryBlue,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: mExtrabold(size: 13, context: context),
                      tabs: const [
                        Tab(text: 'Solicitudes'),
                        Tab(text: 'Agendados'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    )
                  : TabBarView(
                      children: [
                        _buildList(
                          context,
                          sw,
                          _solicitudesPendientes,
                          isPendiente: true,
                        ),
                        _buildList(
                          context,
                          sw,
                          _viajesAgendados,
                          isPendiente: false,
                        ),
                      ],
                    ),
            ),
          ],
        ),
        bottomNavigationBar: const DriverBottomNav(selectedIndex: 2),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    double sw,
    List<dynamic> viajes, {
    required bool isPendiente,
  }) {
    if (viajes.isEmpty) {
      return Center(
        child: Text(
          isPendiente
              ? 'No tienes solicitudes nuevas'
              : 'No tienes viajes agendados',
          style: GoogleFonts.montserrat(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 20),
      itemCount: viajes.length,
      itemBuilder: (context, index) {
        final viaje = viajes[index];
        final nombrePasajero =
            viaje['nombre_pasajero'] ?? 'Pasajero Desconocido';
        final origen = viaje['punto_inicio'] ?? 'Origen no especificado';
        final destino = viaje['destino'] ?? 'Destino no especificado';
        final fecha = viaje['fecha_inicio'] ?? 'Fecha no disponible';
        final String idViaje =
            viaje['id']?.toString() ?? viaje['id_viaje']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: cardBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: primaryBlue),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombrePasajero,
                          style: mExtrabold(size: 15, context: context),
                        ),
                        Text(
                          'Fecha: $fecha',
                          style: GoogleFonts.montserrat(
                            fontSize: sp(11, context),
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.location_on, color: statusGreen, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      origen,
                      style: GoogleFonts.montserrat(fontSize: sp(12, context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.flag, color: statusRed, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      destino,
                      style: GoogleFonts.montserrat(fontSize: sp(12, context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 25, color: Colors.white),
              Row(
                children: isPendiente
                    ? [
                        // PENDIENTE: RECHAZAR O ACEPTAR
                        _btn('Rechazar', Colors.white, statusRed, context, () {
                          _mostrarModalConfirmacion(
                            titulo: 'Rechazar viaje',
                            mensaje:
                                '¿Estás seguro de que deseas rechazar este viaje con $nombrePasajero?',
                            colorPrimario: statusRed,
                            onConfirm: () => _procesarAccion(
                              () => ViajeService.rechazarViaje(idViaje),
                            ),
                          );
                        }),
                        const SizedBox(width: 10),
                        _btn('Aceptar', primaryBlue, Colors.white, context, () {
                          _mostrarModalConfirmacion(
                            titulo: 'Aceptar viaje',
                            mensaje:
                                '¿Deseas confirmar y agendar este viaje con $nombrePasajero?',
                            colorPrimario: primaryBlue,
                            onConfirm: () => _procesarAccion(
                              () => ViajeService.aceptarViaje(idViaje),
                            ),
                          );
                        }),
                      ]
                    : [
                        // AGENDADO: VER DETALLES O CANCELAR
                        _btn(
                          'Ver Detalles',
                          Colors.white,
                          primaryBlue,
                          context,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SolicitudViaje(idViaje: idViaje),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _btn(
                          'Cancelar Viaje',
                          statusRed,
                          Colors.white,
                          context,
                          () {
                            _mostrarModalConfirmacion(
                              titulo: 'Cancelar viaje agendado',
                              mensaje:
                                  '¿Estás seguro de cancelar este viaje programado con $nombrePasajero? Perderás la asignación.',
                              colorPrimario: statusRed,
                              onConfirm: () => _procesarAccion(
                                () => ViajeService.cancelarViajeChofer(idViaje),
                              ),
                            );
                          },
                        ),
                      ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _btn(
    String label,
    Color bg,
    Color txt,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: bg == Colors.white
                ? BorderSide(color: txt.withOpacity(0.5))
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: mExtrabold(color: txt, size: 12, context: context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
