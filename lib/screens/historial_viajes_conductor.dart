import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../core/utils/auth_helper.dart'; // Ajusta según tu estructura
import '../services/viaje/viaje_service.dart'; // Ajusta según tu estructura

class HistorialViajesConductor extends StatefulWidget {
  const HistorialViajesConductor({super.key});

  @override
  State<HistorialViajesConductor> createState() =>
      _HistorialViajesConductorState();
}

class _HistorialViajesConductorState extends State<HistorialViajesConductor> {
  String _filterSelected = 'Todos';
  bool _isLoading = true;

  List<dynamic> _viajesCompletos = [];
  List<dynamic> _viajesFiltrados = [];

  final List<String> filters = [
    'Todos',
    'En curso',
    'Pendiente',
    'Agendado', // 🔥 NUEVO ESTADO AQUÍ
    'Finalizado',
    'Cancelado',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // --- CARGA DE DATOS DESDE EL BACKEND ---
  Future<void> _cargarDatos() async {
    try {
      final data = await ViajeService.obtenerHistorialConductor();
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

  // --- LÓGICA DE FILTRADO ---
  void _aplicarFiltro(String label) {
    setState(() {
      _filterSelected = label;
      if (label == 'Todos') {
        _viajesFiltrados = _viajesCompletos;
      } else {
        // Convierte "En curso" -> "en_curso" para comparar exactamente con el API
        String busca = label.toLowerCase().replaceAll(" ", "_");
        _viajesFiltrados = _viajesCompletos.where((v) {
          return v['estado'].toString().toLowerCase() == busca;
        }).toList();
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(pinned: true, delegate: _HeaderDelegate()),
          SliverToBoxAdapter(child: _buildFilterMenu()),

          // --- RENDERIZADO CONDICIONAL DE LA LISTA ---
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
                  'No hay registros',
                  style: mFont(color: AppColors.textSecondary, size: 16),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildTripCard(_viajesFiltrados[index]);
                }, childCount: _viajesFiltrados.length),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(
        selectedIndex: 3,
      ), // Asegúrate de tener este widget en tu proyecto
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
    String estado = viaje['estado'].toString().toLowerCase();
    String statusText = 'Desconocido';
    Color statusColor = AppColors.primary;
    bool esFinalizado = false;

    // Colores y textos adaptados a tu base de datos y nuevo diseño
    if (estado == 'en_curso') {
      statusText = 'En Curso';
      statusColor = AppColors.primary;
    } else if (estado == 'agendado') {
      // 🔥 NUEVA CONDICIÓN PARA AGENDADO
      statusText = 'Agendado';
      statusColor =
          Colors.blue; // Puedes usar un azul de tu AppColors si lo prefieres
    } else if (estado == 'pendiente') {
      statusText = 'Pendiente';
      statusColor = Colors.orange;
    } else if (estado == 'finalizado' || estado == 'aceptado') {
      statusText = 'Finalizado';
      statusColor = const Color(0xFF16A34A);
      esFinalizado = true; // Variable para controlar la visibilidad del botón
    } else if (estado == 'cancelado' || estado == 'rechazado') {
      statusText = 'Cancelado';
      statusColor = AppColors.error;
    }

    String origen = viaje['punto_inicio'] ?? 'Origen desconocido';
    String destino = viaje['destino'] ?? 'Destino desconocido';
    String date = viaje['fecha_inicio'] ?? '---';
    String pasajero = viaje['nombre_pasajero'] ?? 'Pasajero';

    // Extracción segura del ID del viaje (Ajusta 'id_viaje' si tu API lo manda con otro nombre)
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage:
                          (viaje['foto_pasajero'] != null &&
                              viaje['foto_pasajero'].isNotEmpty)
                          ? NetworkImage(viaje['foto_pasajero'])
                                as ImageProvider
                          : const AssetImage('assets/conductor.png'),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pasajero,
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
                    // Iconos dinámicos de necesidades especiales
                    _buildDiscapacidadIcons(viaje['necesidad_especial']),
                  ],
                ),

                // 🚀 AQUÍ AÑADIMOS EL BOTÓN CONDICIONAL DE REPORTE
                if (esFinalizado) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        // Reemplaza '/reporte_incidencia' por el nombre de ruta real en tu MaterialApp
                        Navigator.pushNamed(
                          context,
                          '/reporte_incidencia_conductor',
                          arguments: idViaje,
                        );
                      },
                      icon: const Icon(
                        Icons.flag_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      label: Text(
                        'Reportar',
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
                // ----------------------------------------------------
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PROCESAMIENTO DE TEXTO DE DISCAPACIDADES ---
  Widget _buildDiscapacidadIcons(String? textoNecesidades) {
    if (textoNecesidades == null ||
        textoNecesidades.isEmpty ||
        textoNecesidades.toLowerCase() == 'ninguna') {
      return const SizedBox.shrink();
    }

    List<String> lista = textoNecesidades
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: lista.map((n) {
        String path = 'assets/tercera_edad.png';

        if (n.contains('tercera edad'))
          path = 'assets/tercera_edad.png';
        else if (n.contains('movilidad') || n.contains('silla'))
          path = 'assets/silla_ruedas.png';
        else if (n.contains('auditiva'))
          path = 'assets/auditiva.png';
        else if (n.contains('obesidad'))
          path = 'assets/obesidad.png';
        else if (n.contains('visual'))
          path = 'assets/visual.png';

        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Image.asset(
              path,
              width: 24,
              height: 24,
              errorBuilder: (c, e, s) => const Icon(
                Icons.accessibility_new,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
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
      ],
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => false;
}
