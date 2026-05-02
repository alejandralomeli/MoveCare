import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../app_theme.dart';

import '../services/auth/validacion_service.dart';
// import '../services/auth/admin_bottom_nav.dart'; 

class GestionUsuarios extends StatefulWidget {
  const GestionUsuarios({super.key});

  @override
  State<GestionUsuarios> createState() => _GestionUsuariosState();
}

class _GestionUsuariosState extends State<GestionUsuarios> {
  bool _isLoading = true;
  List<dynamic> _conductores = [];
  List<dynamic> _pasajeros = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // Llamada al service
      final data = await ValidacionService.obtenerPendientes();
      setState(() {
        _conductores = data['conductores'] ?? [];
        _pasajeros = data['pasajeros'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
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

  void _procesarAccion(String idValidacion, String accion, {String motivo = ''}) async {
    try {
      if (accion == 'aceptar') {
        await ValidacionService.aceptarValidacion(idValidacion);
      } else {
        await ValidacionService.rechazarValidacion(idValidacion, motivo);
      }
      _cargarDatos(); // Recargar la lista tras el éxito
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar: $e')),
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
        backgroundColor: AppColors.white,
        bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primaryLight,
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            'Gestión de Usuarios',
                            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 20,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: mExtrabold(size: 13, context: context),
                    tabs: const [Tab(text: 'Conductores'), Tab(text: 'Pasajeros')],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                      children: [
                        _buildList(context, sw, 'Conductor', _conductores),
                        _buildList(context, sw, 'Pasajero', _pasajeros),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, double sw, String tipo, List<dynamic> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('No hay validaciones pendientes.', style: GoogleFonts.montserrat(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final usuario = item['usuario'];
        final validacion = item['validacion'];

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: AppColors.white, child: Icon(tipo == 'Conductor' ? Icons.directions_car : Icons.person, color: AppColors.primary)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(usuario['nombre'] ?? 'Usuario', style: mExtrabold(size: 15, context: context)),
                        Text('Ver documentos pendientes', style: GoogleFonts.montserrat(fontSize: sp(11, context))),
                      ],
                    ),
                  ),
                  // BOTON FLECHA: Ver más detalles
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DetallesValidacionModal(validacion: validacion, usuario: usuario),
                      );
                    },
                  ),
                ],
              ),
              const Divider(height: 25),
              Row(
                children: [
                  _btn('Rechazar', AppColors.white, AppColors.error, context, () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => RechazoValidacionModal(
                        nombreUsuario: usuario['nombre'],
                        onConfirm: (motivo) {
                          Navigator.pop(context);
                          _procesarAccion(validacion['id_validacion'], 'rechazar', motivo: motivo);
                        },
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  _btn('Aceptar', const Color(0xFF16A34A), AppColors.white, context, () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmarAceptarModal(
                        onConfirm: () {
                          Navigator.pop(context);
                          _procesarAccion(validacion['id_validacion'], 'aceptar');
                        },
                      ),
                    );
                  }),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _btn(String label, Color bg, Color txt, BuildContext context, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: bg == AppColors.white ? const BorderSide(color: AppColors.error) : BorderSide.none,
          ),
        ),
        child: Text(label, style: mExtrabold(color: txt, size: 11, context: context)),
      ),
    );
  }
}

// =====================================================================
// MODALES EXTERNALIZADOS COMO WIDGETS
// =====================================================================

// MODAL DE RECHAZO (El que tú diseñaste, ahora funcional y aislado)
class RechazoValidacionModal extends StatefulWidget {
  final String nombreUsuario;
  final Function(String) onConfirm;

  const RechazoValidacionModal({super.key, required this.nombreUsuario, required this.onConfirm});

  @override
  State<RechazoValidacionModal> createState() => _RechazoValidacionModalState();
}

class _RechazoValidacionModalState extends State<RechazoValidacionModal> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Rechazar solicitud', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(widget.nombreUsuario, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motivo del rechazo...',
                hintStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isEmpty) return; // Validar vacío
                      widget.onConfirm(_controller.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Confirmar', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
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
}

// MODAL DE ACEPTAR
class ConfirmarAceptarModal extends StatelessWidget {
  final VoidCallback onConfirm;
  const ConfirmarAceptarModal({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Aprobar Validacion', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
      content: Text('¿Estás seguro de que la información es correcta y deseas aprobar a este usuario?', style: GoogleFonts.montserrat()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: GoogleFonts.montserrat(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
          onPressed: onConfirm,
          child: Text('Aprobar', style: GoogleFonts.montserrat(color: AppColors.white)),
        ),
      ],
    );
  }
}

// MODAL PARA VER DETALLES Y PDF
class DetallesValidacionModal extends StatelessWidget {
  final Map<String, dynamic> validacion;
  final Map<String, dynamic> usuario;

  const DetallesValidacionModal({super.key, required this.validacion, required this.usuario});

  // Limpia el base64 que a veces viene con prefijos de postman/web
  String _limpiarBase64(String base64String) {
    if (base64String.contains(',')) return base64String.split(',').last;
    return base64String.replaceAll('\n', '').replaceAll('\r', '');
  }

  Widget _buildImagenDecodificada(String label, String? base64String) {
    if (base64String == null || base64String.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(_limpiarBase64(base64String)),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirPdf(BuildContext context, String pdfBase64) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Ver Póliza', style: GoogleFonts.montserrat(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
          body: SfPdfViewer.memory(base64Decode(_limpiarBase64(pdfBase64))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Documentos de ${usuario['nombre']}', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildImagenDecodificada('INE Frente', validacion['ine_frente']),
                _buildImagenDecodificada('INE Reverso', validacion['ine_reverso']),
                if (usuario['rol'].toString().toLowerCase() == 'conductor') ...[
                  _buildImagenDecodificada('Licencia Frente', validacion['licencia_frente']),
                  _buildImagenDecodificada('Licencia Reverso', validacion['licencia_reverso']),
                  if (validacion['poliza'] != null && validacion['poliza'].toString().isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _abrirPdf(context, validacion['poliza']),
                      icon: const Icon(Icons.picture_as_pdf, color: AppColors.white),
                      label: Text('Ver Póliza de Seguro (PDF)', style: GoogleFonts.montserrat(color: AppColors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                    )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}