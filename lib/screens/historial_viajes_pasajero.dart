import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../core/utils/auth_helper.dart';
import '../services/viaje/viaje_service.dart';
import 'widgets/mic_button.dart';

class HistorialViajesPasajero extends StatefulWidget {
  const HistorialViajesPasajero({super.key});

  @override
  State<HistorialViajesPasajero> createState() => _HistorialViajesPasajero();
}

class _HistorialViajesPasajero extends State<HistorialViajesPasajero> {
  // Variables de estado
  String _filterSelected = 'Todos';
  bool _isVoiceActive = false;
  bool _isLoading = true;

  // Listas de datos
  List<dynamic> _viajesCompletos = [];
  List<dynamic> _viajesFiltrados = [];

  // Filtros completos (HEAD)
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
    _cargarHistorial();
  }

  // Estilo de texto flexible (Basado en Main)
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
        setState(() => _isLoading = false); // Asegurar que deje de cargar
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
                  v['estado'].toString().toLowerCase() ==
                  filtroNormalizado.toLowerCase(),
            )
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'En_curso':
        return AppColors.primary;
      case 'Finalizado':
        return const Color(0xFF16A34A);
      case 'Cancelado':
        return AppColors.error;
      case 'Agendado':
        return const Color(0xFFF59E0B);
      case 'Pendiente':
        return const Color(0xFFFBBF24);
      default:
        return AppColors.textSecondary;
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
              isVoiceActive: _isVoiceActive,
              onVoiceTap: () =>
                  setState(() => _isVoiceActive = !_isVoiceActive),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 35),
                _buildFilterMenu(),
              ],
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final viaje = _viajesFiltrados[index];
                    return _buildTripCard(
                      viaje['estado'].toString().replaceAll("_", " "),
                      _getStatusColor(viaje['estado']),
                      viaje['fecha_inicio'] ?? 'Fecha desconocida',
                      viaje['punto_inicio'] ?? 'Origen desconocido',
                      viaje['destino'] ?? 'Múltiples destinos',
                      viaje['nombre_conductor'],
                      viaje['foto_conductor'],
                    );
                  },
                  childCount: _viajesFiltrados.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 2),
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

  // Tarjeta híbrida: Datos de HEAD + Estilo de Main
  Widget _buildTripCard(
    String status,
    Color statusColor,
    String date,
    String origen,
    String destino,
    String? conductor,
    String? foto,
  ) {
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
          // Badge de estado
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
                status,
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

                // Sección de Origen y Destino (Datos de HEAD, Layout limpio)
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

                // Sección Conductor (Datos de HEAD + UI de Main)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: (foto != null && foto.isNotEmpty)
                          ? NetworkImage(foto) as ImageProvider
                          : const AssetImage('assets/conductor.png'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conductor ?? 'Buscando conductor...',
                          style: mFont(
                            size: 14,
                            color: AppColors.textPrimary,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Estrellas y Verificado (UI de Main)
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
                  ],
                ),
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
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          right: 15,
          bottom: -20,
          child: MicButton(isActive: isVoiceActive, onTap: onVoiceTap, size: 42),
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
