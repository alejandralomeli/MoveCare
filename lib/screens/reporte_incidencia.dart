import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'widgets/mic_button.dart'; // Mantengo tu import
import '../services/incidencias/incidencias_service.dart'; // Ajusta la ruta a tu service

class ReporteIncidencia extends StatefulWidget {
  const ReporteIncidencia({super.key});

  @override
  State<ReporteIncidencia> createState() => _ReporteIncidenciaState();
}

class _ReporteIncidenciaState extends State<ReporteIncidencia> {
  bool _isListening = false;
  bool _isLoading = true;
  List<dynamic> _reportes = [];

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  // --- CARGAR REPORTES DESDE EL BACKEND ---
  Future<void> _cargarReportes() async {
    try {
      final data = await IncidenciasService.obtenerReportesPendientes();
      if (mounted) {
        setState(() {
          _reportes = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // --- MODAL PARA RECHAZAR REPORTE ---
  Future<void> _mostrarModalRechazo(String idReporte) async {
    final TextEditingController motivoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Motivo de rechazo',
            style: mExtrabold(size: 16, context: context, color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: motivoController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Explique por qué se descarta este reporte...',
              hintStyle: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cierra el modal sin hacer nada
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final motivo = motivoController.text.trim();
                if (motivo.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debe ingresar un motivo para rechazar.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context); // Cierra el modal
                // Ejecuta el proceso con el motivo ingresado
                _procesarReporte(idReporte, 'Rechazado', motivoRechazo: motivo);
              },
              child: Text(
                'Descartar',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- PROCESAR ACCIÓN (ACEPTAR/RECHAZAR) ---
  // 🔥 Agregamos el parámetro opcional motivoRechazo
  Future<void> _procesarReporte(String idReporte, String nuevoEstado, {String motivoRechazo = ""}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 🔥 Ahora mandamos el motivo al service
      await IncidenciasService.cambiarEstadoReporte(
        idReporte: idReporte,
        estado: nuevoEstado,
        motivoRechazo: motivoRechazo, 
      );

      if (mounted) {
        Navigator.pop(context); // Cierra el dialog de carga

        setState(() {
          _reportes.removeWhere((r) => r['id_reporte'].toString() == idReporte);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reporte marcado como $nuevoEstado'),
            backgroundColor: nuevoEstado == 'Aceptado' ? const Color(0xFF16A34A) : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cierra el dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.error,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const AdminBottomNav(
        selectedIndex: 2,
      ), // Asegúrate de tener este widget
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: _isListening,
              onVoiceTap: () => setState(() => _isListening = !_isListening),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_reportes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No hay reportes pendientes',
                  style: GoogleFonts.montserrat(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            SliverFillRemaining(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.06,
                  vertical: 20,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _reportes.length,
                itemBuilder: (context, index) {
                  final reporte = _reportes[index];
                  return _buildReportCard(context, reporte);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, dynamic reporte) {
    final String rawId = reporte['id_reporte']?.toString() ?? 'N/A';
    final String idReporte = rawId.split('-')[0];
    final String tipoReporte = reporte['tipo_reporte']?.toString() ?? 'Reporte general';
    final String descripcion = reporte['descripcion']?.toString() ?? 'Sin descripción proporcionada.';
    final String fecha = reporte['fecha_creacion']?.toString() ?? 'Fecha no disponible';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reporte #$idReporte',
                style: mExtrabold(size: 15, context: context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tipoReporte.toUpperCase(),
                  style: mExtrabold(
                    color: AppColors.white,
                    size: 10,
                    context: context,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha: $fecha',
            style: GoogleFonts.montserrat(
              fontSize: sp(12, context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border, thickness: 1),
          ),
          Text(
            'Descripción:',
            style: mExtrabold(
              size: 13,
              context: context,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            descripcion,
            style: GoogleFonts.montserrat(fontSize: sp(12, context)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _actionBtn(
                label: 'Descartar',
                bgColor: AppColors.white,
                textColor: AppColors.textSecondary,
                context: context,
                // 🔥 Ahora llama al modal en lugar de procesar directo
                onPressed: () => _mostrarModalRechazo(reporte['id_reporte'].toString()),
              ),
              const SizedBox(width: 10),
              _actionBtn(
                label: 'Aceptar',
                bgColor: AppColors.error, // Nota: el verde suele ser mejor para aceptar, pero respeté tus colores
                textColor: AppColors.white,
                context: context,
                // Aceptar pasa directo sin motivo (o motivo vacío)
                onPressed: () => _procesarReporte(
                  reporte['id_reporte'].toString(),
                  'Aceptado',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required Color bgColor,
    required Color textColor,
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: bgColor == AppColors.white
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          style: mExtrabold(color: textColor, size: 11, context: context),
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              'Bandeja de Reportes',
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 20,
            ),
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