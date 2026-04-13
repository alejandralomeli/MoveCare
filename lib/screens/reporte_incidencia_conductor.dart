import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- TUS DEPENDENCIAS (Ajusta las rutas según tu proyecto) ---
import '../app_theme.dart';
import 'widgets/mic_button.dart';
import '../providers/user_provider.dart'; 
import '../services/incidencias/incidencias_service.dart';
// 👇 IMPORTA AQUÍ EL SERVICIO DONDE TIENES obtenerDetalleViaje
import '../services/viaje/viaje_service.dart'; 

class ReporteIncidenciaConductor extends StatefulWidget {
  const ReporteIncidenciaConductor({super.key});

  @override
  State<ReporteIncidenciaConductor> createState() => _ReporteIncidenciaConductorState();
}

class _ReporteIncidenciaConductorState extends State<ReporteIncidenciaConductor> {
  bool _isListening = false;
  bool _isSubmitting = false;
  int? _tipoSeleccionado;
  String? _idViaje; 
  final TextEditingController _descripcionCtrl = TextEditingController();

  final List<Map<String, dynamic>> _tiposIncidencia = [
    {'label': 'Pasajero agresivo', 'icon': Icons.person_off_rounded},
    {'label': 'Accidente vial', 'icon': Icons.car_crash_rounded},
    {'label': 'Falla del vehículo', 'icon': Icons.car_repair_rounded},
    {'label': 'Ruta bloqueada', 'icon': Icons.block_rounded},
    {'label': 'Emergencia médica', 'icon': Icons.medical_services_rounded},
    {'label': 'Otro', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg != null) {
      _idViaje = arg.toString();
    }
  }

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _enviarReporte() {
    if (_tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el tipo de incidencia')),
      );
      return;
    }
    if (_descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una descripción')),
      );
      return;
    }
    if (_idViaje == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se identificó el viaje a reportar')),
      );
      return;
    }
    
    _mostrarConfirmacion();
  }

  // 🚀 LÓGICA DE CONEXIÓN ACTUALIZADA
  Future<void> _ejecutarEnvioBackend() async {
    Navigator.pop(context); 
    
    setState(() => _isSubmitting = true);

    try {
      final userProvider = context.read<UserProvider>();
      final String idUsuario = userProvider.user?.idUsuario ?? "0"; 
      
      final tipoReporteStr = _tiposIncidencia[_tipoSeleccionado!]['label'];

      // 1. Buscamos la info del viaje con tu servicio
      // Cambia "ViajesService" por el nombre real de tu clase
      final Map<String, dynamic> infoViaje = await ViajeService.obtenerDetalleViaje(_idViaje!);

      // 2. Extraemos el id del pasajero desde el JSON que me mostraste
      final String idPasajero = infoViaje['id_pasajero'];

      // 3. Enviamos todos los datos correctamente al backend estricto
      await IncidenciasService.enviarIncidencia(
        idReportante: idUsuario,
        idReportado: idPasajero, // 👈 Ahora sí enviamos el del pasajero
        idViaje: _idViaje!,      // 👈 Y enviamos explícitamente el del viaje
        tipoReporte: tipoReporteStr,
        descripcion: _descripcionCtrl.text.trim(),
      );

      if (!mounted) return;
      
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _mostrarConfirmacion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: !_isSubmitting, 
      builder: (context) => Container(
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flag_rounded, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Enviar reporte',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tu reporte será revisado por el equipo de MoveCare.',
              textAlign: TextAlign.center,
              style: mBold(color: AppColors.textSecondary, size: 13),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar', style: mBold(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _ejecutarEnvioBackend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Confirmar', style: mBold(color: AppColors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 0),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  isVoiceActive: _isListening,
                  onVoiceTap: () => setState(() => _isListening = !_isListening),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tu reporte es confidencial y será atendido en menos de 24 horas.',
                                style: mBold(color: AppColors.error, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('Tipo de incidencia', style: mBold(size: 16)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _tiposIncidencia.length,
                        itemBuilder: (context, i) {
                          final selected = _tipoSeleccionado == i;
                          return GestureDetector(
                            onTap: () => setState(() => _tipoSeleccionado = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.border,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _tiposIncidencia[i]['icon'] as IconData,
                                    color: selected ? AppColors.white : AppColors.primary,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _tiposIncidencia[i]['label'] as String,
                                    textAlign: TextAlign.center,
                                    style: mBold(
                                      color: selected ? AppColors.white : AppColors.textPrimary,
                                      size: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Text('Descripción', style: mBold(size: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descripcionCtrl,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Describe con detalle lo que ocurrió...',
                          hintStyle: mBold(color: AppColors.textSecondary, size: 13),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _enviarReporte,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text('Enviar reporte', style: mBold(color: AppColors.white, size: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          if (_isSubmitting)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          color: AppColors.primaryLight,
          child: Center(
            child: Text(
              'Reportar Incidencia',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}