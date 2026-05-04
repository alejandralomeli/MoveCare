import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart'; // Ajusta la ruta
import '../chat_viaje.dart'; // Ajusta la ruta

class PanelInferiorViaje extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, dynamic>? datosViaje;
  final String
  estadoViaje; // <-- Cambiado de int tripPhase a String estadoViaje
  final VoidCallback onTogglePanel;
  final VoidCallback onAvanzarFase;

  const PanelInferiorViaje({
    super.key,
    required this.scrollController,
    required this.datosViaje,
    required this.estadoViaje, // <-- Actualizado aquí
    required this.onTogglePanel,
    required this.onAvanzarFase,
  });

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildAvatar(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.border,
        child: Icon(Icons.person, color: AppColors.primary, size: 28),
      );
    }
    try {
      final String cleanBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return CircleAvatar(
        radius: 26,
        backgroundImage: MemoryImage(base64Decode(cleanBase64)),
      );
    } catch (e) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.border,
        child: Icon(Icons.person, color: AppColors.primary),
      );
    }
  }

  Widget _etaChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: mBold(color: color, size: 13)),
      ],
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pasajeroData = datosViaje?['pasajero'] ?? {};
    final rutaData = datosViaje?['ruta_data'] ?? datosViaje?['ruta'] ?? {};

    final nombre = pasajeroData['nombre'] ?? 'Cargando...';
    final fotoBase64 = pasajeroData['foto_perfil'];
    final calificacion = pasajeroData['calificacion'] ?? '--';
    final discapacidad = pasajeroData['discapacidad'] ?? 'Ninguna';

    final direccionDestino =
        rutaData['destino']?['direccion'] ?? 'Dirección no disponible';
    final tiempo = rutaData['duracion_aprox_min'] != null
        ? "${rutaData['duracion_aprox_min']} min"
        : "-- min";
    final distancia = rutaData['distancia_km'] != null
        ? "${rutaData['distancia_km']} km"
        : "-- km";

    // LÓGICA DEL BOTÓN BASADA EN EL ESTADO DEL BACKEND
    final bool esAgendado = estadoViaje == 'Agendado';
    final String textoBoton = esAgendado
        ? 'Confirmar recogida'
        : 'Finalizar viaje';
    final Color colorBoton = esAgendado ? AppColors.primary : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTogglePanel,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _etaChip(
                    Icons.access_time_rounded,
                    tiempo,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _etaChip(
                    Icons.route_rounded,
                    distancia,
                    AppColors.textSecondary,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'En Tiempo',
                      style: mBold(color: AppColors.success, size: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildAvatar(fotoBase64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: mBold(size: 15)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              calificacion,
                              style: mBold(
                                color: AppColors.textSecondary,
                                size: 12,
                              ),
                            ),
                            if (discapacidad != 'Ninguna' &&
                                discapacidad.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.accessible_forward_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  discapacidad,
                                  overflow: TextOverflow.ellipsis,
                                  style: mBold(
                                    color: AppColors.textSecondary,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _circleBtn(Icons.phone_rounded, AppColors.primary, () {}),
                  const SizedBox(width: 10),
                  _circleBtn(Icons.message_rounded, AppColors.primary, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatViaje(
                          nombreContacto: nombre,
                          esConductor: true,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        direccionDestino,
                        style: mBold(size: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onAvanzarFase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        colorBoton, // <-- Usamos el color calculado
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    textoBoton, // <-- Usamos el texto calculado
                    style: mBold(color: AppColors.white, size: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
