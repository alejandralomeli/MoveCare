import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../services/viaje/viaje_service.dart';
import 'widgets/route_map_widget.dart';

class SolicitudViaje extends StatefulWidget {
  final String? idViaje;
  const SolicitudViaje({super.key, this.idViaje});

  @override
  State<SolicitudViaje> createState() => _SolicitudViajeState();
}

class _SolicitudViajeState extends State<SolicitudViaje> {
  bool _isLoading = true;
  Map<String, dynamic>? _viajeData;
  List<LatLng> _routePoints = [];

  // Se mantiene solo por compatibilidad de firma con el Delegate, pero sin uso funcional
  final bool _isVoiceActive = false;

  @override
  void initState() {
    super.initState();
    _cargarDetallesViaje();
  }

  // --- LÓGICA DE BACKEND Y MAPAS ---
  Future<void> _cargarDetallesViaje() async {
    try {
      // Si idViaje es nulo, deberías manejar un caso por defecto, aquí asumimos que viene
      final data = await ViajeService.obtenerViajeActual(widget.idViaje ?? '');

      List<LatLng> puntosRuta = [];
      final rutaData = data['ruta_data'] ?? data['ruta'];

      if (rutaData != null) {
        String polyline = rutaData['polyline'] ?? "";

        if (polyline.isNotEmpty && polyline != "sin_datos_de_polyline") {
          puntosRuta = ViajeService.decodificarPolyline(polyline);
        } else if (rutaData['origen'] != null && rutaData['destino'] != null) {
          double startLat = double.parse(rutaData['origen']['lat'].toString());
          double startLng = double.parse(rutaData['origen']['lng'].toString());
          double endLat = double.parse(rutaData['destino']['lat'].toString());
          double endLng = double.parse(rutaData['destino']['lng'].toString());

          puntosRuta = await _obtenerRutaDesdeOSRM(
            LatLng(startLat, startLng),
            LatLng(endLat, endLng),
          );
        }
      }

      if (mounted) {
        setState(() {
          _viajeData = data;
          _routePoints = puntosRuta;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar solicitud: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<List<LatLng>> _obtenerRutaDesdeOSRM(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          List<LatLng> puntos = coordinates.map((coord) {
            return LatLng(
              double.parse(coord[1].toString()),
              double.parse(coord[0].toString()),
            );
          }).toList();

          return puntos;
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo ruta desde OSRM: $e");
    }
    return [];
  }

  // --- PANEL DE ESTADO (ACEPTADO / RECHAZADO) ---
  void _mostrarPanelEstado(
    BuildContext context,
    String mensaje, {
    bool esAceptado = true,
  }) {
    final Color accentColor = esAceptado
        ? const Color(0xFF16A34A)
        : AppColors.error;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
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
              const SizedBox(height: 28),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                esAceptado
                    ? 'El pasajero ha sido notificado'
                    : 'La solicitud ha sido rechazada',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _toggleVoiceDummy() {
    // Ya no hace nada, se mantiene para la firma del Delegate
  }

  // --- ESTILOS ---
  TextStyle mBold({Color color = Colors.black, double size = 13}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DynamicHeaderDelegate(
                    maxHeight: 80,
                    minHeight: 80,
                    isVoiceActive: _isVoiceActive,
                    onVoiceTap: _toggleVoiceDummy,
                    screenWidth: sw,
                    title: 'Solicitud de Viaje',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        _buildMapContainer(),
                        const SizedBox(height: 25),
                        _buildTripDetailsCard(),
                        const SizedBox(height: 25),
                        _buildCompanionSelector(),
                        const SizedBox(height: 25),

                        // Información del Pasajero Principal
                        _buildUserInfoCard(isAcompanante: false),

                        // Si hay acompañante, se muestra su tarjeta
                        if (_viajeData?['check_acompanante'] == true) ...[
                          const SizedBox(height: 15),
                          _buildUserInfoCard(isAcompanante: true),
                        ],

                        const SizedBox(height: 30),
                        _buildActionButtons(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const DriverBottomNav(
        selectedIndex: 5,
      ), // Asegúrate de tener este widget definido en tu proyecto
    );
  }

  Widget _buildMapContainer() {
    LatLng? startCoord;
    LatLng? endCoord;
    double? distanciaTotal;

    final rutaData = _viajeData?['ruta_data'] ?? _viajeData?['ruta'];

    if (rutaData != null) {
      try {
        if (rutaData['origen'] != null) {
          startCoord = LatLng(
            double.parse(rutaData['origen']['lat'].toString()),
            double.parse(rutaData['origen']['lng'].toString()),
          );
        }
        if (rutaData['destino'] != null) {
          endCoord = LatLng(
            double.parse(rutaData['destino']['lat'].toString()),
            double.parse(rutaData['destino']['lng'].toString()),
          );
        }
        if (rutaData['distancia_km'] != null) {
          distanciaTotal = double.parse(rutaData['distancia_km'].toString());
        }
      } catch (e) {
        debugPrint("Error parseando la ruta en buildMapContainer: $e");
      }
    }

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RouteMapWidget(
          startCoord: startCoord,
          endCoord: endCoord,
          routePoints: _routePoints,
          distanciaTotalKm: distanciaTotal,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  Widget _buildTripDetailsCard() {
    final origen = _viajeData?['origen'] ?? 'Origen desconocido';
    final destino = _viajeData?['destino'] ?? 'Destino desconocido';
    final hora = _viajeData?['hora'] ?? '-- : --';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _locationItem(Icons.location_on_outlined, 'Desde', origen),
          const SizedBox(height: 12),
          _locationItem(Icons.flag_outlined, 'Destino', destino),
          const Divider(height: 24, color: AppColors.border),
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(hora, style: mSemibold(size: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: mBold(color: AppColors.primary, size: 10)),
              Text(
                subtitle,
                style: mBold(size: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanionSelector() {
    final bool tieneAcompanante = _viajeData?['check_acompanante'] == true;
    final String numeroMostrar = tieneAcompanante ? '2' : '1';
    final String textoMostrar = tieneAcompanante
        ? 'Con acompañante'
        : 'Sin acompañante';

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            numeroMostrar,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          textoMostrar,
          style: mBold(size: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard({required bool isAcompanante}) {
    String nombre = 'Desconocido';
    String calificacion = '5.0';
    String? fotoBase64;
    String discapacidadStr = '';

    if (isAcompanante) {
      final infoAcomp = _viajeData?['acompanante'];
      if (infoAcomp != null) {
        nombre = infoAcomp['nombre'] ?? 'Acompañante';
      }
    } else {
      final infoPasajero = _viajeData?['pasajero'];
      if (infoPasajero != null) {
        nombre = infoPasajero['nombre'] ?? 'Pasajero';
        calificacion = infoPasajero['calificacion']?.toString() ?? '5.0';
        fotoBase64 = infoPasajero['foto_perfil'];
        discapacidadStr = infoPasajero['discapacidad'] ?? '';
      }
    }

    ImageProvider imageProvider;
    if (fotoBase64 != null && fotoBase64.isNotEmpty) {
      try {
        String cleanBase64 = fotoBase64;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        imageProvider = MemoryImage(base64Decode(cleanBase64));
      } catch (e) {
        imageProvider = const AssetImage('assets/conductor.png');
      }
    } else {
      imageProvider = const AssetImage('assets/conductor.png');
    }

    List<Widget> iconosDiscapacidad = [];
    if (!isAcompanante && discapacidadStr.isNotEmpty) {
      final Map<String, String> mapaIconos = {
        'tercera edad': 'assets/tercera_edad.png',
        'movilidad reducida': 'assets/silla_ruedas.png',
        'discapacidad auditiva': 'assets/auditiva.png',
        'obesidad': 'assets/obesidad.png',
        'discapacidad visual': 'assets/visual.png',
      };

      List<String> listaDiscapacidades = discapacidadStr.split(',');

      for (String discap in listaDiscapacidades) {
        String key = discap.trim().toLowerCase();
        if (mapaIconos.containsKey(key)) {
          iconosDiscapacidad.add(
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Image.asset(
                mapaIconos[key]!,
                width: 35,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.accessible, color: AppColors.primary),
              ),
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        color: isAcompanante
            ? AppColors.surface
            : Colors.transparent, // Le da un toque distinto al acompañante
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: imageProvider,
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: mSemibold(size: 15)),
                if (!isAcompanante)
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 14,
                        ),
                      ),
                      Text(
                        ' $calificacion',
                        style: mBold(size: 11, color: AppColors.primary),
                      ),
                    ],
                  )
                else
                  Text(
                    'Acompañante',
                    style: mBold(size: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (iconosDiscapacidad.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: iconosDiscapacidad),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _btn(
            'Aceptar',
            const Color(0xFF16A34A),
            () => _mostrarPanelEstado(
              context,
              '¡Viaje Aceptado!',
              esAceptado: true,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _btn(
            'Rechazar',
            AppColors.error,
            () => _mostrarPanelEstado(
              context,
              '¡Viaje Rechazado!',
              esAceptado: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;
  final double screenWidth;
  final String title;

  _DynamicHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.onVoiceTap,
    required this.screenWidth,
    required this.title,
  });

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
          height: maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: screenWidth * (16 / 375),
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
  double get maxExtent => maxHeight;
  @override
  double get minExtent => minHeight;
  @override
  bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}
