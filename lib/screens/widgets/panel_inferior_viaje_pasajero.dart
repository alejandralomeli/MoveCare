import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 1. Agregado
import '../../app_theme.dart';
import '../chat_viaje.dart';
import '../../providers/user_provider.dart';

class PanelInferiorViajePasajero extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, dynamic>? datosViaje;
  final String estadoViaje;
  final VoidCallback onTogglePanel;
  final VoidCallback onAvanzarFase;

  const PanelInferiorViajePasajero({
    super.key,
    required this.scrollController,
    required this.datosViaje,
    required this.estadoViaje,
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

  // ... (Tus métodos _buildAvatar, _etaChip y _circleBtn se mantienen igual)
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
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. OBTENCIÓN DE DATOS DE USUARIO Y VIAJE
    final user = context.read<UserProvider>().user;
    final String idViaje = datosViaje?['id_viaje']?.toString() ?? '';

    final conductor = datosViaje?['conductor'];
    final vehiculo = conductor?['vehiculo'];
    final rutaData = datosViaje?['ruta_data'] ?? {};

    final String nombreChofer = conductor?['nombre'] ?? 'Buscando...';
    final String fotoChofer = conductor?['foto_perfil'] ?? '';
    final String calificacion = conductor?['calificacion'] ?? '5.0';
    
    final String modeloAuto = vehiculo?['modelo'] ?? 'Vehículo';
    final String placaAuto = vehiculo?['placa'] ?? '---';
    final String colorAuto = vehiculo?['color'] ?? '';
    final String infoAutoFull = colorAuto.isNotEmpty ? "$modeloAuto ($colorAuto)" : modeloAuto;

    final String direccionDestino = rutaData['destino']?['direccion'] ?? 'Destino no disponible';
    final String tiempo = rutaData['duracion_aprox_min'] != null
        ? "${rutaData['duracion_aprox_min']} min"
        : "-- min";
    final String distancia = rutaData['distancia_km'] != null
        ? "${rutaData['distancia_km']} km"
        : "-- km";

    final bool esAgendado = estadoViaje == 'Agendado';
    final String textoBoton = esAgendado ? 'Ver PIN de Seguridad' : 'Viaje en curso';
    final Color colorBoton = esAgendado ? AppColors.primary : AppColors.success;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
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
                  _etaChip(Icons.access_time_rounded, tiempo, AppColors.primary),
                  const SizedBox(width: 10),
                  _etaChip(Icons.route_rounded, distancia, AppColors.textSecondary),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Seguro', style: mBold(color: AppColors.success, size: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),

              Row(
                children: [
                  _buildAvatar(fotoChofer),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombreChofer, style: mBold(size: 15)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(calificacion, style: mBold(size: 12, color: AppColors.textSecondary)),
                            const SizedBox(width: 12),
                            const Icon(Icons.directions_car_filled_rounded, color: AppColors.textSecondary, size: 14),
                            const SizedBox(width: 4),
                            Text(placaAuto, style: mBold(color: AppColors.primary, size: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _circleBtn(Icons.phone_rounded, AppColors.primary, () {
                    // Implementación de llamada telefónica
                  }),
                  const SizedBox(width: 10),
                  // 3. BOTÓN DE CHAT CORREGIDO
                  _circleBtn(Icons.message_rounded, AppColors.primary, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatViaje(
                          nombreContacto: nombreChofer,
                          esConductor: false, // El usuario es pasajero
                          idViaje: idViaje,
                          idUsuarioActual: user?.idUsuario ?? '',
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(infoAutoFull, style: mBold(size: 13))),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            direccionDestino,
                            style: mBold(size: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: esAgendado ? onAvanzarFase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorBoton,
                    disabledBackgroundColor: AppColors.border,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    textoBoton,
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