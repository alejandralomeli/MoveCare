import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/auditoria_model.dart';

class DetalleAuditoriaModal extends StatelessWidget {
  final Auditoria registro;

  const DetalleAuditoriaModal({super.key, required this.registro});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del modal
            Row(
              children: [
                const Icon(Icons.info_outline, color: primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Detalles del Movimiento',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey, size: 22),
                ),
              ],
            ),
            const Divider(height: 30, color: lightBlueBg, thickness: 1),
            
            // Contenido dinámico
            _buildFilaDetalle('Administrador:', registro.nombreAdmin),
            _buildFilaDetalle('Acción:', registro.accion),
            _buildFilaDetalle(
              'Tabla:', 
              registro.tablaAfectada.replaceAll('_', ' ').toUpperCase()
            ),
            
            if (registro.detalle != null && registro.detalle!.isNotEmpty)
              _buildFilaDetalle('Detalle:', registro.detalle!),
              
            // Estos solo se mostrarán si traen datos (como en validacion_usuario)
            if (registro.estadoValidacion != null)
              _buildFilaDetalle('Estado de validación:', registro.estadoValidacion!),
              
            if (registro.motivoRechazo != null)
              _buildFilaDetalle('Motivo de rechazo:', registro.motivoRechazo!),
              
            const SizedBox(height: 10),
            
            // Botón de cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de apoyo para pintar cada fila con estilo uniforme
  Widget _buildFilaDetalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.montserrat(
            color: Colors.black87, 
            fontSize: 13, 
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$titulo ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }
}