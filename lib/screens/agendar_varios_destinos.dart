import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/widgets/modals/confirm_modal.dart';
import '../services/acompanante/acompanante_service.dart';
import '../services/viaje/viaje_service.dart';
import '../services/pagos/pagos_service.dart';
import '../core/utils/auth_helper.dart';

class AgendarVariosDestinos extends StatefulWidget {
  const AgendarVariosDestinos({super.key});

  @override
  State<AgendarVariosDestinos> createState() => _AgendarVariosDestinosState();
}

class _AgendarVariosDestinosState extends State<AgendarVariosDestinos> {
  // --- CONSTANTES DE COLOR ---
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color labelBlue = Color(0xFF42A5F5);

  // --- VARIABLES DE ESTADO (LÓGICA) ---
  bool _isCreatingTrip = false;
  bool _isVoiceActive = false; // Estado para el header dinámico

  // Controladores de Texto
  final List<TextEditingController> _destinoControllers = [];
  final TextEditingController origenController = TextEditingController();

  // Fechas y Horas
  DateTime _weekStart = DateTime.now();
  DateTime? _selectedDateTime;
  String? selectedHour;
  String? selectedMinute;

  // Listas para Dropdowns
  final List<String> hoursList = List.generate(
    24,
    (index) => index.toString().padLeft(2, '0'),
  );
  final List<String> minutesList = List.generate(
    60,
    (index) => index.toString().padLeft(2, '0'),
  );

  final List<String> zmgLocations = [
    'Guadalajara Centro',
    'Zapopan Centro',
    'Tlaquepaque',
    'Tonalá',
    'Tlajomulco',
    'Chapalita',
    'Providencia',
    'Puerta de Hierro',
    'Colonia Americana',
    'Andares',
    'Plaza del Sol',
    'Estadio Jalisco',
    'Expo Guadalajara',
  ];

  final List<String> needsList = [
    'Tercera Edad',
    'Movilidad reducida',
    'Discapacidad auditiva',
    'Obesidad',
    'Discapacidad visual',
  ];

  // Variables de Selección
  String? selectedNeed;
  String? especificaciones;
  String? selectedPayment;
  int _cantidadDestinos = 2;
  int _selectedIndex = 1;

  // ACOMPAÑANTES
  String? selectedAcompananteId;
  List<Map<String, String>> acompanantes = [];
  bool cargandoAcompanantes = false;
  bool hasCompanion = false;

  // TARJETAS
  String? selectedTarjetaId;
  List<Map<String, String>> tarjetas = [];
  bool cargandoTarjetas = false;

  // --- ESTILOS DE TEXTO (RESPONSIVE) ---
  TextStyle mSemibold(
    double sw, {
    Color color = Colors.black,
    double size = 14,
  }) => GoogleFonts.montserrat(
    color: color,
    fontSize: (sw * (size / 375)),
    fontWeight: FontWeight.w600,
  );

  TextStyle mExtrabold(
    double sw, {
    Color color = Colors.black,
    double size = 18,
  }) => GoogleFonts.montserrat(
    color: color,
    fontSize: (sw * (size / 375)),
    fontWeight: FontWeight.w800,
  );

  TextStyle labelStyle(double sw, {double size = 14}) => GoogleFonts.montserrat(
    color: labelBlue,
    fontSize: (sw * (size / 375)),
    fontWeight: FontWeight.w700,
  );

  // --- MÉTODOS DE CICLO DE VIDA ---
  @override
  void initState() {
    super.initState();
    _syncDestinoControllers();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    origenController.dispose();
    for (var controller in _destinoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _cargarDatosIniciales() async {
    await Future.wait([_cargarAcompanantes(), _cargarTarjetas()]);
  }

  Future<void> _cargarAcompanantes() async {
    setState(() => cargandoAcompanantes = true);
    try {
      final List<dynamic> data = await AcompananteService.obtenerAcompanantes();
      acompanantes = data.map<Map<String, String>>((a) {
        return {
          "id": a["id_acompanante"].toString(),
          "nombre": a["nombre_completo"].toString(),
        };
      }).toList();
    } catch (e) {
      acompanantes = [];
      if (mounted) AuthHelper.manejarError(context, e);
    }
    if (mounted) setState(() => cargandoAcompanantes = false);
  }

  Future<void> _cargarTarjetas() async {
    setState(() => cargandoTarjetas = true);
    try {
      final List<dynamic> data = await PagosService.obtenerTarjetas();
      tarjetas = data.map<Map<String, String>>((t) {
        return {
          "id": t["id_tarjeta"].toString(),
          "texto": "${t['marca']} •••• ${t['ultimos_cuatro']}",
        };
      }).toList();
    } catch (e) {
      tarjetas = [];
      print("Error cargando tarjetas: $e");
    }
    if (mounted) setState(() => cargandoTarjetas = false);
  }

  void _syncDestinoControllers() {
    setState(() {
      if (_destinoControllers.length < _cantidadDestinos) {
        for (int i = _destinoControllers.length; i < _cantidadDestinos; i++) {
          _destinoControllers.add(TextEditingController());
        }
      } else if (_destinoControllers.length > _cantidadDestinos) {
        for (int i = _cantidadDestinos; i < _destinoControllers.length; i++) {
          _destinoControllers[i].dispose();
        }
        _destinoControllers.removeRange(
          _cantidadDestinos,
          _destinoControllers.length,
        );
      }
    });
  }

  // --- LÓGICA DE CREACIÓN DE VIAJE ---
  DateTime _buildFechaHoraInicio() {
    if (_selectedDateTime == null) throw Exception('Selecciona una fecha');
    if (selectedHour == null || selectedMinute == null)
      throw Exception('Selecciona una hora');
    return DateTime(
      _selectedDateTime!.year,
      _selectedDateTime!.month,
      _selectedDateTime!.day,
      int.parse(selectedHour!),
      int.parse(selectedMinute!),
    );
  }

  List<Map<String, dynamic>> _buildDestinosPayload() {
    final List<Map<String, dynamic>> destinos = [];
    for (int i = 0; i < _destinoControllers.length; i++) {
      final text = _destinoControllers[i].text.trim();
      if (text.isEmpty) throw Exception('Completa todos los destinos');
      destinos.add({"direccion": text, "orden": i + 1});
    }
    return destinos;
  }

  Future<void> _crearViaje() async {
    if (_isCreatingTrip) return;

    // Validaciones
    bool esPagoConTarjeta =
        (selectedPayment == 'Tarjeta de crédito' ||
        selectedPayment == 'Tarjeta de débito');

    if (esPagoConTarjeta && selectedTarjetaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tarjeta'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (origenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el punto de origen')),
      );
      return;
    }
    if (_selectedDateTime == null ||
        selectedHour == null ||
        selectedMinute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora')),
      );
      return;
    }
    if (hasCompanion && selectedAcompananteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un acompañante o desmarque la casilla'),
        ),
      );
      return;
    }

    setState(() => _isCreatingTrip = true);

    try {
      final fechaHoraInicio = _buildFechaHoraInicio();
      final destinos = _buildDestinosPayload();

      final viajeId = await ViajeService.crearViaje(
        puntoInicio: origenController.text.trim(),
        destino: null, // Es null porque usamos 'destinos' (lista)
        destinos: destinos,
        checkVariosDestinos: true,
        fechaHoraInicio: fechaHoraInicio.toIso8601String(),
        metodoPago: selectedPayment ?? 'Efectivo',
        idMetodo: esPagoConTarjeta ? selectedTarjetaId : null,
        especificaciones: especificaciones,
        checkAcompanante: hasCompanion,
        idAcompanante: hasCompanion ? selectedAcompananteId : null,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/principal_pasajero',
        arguments: viajeId,
      );
    } catch (e) {
      if (!mounted) return;
      AuthHelper.manejarError(context, e);
    } finally {
      if (mounted) setState(() => _isCreatingTrip = false);
    }
  }

  // --- LÓGICA DE FECHAS ---
  String _dayLetter(DateTime d) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[d.weekday - 1];
  }

  List<DateTime> get _diasSemana =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sw = size.width;
    bool isCardPayment =
        selectedPayment == 'Tarjeta de crédito' ||
        selectedPayment == 'Tarjeta de débito';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _DynamicHeaderDelegate(
              maxHeight: 110,
              minHeight: 85,
              isVoiceActive: _isVoiceActive,
              onVoiceTap: () =>
                  setState(() => _isVoiceActive = !_isVoiceActive),
              screenWidth: sw,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildInstructionBadge(sw),
                  const SizedBox(height: 15),

                  // Selector de Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seleccionar fecha',
                        style: mExtrabold(sw, size: 20),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => setState(
                              () => _weekStart = _weekStart.subtract(
                                const Duration(days: 7),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => setState(
                              () => _weekStart = _weekStart.add(
                                const Duration(days: 7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDateRow(sw),
                  const SizedBox(height: 20),

                  // Formulario Principal
                  Container(
                    padding: EdgeInsets.all(sw * 0.05),
                    decoration: BoxDecoration(
                      color: containerBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seleccionar hora', style: mSemibold(sw)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeDropdown(
                                'Hora',
                                hoursList,
                                selectedHour,
                                (v) => setState(() => selectedHour = v),
                                sw,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTimeDropdown(
                                'Minutos',
                                minutesList,
                                selectedMinute,
                                (v) => setState(() => selectedMinute = v),
                                sw,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text('Lugar', style: mSemibold(sw)),
                        const SizedBox(height: 8),
                        _buildZMGAutocomplete(
                          'Ubicación actual',
                          origenController,
                          sw,
                        ),

                        const SizedBox(height: 15),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Cantidad de destinos',
                                style: mSemibold(
                                  sw,
                                  color: primaryBlue,
                                  size: 12,
                                ),
                              ),
                              _buildStepperDestinos(sw),
                            ],
                          ),
                        ),

                        // Generación de Inputs Dinámicos
                        ...List.generate(_cantidadDestinos, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildZMGAutocomplete(
                              'Parada ${index + 1}',
                              _destinoControllers[index],
                              sw,
                            ),
                          );
                        }),

                        const SizedBox(height: 15),
                        _buildCompanionSection(sw),
                        const SizedBox(height: 10),

                        if (hasCompanion) ...[
                          _buildAcompananteDropdown(sw),
                          const SizedBox(height: 10),
                          _buildRegistrarAcompananteButton(sw),
                          const SizedBox(height: 15),
                        ],

                        _buildSpecialNeedDropdown(sw),
                        const SizedBox(height: 15),

                        Center(
                          child: Text(
                            'Seleccionar forma de pago',
                            style: mSemibold(sw, color: primaryBlue, size: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSimpleDropdown(
                          'Forma de pago',
                          Icons.monetization_on_outlined,
                          [
                            'Tarjeta de crédito',
                            'Tarjeta de débito',
                            'Efectivo',
                          ],
                          selectedPayment,
                          (v) => setState(() {
                            selectedPayment = v;
                            if (!isCardPayment) selectedTarjetaId = null;
                          }),
                          sw,
                        ),

                        if (isCardPayment) ...[
                          const SizedBox(height: 15),
                          _buildTarjetaDropdown(sw),
                          const SizedBox(height: 10),
                          _buildRegistrarTarjetaButton(sw),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(sw),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildDateRow(double sw) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _diasSemana.map((date) {
          final isPast = date.isBefore(
            DateTime.now().subtract(const Duration(days: 1)),
          );
          final isSelected =
              _selectedDateTime != null &&
              date.day == _selectedDateTime!.day &&
              date.month == _selectedDateTime!.month;

          return GestureDetector(
            onTap: isPast
                ? null
                : () => setState(() => _selectedDateTime = date),
            child: Opacity(
              opacity: isPast ? 0.4 : 1,
              child: _dateItem(
                _dayLetter(date),
                date.day.toString(),
                isSelected,
                sw,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateItem(String day, String num, bool isSelected, double sw) {
    return Container(
      width: sw * 0.155,
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: mSemibold(sw, color: Colors.white, size: 11),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(num, style: mExtrabold(sw, color: primaryBlue, size: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperDestinos(double sw) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (_cantidadDestinos > 2) {
              setState(() {
                _cantidadDestinos--;
                _syncDestinoControllers();
              });
            }
          },
          icon: const Icon(Icons.remove_circle, color: primaryBlue, size: 28),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$_cantidadDestinos',
            style: mSemibold(sw, color: Colors.white, size: 16),
          ),
        ),
        IconButton(
          onPressed: () {
            if (_cantidadDestinos < 5) {
              setState(() {
                _cantidadDestinos++;
                _syncDestinoControllers();
              });
            }
          },
          icon: const Icon(Icons.add_circle, color: primaryBlue, size: 28),
        ),
      ],
    );
  }

  Widget _buildZMGAutocomplete(
    String hint,
    TextEditingController controller,
    double sw,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (v) => v.text.isEmpty
            ? const Iterable.empty()
            : zmgLocations.where(
                (l) => l.toLowerCase().contains(v.text.toLowerCase()),
              ),
        onSelected: (v) => controller.text = v,
        fieldViewBuilder: (c, ct, f, o) {
          if (ct.text.isEmpty && controller.text.isNotEmpty)
            ct.text = controller.text;
          return TextField(
            controller: ct,
            focusNode: f,
            onChanged: (text) => controller.text = text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: labelStyle(sw),
              icon: const Icon(Icons.location_on, color: primaryBlue, size: 20),
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeDropdown(
    String h,
    List<String> i,
    String? v,
    Function(String?) o,
    double sw,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: v,
          hint: Text(h, style: labelStyle(sw, size: 12)),
          isExpanded: true,
          items: i
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: o,
        ),
      ),
    );
  }

  Widget _buildSpecialNeedDropdown(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedNeed,
          hint: Text('Necesidad especial', style: labelStyle(sw, size: 13)),
          isExpanded: true,
          items: needsList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() {
            selectedNeed = v;
            especificaciones = v;
          }),
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(
    String h,
    IconData i,
    List<String> it,
    String? v,
    Function(String?) o,
    double sw,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: v,
          hint: Row(
            children: [
              Icon(i, color: primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(h, style: labelStyle(sw, size: 13)),
            ],
          ),
          isExpanded: true,
          items: it
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: o,
        ),
      ),
    );
  }

  Widget _buildAcompananteDropdown(double sw) {
    if (cargandoAcompanantes)
      return const Center(child: CircularProgressIndicator());
    return _buildSimpleDropdown(
      acompanantes.isEmpty ? 'Sin acompañantes' : 'Selecciona acompañante',
      Icons.person,
      acompanantes.map((a) => a["nombre"]!).toList(),
      acompanantes.firstWhere(
                (element) => element["id"] == selectedAcompananteId,
                orElse: () => {"nombre": ""},
              )["nombre"] ==
              ""
          ? null
          : acompanantes.firstWhere(
              (element) => element["id"] == selectedAcompananteId,
            )["nombre"],
      (nombre) {
        final id = acompanantes.firstWhere((a) => a["nombre"] == nombre)["id"];
        setState(() => selectedAcompananteId = id);
      },
      sw,
    );
  }

  Widget _buildTarjetaDropdown(double sw) {
    if (cargandoTarjetas)
      return const Center(child: CircularProgressIndicator());
    return _buildSimpleDropdown(
      tarjetas.isEmpty ? 'Registrar Tarjeta' : 'Selecciona tu tarjeta',
      Icons.credit_card,
      tarjetas.map((t) => t["texto"]!).toList(),
      tarjetas.firstWhere(
                (element) => element["id"] == selectedTarjetaId,
                orElse: () => {"texto": ""},
              )["texto"] ==
              ""
          ? null
          : tarjetas.firstWhere(
              (element) => element["id"] == selectedTarjetaId,
            )["texto"],
      (texto) {
        final id = tarjetas.firstWhere((t) => t["texto"] == texto)["id"];
        setState(() => selectedTarjetaId = id);
      },
      sw,
    );
  }

  Widget _buildRegistrarAcompananteButton(double sw) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          '/registro_acompanante',
        ).then((_) => _cargarAcompanantes()),
        icon: const Icon(Icons.person_add, size: 18, color: primaryBlue),
        label: Text(
          "Registrar nuevo acompañante",
          style: mSemibold(sw, color: primaryBlue),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrarTarjetaButton(double sw) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          '/registro_tarjeta',
        ).then((_) => _cargarTarjetas()),
        icon: const Icon(Icons.add_card, color: Colors.white, size: 18),
        label: Text(
          "Registrar Tarjeta",
          style: mSemibold(sw, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCompanionSection(double sw) {
    return Row(
      children: [
        Checkbox(
          value: hasCompanion,
          activeColor: primaryBlue,
          onChanged: (v) => setState(() => hasCompanion = v!),
        ),
        Text(
          'Registrar acompañante',
          style: mSemibold(sw, color: accentBlue, size: 13),
        ),
      ],
    );
  }

  Widget _buildInstructionBadge(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: accentBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Ingresa los datos para agendar',
            style: mSemibold(sw, color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double sw) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            minimumSize: Size(sw * 0.6, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            'Mostrar estimación',
            style: mSemibold(sw, color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _actionBtn(
                  'Agendar viaje',
                  accentBlue,
                  sw,
                  () => showConfirmModal(
                    context: context,
                    title: '¿Está seguro?',
                    onConfirm: _crearViaje,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _actionBtn(
                  'Cancelar',
                  accentBlue,
                  sw,
                  () =>
                      Navigator.pushReplacementNamed(context, '/home_pasajero'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(String l, Color c, double sw, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: c,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        l,
        textAlign: TextAlign.center,
        style: mSemibold(sw, color: Colors.white, size: 12),
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: sw * 0.2,
      decoration: const BoxDecoration(color: containerBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home),
          _navIcon(1, Icons.location_on),
          _navIcon(2, Icons.history),
          _navIcon(3, Icons.person),
        ],
      ),
    );
  }

  Widget _navIcon(int i, IconData ic) {
    bool a = _selectedIndex == i;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = i);
        if (i == 0)
          Navigator.pushReplacementNamed(context, '/principal_pasajero');
        // Agregar otras rutas aquí si es necesario
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: a ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(ic, color: a ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}

// --- CLASES AUXILIARES DEL HEADER DINÁMICO ---

class _DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;
  final double screenWidth;

  _DynamicHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.onVoiceTap,
    required this.screenWidth,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double percent = shrinkOffset / maxHeight;
    final double opacity = 1.0 - percent.clamp(0.0, 1.0);

    return _VoicePulseWrapper(
      maxHeight: maxHeight,
      opacity: opacity,
      isVoiceActive: isVoiceActive,
      onVoiceTap: onVoiceTap,
    );
  }

  @override
  double get maxExtent => maxHeight;
  @override
  double get minExtent => minHeight;
  @override
  bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}

class _VoicePulseWrapper extends StatefulWidget {
  final double maxHeight;
  final double opacity;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  const _VoicePulseWrapper({
    required this.maxHeight,
    required this.opacity,
    required this.isVoiceActive,
    required this.onVoiceTap,
  });

  @override
  State<_VoicePulseWrapper> createState() => _VoicePulseWrapperState();
}

class _VoicePulseWrapperState extends State<_VoicePulseWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isVoiceActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _VoicePulseWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVoiceActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: widget.maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFB3D4FF)),
          child: Opacity(
            opacity: widget.opacity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Agenda tu viaje',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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
          bottom: -25,
          child: GestureDetector(
            onTap: widget.onVoiceTap,
            child: ScaleTransition(
              scale: _animation,
              child: Image.asset(
                widget.isVoiceActive
                    ? 'assets/escuchando.png'
                    : 'assets/control_voz.png',
                height: 65,
                width: 65,
                errorBuilder: (c, e, s) => const CircleAvatar(
                  backgroundColor: Color(0xFF1559B2),
                  radius: 32,
                  child: Icon(Icons.mic, color: Colors.white, size: 30),
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
