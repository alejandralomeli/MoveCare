import 'dart:convert'; // 👈 IMPORTANTE: Necesario para decodificar Base64
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../core/utils/auth_helper.dart';
import '../services/viaje/viaje_service.dart';
import 'widgets/mic_button.dart';
import '../services/voz/voz_mixin.dart';

class HistorialViajesPasajero extends StatefulWidget {
  const HistorialViajesPasajero({super.key});

  @override
  State<HistorialViajesPasajero> createState() => _HistorialViajesPasajero();
}

class _HistorialViajesPasajero extends State<HistorialViajesPasajero> with VozMixin {
  // Variables de estado
  String _filterSelected = 'Todos';
  bool _isLoading = true;

  // Listas de datos
  List<dynamic> _viajesCompletos = [];
  List<dynamic> _viajesFiltrados = [];

  // Filtros completos
  final List<String> filters = [
    'Todos',
    'Pendiente',
    'Agendado',
    'En curso',
    'Finalizado',
    'Cancelado',
  ];

  @override
  void initState() {
    super.initState();
    inicializarVoz();
    _cargarHistorial();
  }

  // Estilo de texto flexible
  TextStyle mFont({
    Color color = AppColors.primary,
    double size = 14,
    FontWeight weight = FontWeight.w800,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  Future<void> _cargarHistorial() async {
    try {
      final data = await ViajeService.obtenerHistorial();
      if (mounted) {
        setState(() {
          _viajesCompletos = data;
          _viajesFiltrados = data;
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

  void _aplicarFiltro(String filtro) {
    setState(() {
      _filterSelected = filtro;
      if (filtro == 'Todos') {
        _viajesFiltrados = _viajesCompletos;
      } else {
        String filtroNormalizado = filtro.replaceAll(" ", "_");
        _viajesFiltrados = _viajesCompletos
            .where(
              (v) =>
                  v['estado']?.toString().toLowerCase() ==
                  filtroNormalizado.toLowerCase(),
            )
            .toList();
      }
    });
  }

  // 🚀 NUEVA FUNCIÓN: Decodificador seguro de Base64 a Imagen
  ImageProvider _getProfileImage(String? base64Data) {
    if (base64Data == null || base64Data.trim().isEmpty) {
      return const AssetImage('assets/conductor.png'); // Imagen por defecto
    }

    try {
      String cleanBase64 = base64Data;
      // Si el backend manda el prefijo "data:image/png;base64,", lo quitamos
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      // Quitamos espacios en blanco o saltos de línea indeseados
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

      return MemoryImage(base64Decode(cleanBase64));
    } catch (e) {
      // Si el string viene corrupto, mostramos el avatar por defecto y evitamos el crasheo
      return const AssetImage('assets/conductor.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: vozEscuchando || vozProcesando,
              onVoiceTap: () => escucharComando({
                'filtrar_completados': (_) => _aplicarFiltro('Finalizado'),
                'filtrar_cancelados': (_) => _aplicarFiltro('Cancelado'),
                'filtrar_todos': (_) => _aplicarFiltro('Todos'),
                'ir_atras': (_) => Navigator.pop(context),
              }),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [const SizedBox(height: 35), _buildFilterMenu()],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_viajesFiltrados.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  "No hay viajes en esta categoría",
                  style: mFont(
                    color: AppColors.textSecondary,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final viaje = _viajesFiltrados[index];
                  return _buildTripCard(viaje);
                }, childCount: _viajesFiltrados.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = _filterSelected == filter;
          return GestureDetector(
            onTap: () => _aplicarFiltro(filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: mFont(
                  color: isSelected ? AppColors.white : AppColors.primary,
                  size: 13,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripCard(dynamic viaje) {
    if (viaje == null) return const SizedBox.shrink();

    String estado = viaje['estado']?.toString().toLowerCase() ?? '';
    String statusText = 'Desconocido';
    Color statusColor = AppColors.primary;
    bool esFinalizado = false;

    if (estado == 'en_curso') {
      statusText = 'En Curso';
      statusColor = AppColors.primary;
    } else if (estado == 'agendado') {
      statusText = 'Agendado';
      statusColor = Colors.blue;
    } else if (estado == 'pendiente') {
      statusText = 'Pendiente';
      statusColor = Colors.orange;
    } else if (estado == 'finalizado' || estado == 'aceptado') {
      statusText = 'Finalizado';
      statusColor = const Color(0xFF16A34A);
      esFinalizado = true;
    } else if (estado == 'cancelado' || estado == 'rechazado') {
      statusText = 'Cancelado';
      statusColor = AppColors.error;
    }

    String origen =
        viaje['punto_inicio']?.toString() ??
        viaje['origen']?.toString() ??
        'Origen desconocido';
    String destino = viaje['destino']?.toString() ?? 'Destino desconocido';
    String date =
        viaje['fecha_inicio']?.toString() ??
        viaje['fecha']?.toString() ??
        '---';
    String conductor =
        viaje['nombre_conductor']?.toString() ??
        viaje['conductor']?.toString() ??
        'Buscando conductor...';

    // Obtenemos el texto en Base64
    String? fotoBase64 =
        viaje['foto_conductor']?.toString() ?? viaje['foto']?.toString();

    String idViaje =
        viaje['id_viaje']?.toString() ?? viaje['id']?.toString() ?? '';

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
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                statusText,
                style: mFont(
                  color: AppColors.white,
                  size: 11,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
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
                  'Fecha: $date',
                  style: mFont(
                    size: 12,
                    color: AppColors.primary,
                    weight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 15),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 15),

                Row(
                  children: [
                    // 🚀 APLICACIÓN DE LA IMAGEN EN BASE64
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: _getProfileImage(fotoBase64),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conductor,
                            style: mFont(
                              size: 14,
                              color: AppColors.textPrimary,
                              weight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.white,
                                      size: 10,
                                    ),
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
                  ],
                ),

                if (esFinalizado) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        if (idViaje.isNotEmpty) {
                          Navigator.pushNamed(
                            context,
                            '/reporte_incidencia_pasajero',
                            arguments: idViaje,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error: Viaje sin ID válido.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.flag_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      label: Text(
                        'Reportar incidencia',
                        style: mFont(
                          color: AppColors.error,
                          size: 12,
                          weight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppColors.error.withValues(
                          alpha: 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
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
              'Historial de Viajes',
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
        Positioned(
          right: 15,
          bottom: -20,
          child: MicButton(
            isActive: isVoiceActive,
            onTap: onVoiceTap,
            size: 42,
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
