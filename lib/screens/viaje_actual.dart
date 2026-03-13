import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// Asegúrate de que las rutas a tus archivos locales sean correctas
import '../services/viaje/viaje_service.dart';
import 'widgets/bottom_sheet_finalizar_viaje.dart';

enum EstadoViaje {
  enCaminoAlOrigen,
  esperandoPasajero,
  viajeEnCurso,
  cobroYCalificacion,
  finalizado,
}

class ViajeActualMapa extends StatefulWidget {
  const ViajeActualMapa({super.key});

  @override
  State<ViajeActualMapa> createState() => _ViajeActualMapaState();
}

class _ViajeActualMapaState extends State<ViajeActualMapa>
    with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);

  bool _isVoiceActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // --- CONTROL DEL MAPA Y ESTADO ---
  final MapController _mapController = MapController();
  EstadoViaje _estadoActual = EstadoViaje.enCaminoAlOrigen;
  bool _isLoading = true;
  bool _isRecalculating = false; // Seguro anti-spam para OSRM
  Map<String, dynamic>? _datosViaje;
  String? _idViaje;

  // --- COORDENADAS ---
  LatLng? _ubicacionActual;
  LatLng? _origenViaje;
  LatLng? _destinoViaje;
  List<LatLng> _routePoints = [];

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('id_viaje')) {
      _idViaje = args['id_viaje'].toString();
    }
    
    _inicializarPantalla();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE INICIO Y GPS ---

  Future<void> _inicializarPantalla() async {
    await _iniciarRastreoUbicacion();
    await _cargarDatosViaje();
  }

  Future<void> _iniciarRastreoUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position initialPos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _ubicacionActual = LatLng(initialPos.latitude, initialPos.longitude);

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _ubicacionActual = LatLng(position.latitude, position.longitude);
            });

            if (!_isLoading) {
              try {
                _mapController.move(
                  _ubicacionActual!,
                  _mapController.camera.zoom,
                );
              } catch (e) {
                debugPrint("Esperando a que el mapa esté listo...");
              }
            }

            _verificarDesvioDeRuta();
          }
        });
  }

  Future<void> _cargarDatosViaje() async {
    if (_idViaje == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await ViajeService.obtenerViajeActual(_idViaje!);

      if (mounted) {
        setState(() {
          _datosViaje = data;
          final rutaData = data['ruta_data'] ?? data['ruta'];
          if (rutaData != null) {
            _origenViaje = LatLng(
              double.parse(rutaData['origen']['lat'].toString()),
              double.parse(rutaData['origen']['lng'].toString()),
            );
            _destinoViaje = LatLng(
              double.parse(rutaData['destino']['lat'].toString()),
              double.parse(rutaData['destino']['lng'].toString()),
            );
          }
        });

        await _actualizarRutaSegunEstado();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error: $e");
    }
  }

  // --- LÓGICA DE RUTAS Y DESVÍOS ---

  Future<void> _actualizarRutaSegunEstado() async {
    if (_ubicacionActual == null ||
        _origenViaje == null ||
        _destinoViaje == null)
      return;

    List<LatLng> nuevosPuntos = [];

    if (_estadoActual == EstadoViaje.enCaminoAlOrigen) {
      nuevosPuntos = await _obtenerRutaDesdeOSRM(
        _ubicacionActual!,
        _origenViaje!,
      );
    } else if (_estadoActual == EstadoViaje.esperandoPasajero) {
      nuevosPuntos = [];
    } else if (_estadoActual == EstadoViaje.viajeEnCurso) {
      nuevosPuntos = await _obtenerRutaDesdeOSRM(
        _ubicacionActual!,
        _destinoViaje!,
      );
    }

    if (mounted) {
      setState(() {
        _routePoints = nuevosPuntos;
      });
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
          return coordinates.map((coord) {
            return LatLng(
              double.parse(coord[1].toString()),
              double.parse(coord[0].toString()),
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("❌ Error OSRM: $e");
    }
    return [];
  }

  void _verificarDesvioDeRuta() async {
    if (_routePoints.isEmpty || _ubicacionActual == null || _isRecalculating)
      return;
    if (_estadoActual == EstadoViaje.esperandoPasajero ||
        _estadoActual == EstadoViaje.finalizado)
      return;

    double distanciaMinima = double.infinity;
    const distanceTool = Distance();

    for (LatLng punto in _routePoints) {
      double dist = distanceTool.as(LengthUnit.Meter, _ubicacionActual!, punto);
      if (dist < distanciaMinima) {
        distanciaMinima = dist;
      }
    }

    if (distanciaMinima > 70.0) {
      _isRecalculating = true;
      debugPrint(
        "⚠️ Desvío detectado ($distanciaMinima metros). Recalculando ruta...",
      );
      await _actualizarRutaSegunEstado();
      _isRecalculating = false;
    }
  }

  void _avanzarEstadoViaje() async {
    setState(() {
      switch (_estadoActual) {
        case EstadoViaje.enCaminoAlOrigen:
          _estadoActual = EstadoViaje.esperandoPasajero;
          break;
        case EstadoViaje.esperandoPasajero:
          _estadoActual = EstadoViaje.viajeEnCurso;
          break;
        case EstadoViaje.viajeEnCurso:
          _estadoActual = EstadoViaje.finalizado;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            builder: (context) => const FinalizarViajeBottomSheet(),
          );
          break;
        case EstadoViaje.finalizado:
        case EstadoViaje.cobroYCalificacion:
          break;
      }
    });

    if (_estadoActual != EstadoViaje.finalizado) {
      await _actualizarRutaSegunEstado();
    }
  }

  // --- UTILS DE DISEÑO Y DECODIFICACIÓN ---

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold({
    Color color = Colors.black,
    double size = 14,
    required double sw,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.bold,
    );
  }

  Widget _renderAvatar(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: cardBlue,
        child: Icon(Icons.person, color: primaryBlue, size: 24),
      );
    }
    try {
      final String cleanBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      Uint8List imageBytes = base64Decode(cleanBase64);
      return CircleAvatar(radius: 20, backgroundImage: MemoryImage(imageBytes));
    } catch (e) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: cardBlue,
        child: Icon(Icons.person, color: primaryBlue, size: 24),
      );
    }
  }

  String _getIconForDisability(String label) {
    switch (label.trim()) {
      case 'Tercera Edad':
        return 'assets/tercera_edad.png';
      case 'Movilidad reducida':
        return 'assets/silla_ruedas.png';
      case 'Discapacidad auditiva':
        return 'assets/auditiva.png';
      case 'Obesidad':
        return 'assets/obesidad.png';
      case 'Discapacidad visual':
        return 'assets/visual.png';
      default:
        return '';
    }
  }

  Map<String, dynamic> _getConfiguracionTarjeta() {
    switch (_estadoActual) {
      case EstadoViaje.enCaminoAlOrigen:
        return {
          'colorBoton': Colors.orange,
          'textoBoton': 'LLEGUÉ',
          'mostrarRuta': true,
        };
      case EstadoViaje.esperandoPasajero:
        return {
          'colorBoton': Colors.green,
          'textoBoton': 'INICIAR VIAJE',
          'mostrarRuta': false,
        };
      case EstadoViaje.viajeEnCurso:
        return {
          'colorBoton': Colors.redAccent,
          'textoBoton': 'FINALIZAR',
          'mostrarRuta': true,
        };
      default:
        return {
          'colorBoton': Colors.grey,
          'textoBoton': '...',
          'mostrarRuta': false,
        };
    }
  }

  // --- BUILD ---

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: lightBlueBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sp(10, sw),
                vertical: sp(5, sw),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: primaryBlue,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    _estadoActual == EstadoViaje.viajeEnCurso
                        ? 'En Camino al Destino'
                        : 'Recogiendo Pasajero',
                    style: mBold(size: 20, sw: sw),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: sp(15, sw)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: primaryBlue),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter:
                                      _ubicacionActual ??
                                      const LatLng(20.676667, -103.3475),
                                  initialZoom: 16.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.tuempresa.movecare',
                                  ),
                                  if (_routePoints.isNotEmpty)
                                    PolylineLayer(
                                      polylines: [
                                        Polyline(
                                          points: _routePoints,
                                          color: primaryBlue,
                                          strokeWidth: 5.0,
                                        ),
                                      ],
                                    ),
                                  MarkerLayer(
                                    markers: [
                                      if (_ubicacionActual != null)
                                        Marker(
                                          point: _ubicacionActual!,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.directions_car,
                                            color: primaryBlue,
                                            size: 40,
                                          ),
                                        ),
                                      if (_estadoActual ==
                                              EstadoViaje.enCaminoAlOrigen &&
                                          _origenViaje != null)
                                        Marker(
                                          point: _origenViaje!,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                            size: 40,
                                          ),
                                        ),
                                      if (_estadoActual ==
                                              EstadoViaje.viajeEnCurso &&
                                          _destinoViaje != null)
                                        Marker(
                                          point: _destinoViaje!,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 15,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isVoiceActive = !_isVoiceActive;
                                    if (_isVoiceActive) {
                                      _pulseController.repeat(reverse: true);
                                    } else {
                                      _pulseController.stop();
                                      _pulseController.reset();
                                    }
                                  });
                                },
                                child: ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Image.asset(
                                    _isVoiceActive
                                        ? 'assets/escuchando.png'
                                        : 'assets/controlvoz.png',
                                    width: sp(60, sw),
                                    height: sp(60, sw),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              right: 15,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildRouteCard(sw),
                                  // Verificación correcta para mostrar acompañante
                                  if (_datosViaje != null &&
                                      _datosViaje!['check_acompanante'] == true &&
                                      _datosViaje!['acompanante'] != null) ...[
                                    const SizedBox(height: 10),
                                    _buildAcompananteCard(sw),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(double sw) {
    if (_datosViaje == null) return const SizedBox.shrink();

    final config = _getConfiguracionTarjeta();
    
    // --- LECTURA CORRECTA DEL JSON ---
    final pasajeroData = _datosViaje!['pasajero'] ?? {};
    final pasajero = pasajeroData['nombre'] ?? 'Pasajero';
    final fotoBase64 = pasajeroData['foto_perfil'];
    final calificacion = pasajeroData['calificacion'] ?? '--';
    
    // Extraer discapacidades y convertirlas a una lista
    final stringDiscapacidades = pasajeroData['discapacidad'] ?? '';
    List<String> discapacidades = [];
    if (stringDiscapacidades.isNotEmpty) {
      discapacidades = stringDiscapacidades.split(',');
    }

    final rutaData = _datosViaje!['ruta_data'] ?? _datosViaje!['ruta'] ?? {};
    final String distancia = rutaData['distancia_km'] != null
        ? "${rutaData['distancia_km']} km"
        : "-- km";
    final String tiempo = rutaData['duracion_min'] != null
        ? "${rutaData['duracion_min']} min"
        : "-- min";

    return Container(
      padding: EdgeInsets.all(sp(15, sw)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Solución al OVERFLOW envolviendo en Expanded
              Expanded(
                child: config['mostrarRuta'] == true
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tiempo,
                            style: mBold(size: 22, color: Colors.green, sw: sw),
                          ),
                          Text(
                            '$distancia - Llegada estimada',
                            style: mBold(size: 13, color: Colors.grey, sw: sw),
                          ),
                        ],
                      )
                    : Text(
                        'Espera al pasajero en el punto de encuentro.',
                        style: mBold(size: 14, color: Colors.black87, sw: sw),
                      ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _avanzarEstadoViaje,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: config['colorBoton'],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    config['textoBoton'],
                    style: mBold(color: Colors.white, size: 12, sw: sw),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              _renderAvatar(fotoBase64),
              const SizedBox(width: 10),
              // Info pasajero + Iconos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pasajero,
                            style: mBold(size: 14, sw: sw),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(
                          calificacion,
                          style: mBold(size: 12, color: Colors.grey, sw: sw),
                        ),
                      ],
                    ),
                    if (discapacidades.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: discapacidades.map((d) {
                          String iconPath = _getIconForDisability(d);
                          if (iconPath.isEmpty) return const SizedBox.shrink();
                          return Image.asset(iconPath, width: 20, height: 20);
                        }).toList(),
                      ),
                    ]
                  ],
                ),
              ),
              
              //TODO
              // Vemos luego si le pongo funciones o no

              // IconButton(
              //   icon: const Icon(Icons.message, color: primaryBlue),
              //   onPressed: () {},
              //   padding: EdgeInsets.zero,
              //   constraints: const BoxConstraints(),
              // ),
              // const SizedBox(width: 10),
              // IconButton(
              //   icon: const Icon(Icons.phone, color: primaryBlue),
              //   onPressed: () {},
              //   padding: EdgeInsets.zero,
              //   constraints: const BoxConstraints(),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcompananteCard(double sw) {
    if (_datosViaje == null) return const SizedBox.shrink();

    final checkAcompanante = _datosViaje!['check_acompanante'] == true;
    final acompanante = _datosViaje!['acompanante'];

    if (!checkAcompanante || acompanante == null) return const SizedBox.shrink();

    final nombre = acompanante['nombre'] ?? 'Acompañante';
    final parentesco = acompanante['parentesco'] ?? '';
    // Como el JSON del acompañante no trae foto, le pasamos null para que _renderAvatar use el ícono genérico
    final fotoBase64 = acompanante['foto']; 

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sp(15, sw),
        vertical: sp(10, sw),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: lightBlueBg, width: 2),
      ),
      child: Row(
        children: [
          _renderAvatar(fotoBase64),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentesco.isNotEmpty ? "Acompañante ($parentesco)" : "Acompañante",
                  style: mBold(size: 10, color: Colors.grey, sw: sw),
                ),
                Text(
                  nombre,
                  style: mBold(size: 13, sw: sw),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
