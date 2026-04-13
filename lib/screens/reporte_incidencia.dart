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

  // --- PROCESAR ACCIÓN (ACEPTAR/RECHAZAR) ---
  Future<void> _procesarReporte(String idReporte, String nuevoEstado) async {
    // TODO: Obtener este ID desde la sesión del usuario (ej. AuthHelper.getUsuarioId())
    const int idAdminActual = 1; 

    // Mostrar un pequeño indicador de carga (opcional pero recomendado)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await IncidenciasService.cambiarEstadoReporte(
        idReporte: idReporte,
        estado: nuevoEstado,
        idAdministrador: idAdminActual,
      );

      if (mounted) {
        Navigator.pop(context); // Cierra el dialog de carga
        
        // Removemos el reporte de la lista local para no volver a consultarlo
        setState(() {
          _reportes.removeWhere((r) => r['id_reporte'].toString() == idReporte);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reporte marcado como $nuevoEstado'),
            backgroundColor: const Color(0xFF16A34A), // Verde éxito
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

  TextStyle mExtrabold({Color color = Colors.black, double size = 14, required BuildContext context}) {
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
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2), // Asegúrate de tener este widget
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
          
          // --- RENDERIZADO CONDICIONAL DE LA LISTA ---
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
                padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
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
    // Extracción segura de datos
    final String idReporte = reporte['id_reporte']?.toString() ?? 'N/A';
    final String tipoReporte = reporte['tipo_reporte']?.toString() ?? 'Reporte general';
    final String descripcion = reporte['descripcion']?.toString() ?? 'Sin descripción proporcionada.';
    // Si tu backend manda fecha, úsala. Si no, ponemos un placeholder
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
              Text('Reporte #$idReporte', style: mExtrabold(size: 15, context: context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tipoReporte.toUpperCase(),
                  style: mExtrabold(color: AppColors.white, size: 10, context: context),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha: $fecha',
            style: GoogleFonts.montserrat(fontSize: sp(12, context), fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Divider(color: AppColors.border, thickness: 1),
          ),
          Text(
            'Descripción:',
            style: mExtrabold(size: 13, context: context, color: AppColors.primary),
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
                onPressed: () => _procesarReporte(idReporte, 'Rechazado'),
              ),
              const SizedBox(width: 10),
              _actionBtn(
                label: 'Aceptar', // Cambié "Bloquear" por "Aceptar" para que haga sentido con el backend
                bgColor: AppColors.error,
                textColor: AppColors.white,
                context: context,
                onPressed: () => _procesarReporte(idReporte, 'Aceptado'),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Modifiqué el botón para que acepte el callback
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
            side: bgColor == AppColors.white ? const BorderSide(color: AppColors.border) : BorderSide.none,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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