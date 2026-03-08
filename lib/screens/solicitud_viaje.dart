import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart'
    as http; // 🔥 Necesario para pedir la ruta a OSRM

// 🔥 Ajusta estas rutas si tus carpetas se llaman diferente
import '../services/viaje/viaje_service.dart';
import 'widgets/route_map_widget.dart';

class SolicitudViaje extends StatefulWidget {
  final String idViaje;

  const SolicitudViaje({super.key, required this.idViaje});

  @override
  State<SolicitudViaje> createState() => _SolicitudViajeState();
}

class _SolicitudViajeState extends State<SolicitudViaje>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);

  int _selectedIndex = 1;
  bool _isVoiceActive = false;

  late AnimationController _pulseController;

  bool _isLoading = true;
  Map<String, dynamic>? _viajeData;
  List<LatLng> _routePoints =
      []; // 🔥 Aquí guardaremos los puntos de la línea azul

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
          lowerBound: 1.0,
          upperBound: 1.15,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed && _isVoiceActive) {
            _pulseController.forward();
          }
        });

    _cargarDetallesViaje();
  }

  Future<void> _cargarDetallesViaje() async {
    try {
      final data = await ViajeService.obtenerViajeActual(widget.idViaje);

      List<LatLng> puntosRuta = [];
      final rutaData = data['ruta_data'] ?? data['ruta'];

      // 🔥 LÓGICA DE RUTA: Si el backend no manda la línea, la calculamos nosotros
      if (rutaData != null) {
        String polyline = rutaData['polyline'] ?? "";

        if (polyline.isNotEmpty && polyline != "sin_datos_de_polyline") {
          // 1. Usamos la ruta del backend si existe y es válida
          puntosRuta = ViajeService.decodificarPolyline(polyline);
        } else if (rutaData['origen'] != null && rutaData['destino'] != null) {
          // 2. Si dice "sin_datos_de_polyline", le pedimos el trazo a OSRM
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
          _routePoints = puntosRuta; // Asignamos la ruta al estado
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar solicitud: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<LatLng>> _obtenerRutaDesdeOSRM(LatLng start, LatLng end) async {
    try {
      // 🔥 CAMBIO CLAVE: Cambiamos "geometries=polyline" por "geometries=geojson"
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      print("📡 Pidiendo ruta a OSRM en formato GeoJSON...");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          // OSRM nos da la lista directa: [[longitud, latitud], [longitud, latitud], ...]
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          List<LatLng> puntos = coordinates.map((coord) {
            // LatLng pide (latitud, longitud), así que las acomodamos: coord[1], coord[0]
            return LatLng(
              double.parse(coord[1].toString()),
              double.parse(coord[0].toString()),
            );
          }).toList();

          print("✅ ¡ÉXITO! ${puntos.length} puntos exactos mapeados.");
          if (puntos.isNotEmpty) {
            print(
              "🗺️ Comprobación (debe decir 20.7..., -103...): ${puntos.first.latitude}, ${puntos.first.longitude}",
            );
          }

          return puntos;
        }
      }
    } catch (e) {
      debugPrint("❌ Error obteniendo ruta desde OSRM: $e");
    }
    return [];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _mostrarPanelEstado(
    BuildContext context,
    String mensaje,
    String imagen,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: lightBlueBg.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mensaje,
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 180,
                width: 180,
                child: Image.asset(
                  'assets/$imagen',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      imagen == 'aceptado.png'
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 120,
                      color: primaryBlue,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceActive = !_isVoiceActive;
      if (_isVoiceActive) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 16}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle mExtrabold(
    double sw, {
    Color color = Colors.black,
    double size = 20,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.w900,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DynamicHeaderDelegate(
                    maxHeight: 110,
                    minHeight: 85,
                    isVoiceActive: _isVoiceActive,
                    onVoiceTap: _toggleVoice,
                    screenWidth: sw,
                    pulseAnimation: _pulseController,
                    title: 'Solicitud de Viaje',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        _buildMapContainer(sw),
                        const SizedBox(height: 25),
                        _buildTripDetailsCard(sw),
                        const SizedBox(height: 25),
                        _buildCompanionSelector(sw),
                        const SizedBox(height: 25),
                        _buildUserInfoCard(sw, isAcompanante: false),

                        if (_viajeData?['check_acompanante'] == true) ...[
                          const SizedBox(height: 15),
                          _buildUserInfoCard(sw, isAcompanante: true),
                        ],

                        const SizedBox(height: 30),
                        // _buildActionButtons(sw, context),
                        // const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildMapContainer(double sw) {
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

    // 🔥 Inyectamos los puntos que ya calculamos arriba
    return RouteMapWidget(
      startCoord: startCoord,
      endCoord: endCoord,
      routePoints: _routePoints,
      distanciaTotalKm: distanciaTotal,
      isLoading: _isLoading,
    );
  }

  Widget _locationItem(
    double sw,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 28),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: mBold(sw, color: primaryBlue, size: 12)),
            Text(
              subtitle,
              style: mBold(
                sw,
                size: 14,
              ).copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripDetailsCard(double sw) {
    final origen = _viajeData?['origen'] ?? 'Origen desconocido';
    final destino = _viajeData?['destino'] ?? 'Destino desconocido';
    final hora = _viajeData?['hora'] ?? '-- : --';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlue.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _locationItem(sw, Icons.location_on, 'Desde', origen),
          const Divider(height: 20, color: Colors.transparent),
          _locationItem(sw, Icons.location_on, 'Destino', destino),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.access_time_filled, color: primaryBlue),
              const SizedBox(width: 10),
              Text(hora, style: mBold(sw, size: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionSelector(double sw) {
    final bool tieneAcompanante = _viajeData?['check_acompanante'] == true;
    final String numeroMostrar = tieneAcompanante ? '2' : '1';
    final String textoMostrar = tieneAcompanante
        ? 'Con acompañante'
        : 'Sin acompañante';

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 12),
          decoration: BoxDecoration(
            color: lightBlueBg,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(numeroMostrar, style: mExtrabold(sw, size: 26)),
        ),
        Text(textoMostrar, style: mBold(sw, size: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildUserInfoCard(double sw, {required bool isAcompanante}) {
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
                width: 28,
                errorBuilder: (c, e, s) => const Icon(Icons.info_outline),
              ),
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: primaryBlue.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        color: isAcompanante ? cardBlue.withOpacity(0.3) : Colors.transparent,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: lightBlueBg,
            backgroundImage: imageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: mBold(sw, size: 16)),
                if (!isAcompanante)
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                      Text(
                        ' $calificacion',
                        style: mBold(sw, size: 10, color: primaryBlue),
                      ),
                    ],
                  )
                else
                  Text(
                    'Acompañante',
                    style: mBold(sw, size: 12, color: Colors.grey),
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

  Widget _buildActionButtons(double sw, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _btn(
            sw,
            'Aceptar',
            () => _mostrarPanelEstado(
              context,
              '¡Viaje Aceptado!',
              'aceptado.png',
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _btn(
            sw,
            'Rechazar',
            () => _mostrarPanelEstado(
              context,
              '¡Viaje Rechazado!',
              'rechazado.png',
            ),
          ),
        ),
      ],
    );
  }

  Widget _btn(double sw, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: lightBlueBg,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: sw * (18 / 375),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: cardBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [0, 1, 2, 3]
            .map(
              (i) => _navIcon(
                i,
                i == 0
                    ? Icons.home
                    : i == 1
                    ? Icons.location_on
                    : i == 2
                    ? Icons.bar_chart
                    : Icons.person,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
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
  final Animation<double> pulseAnimation;
  final String title;

  _DynamicHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.onVoiceTap,
    required this.screenWidth,
    required this.pulseAnimation,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double percent = shrinkOffset / maxHeight;
    final double opacity = 1.0 - percent.clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFB3D4FF)),
          child: Opacity(
            opacity: opacity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: screenWidth * (20 / 375),
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 35,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1559B2),
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          right: 20,
          bottom: -28,
          child: GestureDetector(
            onTap: onVoiceTap,
            child: ScaleTransition(
              scale: pulseAnimation,
              child: SizedBox(
                height: 65,
                width: 65,
                child: Image.asset(
                  isVoiceActive
                      ? 'assets/escuchando.png'
                      : 'assets/controlvoz.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
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
