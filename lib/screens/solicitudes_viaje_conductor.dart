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

  // --- HELPERS DE TEXTO ESTILO NUEVO DISEÑO ---
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          titulo,
          style: mFont(size: 16, color: colorPrimario, weight: FontWeight.bold),
        ),
        content: Text(mensaje, style: mFont(size: 14, color: AppColors.textPrimary, weight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Regresar', style: mFont(color: AppColors.textSecondary, size: 14)),
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
              style: mFont(color: AppColors.white, size: 13, weight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE ACCIONES ---
  Future<void> _procesarAccion(Future<void> Function() accion) async {
    try {
      setState(() => _isLoading = true);
      await accion();
      await _cargarViajes(); // Recarga las listas
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            backgroundColor: AppColors.primaryLight,
            elevation: 0,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Mis Viajes',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            bottom: TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: mFont(size: 14, weight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Solicitudes'),
                Tab(text: 'Agendados'),
              ],
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : TabBarView(
                children: [
                  _buildList(_solicitudesPendientes, isPendiente: true),
                  _buildList(_viajesAgendados, isPendiente: false),
                ],
              ),
        bottomNavigationBar: const DriverBottomNav(selectedIndex: 5), // Asegúrate de tener este widget
      ),
    );
  }

  Widget _buildList(List<dynamic> viajes, {required bool isPendiente}) {
    if (viajes.isEmpty) {
      return Center(
        child: Text(
          isPendiente
              ? 'No tienes solicitudes nuevas'
              : 'No tienes viajes agendados',
          style: mFont(
            color: AppColors.textSecondary,
            size: 16,
            weight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: viajes.length,
      itemBuilder: (context, index) {
        final viaje = viajes[index];
        final nombrePasajero = viaje['nombre_pasajero'] ?? 'Pasajero Desconocido';
        final origen = viaje['punto_inicio'] ?? 'Origen no especificado';
        final destino = viaje['destino'] ?? 'Destino no especificado';
        final fecha = viaje['fecha_inicio'] ?? 'Fecha no disponible';
        final String idViaje = viaje['id']?.toString() ?? viaje['id_viaje']?.toString() ?? '';

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
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origen y Destino (Estilo Historial)
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
                  'Fecha: $fecha',
                  style: mFont(
                    size: 12,
                    color: AppColors.primary,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 15),
                
                // Avatar y Datos del Pasajero
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: (viaje['foto_pasajero'] != null && viaje['foto_pasajero'].isNotEmpty)
                          ? NetworkImage(viaje['foto_pasajero']) as ImageProvider
                          : const AssetImage('assets/conductor.png'),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombrePasajero,
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.white, size: 10),
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
                    ),
                    _buildDiscapacidadIcons(viaje['necesidad_especial']),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Botones de Acción
                Row(
                  children: isPendiente
                      ? [
                          // PENDIENTE: RECHAZAR O ACEPTAR
                          _btn('Rechazar', AppColors.surface, AppColors.error, () {
                            _mostrarModalConfirmacion(
                              titulo: 'Rechazar viaje',
                              mensaje: '¿Estás seguro de que deseas rechazar este viaje con $nombrePasajero?',
                              colorPrimario: AppColors.error,
                              onConfirm: () => _procesarAccion(
                                () => ViajeService.rechazarViaje(idViaje),
                              ),
                            );
                          }),
                          const SizedBox(width: 10),
                          _btn('Aceptar', AppColors.primary, AppColors.white, () {
                            _mostrarModalConfirmacion(
                              titulo: 'Aceptar viaje',
                              mensaje: '¿Deseas confirmar y agendar este viaje con $nombrePasajero?',
                              colorPrimario: AppColors.primary,
                              onConfirm: () => _procesarAccion(
                                () => ViajeService.aceptarViaje(idViaje),
                              ),
                            );
                          }),
                        ]
                      : [
                          // AGENDADO: VER DETALLES O CANCELAR
                          _btn('Ver Detalles', AppColors.surface, AppColors.primary, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SolicitudViaje(idViaje: idViaje),
                              ),
                            );
                          }),
                          const SizedBox(width: 10),
                          _btn('Cancelar Viaje', AppColors.error, AppColors.white, () {
                            _mostrarModalConfirmacion(
                              titulo: 'Cancelar viaje agendado',
                              mensaje: '¿Estás seguro de cancelar este viaje programado con $nombrePasajero? Perderás la asignación.',
                              colorPrimario: AppColors.error,
                              onConfirm: () => _procesarAccion(
                                () => ViajeService.cancelarViajeChofer(idViaje),
                              ),
                            );
                          }),
                        ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _btn(String label, Color bg, Color txt, VoidCallback onTap) {
    bool isOutlined = bg == AppColors.surface || bg == AppColors.white;
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isOutlined
                ? BorderSide(color: txt.withValues(alpha: 0.5))
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: mFont(color: txt, size: 13, weight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // --- ICONOS DE NECESIDADES ESPECIALES (MANTENIDOS POR CONSISTENCIA) ---
  Widget _buildDiscapacidadIcons(String? textoNecesidades) {
    if (textoNecesidades == null || textoNecesidades.isEmpty || textoNecesidades.toLowerCase() == 'ninguna') {
      return const SizedBox.shrink();
    }

    List<String> lista = textoNecesidades.split(',').map((e) => e.trim().toLowerCase()).toList();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: lista.map((n) {
        String path = 'assets/tercera_edad.png';
        
        if (n.contains('tercera edad')) path = 'assets/tercera_edad.png';
        else if (n.contains('movilidad') || n.contains('silla')) path = 'assets/silla_ruedas.png';
        else if (n.contains('auditiva')) path = 'assets/auditiva.png';
        else if (n.contains('obesidad')) path = 'assets/obesidad.png';
        else if (n.contains('visual')) path = 'assets/visual.png';

        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Image.asset(
              path, 
              width: 24, 
              height: 24,
              errorBuilder: (c, e, s) => const Icon(Icons.accessibility_new, color: AppColors.primary, size: 20),
            ),
          ),
        );
      }).toList(),
    );
  }
}