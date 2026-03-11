import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../screens/widgets/modals/confirm_modal.dart';
import 'widgets/mic_button.dart';
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
  // --- VARIABLES DE ESTADO (LÓGICA) ---
  bool _isCreatingTrip = false;
  bool _isVoiceActive = false; // Estado para el header dinámico

  // Controladores de Texto
  final List<TextEditingController> _destinoControllers = [];
  final TextEditingController origenController = TextEditingController();

  // Fechas y Horas
  DateTime _weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
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

  // ACOMPAÑANTES
  String? selectedAcompananteId;
  List<Map<String, String>> acompanantes = [];
  bool cargandoAcompanantes = false;
  bool hasCompanion = false;

  // TARJETAS
  String? selectedTarjetaId;
  List<Map<String, String>> tarjetas = [];
  bool cargandoTarjetas = false;

  // --- ESTILOS DE TEXTO ---
  TextStyle mSemibold(
    double sw, {
    Color color = Colors.black,
    double size = 14,
  }) {
    double finalSize = sw < 350 ? size - 2 : size;
    return GoogleFonts.montserrat(
      color: color,
      fontSize: finalSize,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle oldMSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mExtrabold(
    double sw, {
    Color color = Colors.black,
    double size = 18,
  }) {
    double finalSize = sw < 350 ? size - 2 : size;
    return GoogleFonts.montserrat(
      color: color,
      fontSize: finalSize,
      fontWeight: FontWeight.w800,
    );
  }

  TextStyle labelStyle(double sw, {double size = 14}) => GoogleFonts.montserrat(
    color: AppColors.primary,
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
    const days = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
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
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _DynamicHeaderDelegate(
              maxHeight: 80,
              minHeight: 80,
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
                        style: mSemibold(sw, color: AppColors.textPrimary, size: 18),
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
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _weekStart = picked.subtract(Duration(days: picked.weekday - 1)));
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined, size: 16),
                      label: const Text('Ver más'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Formulario Principal
                  Container(
                    padding: EdgeInsets.all(sw * 0.05),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
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
                                  color: AppColors.primary,
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

                        const SizedBox(height: 10),
                        _buildOneDestinationButton(),
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
                            style: mSemibold(sw, color: AppColors.primary, size: 13),
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
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 1),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildOneDestinationButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/agendar_viaje');
        },
        icon: const Icon(Icons.alt_route, color: AppColors.white),
        label: Text(
          'Agendar un solo destino',
          style: oldMSemibold(color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(260, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildDateRow(double sw) {
    return Row(
      children: _diasSemana.map((date) {
        final isPast = date.isBefore(
          DateTime.now().subtract(const Duration(days: 1)),
        );
        final isSelected =
            _selectedDateTime != null &&
            date.day == _selectedDateTime!.day &&
            date.month == _selectedDateTime!.month;

        return Expanded(
          child: GestureDetector(
            onTap: isPast
                ? null
                : () => setState(() => _selectedDateTime = date),
            child: Opacity(
              opacity: isPast ? 0.4 : 1,
              child: Container(
                height: 65,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Text(
                        _dayLetter(date),
                        textAlign: TextAlign.center,
                        style: mSemibold(sw, color: AppColors.white, size: 11),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: mExtrabold(sw, color: AppColors.primary, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
          icon: const Icon(Icons.remove_circle, color: AppColors.primary, size: 28),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$_cantidadDestinos',
            style: mSemibold(sw, color: AppColors.white, size: 16),
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
          icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
        ),
      ],
    );
  }

  Widget _buildZMGAutocomplete(
    String hint,
    TextEditingController controller,
    double sw,
  ) {
    return Autocomplete<String>(
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
            hintStyle: mSemibold(sw, color: AppColors.textSecondary, size: 13),
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        );
      },
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: v,
          hint: Row(
            children: [
              Icon(i, color: AppColors.primary, size: 20),
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
        icon: const Icon(Icons.person_add, size: 18, color: AppColors.primary),
        label: Text(
          "Registrar nuevo acompañante",
          style: mSemibold(sw, color: AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
        icon: const Icon(Icons.add_card, color: AppColors.white, size: 18),
        label: Text(
          "Registrar Tarjeta",
          style: mSemibold(sw, color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => hasCompanion = v!),
        ),
        Text(
          'Registrar acompañante',
          style: mSemibold(sw, color: AppColors.primary, size: 13),
        ),
      ],
    );
  }

  Widget _buildInstructionBadge(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: AppColors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Ingresa los datos para agendar',
            style: mSemibold(sw, color: AppColors.white, size: 12),
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
            backgroundColor: AppColors.primary,
            elevation: 0,
            minimumSize: Size(sw * 0.55, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Mostrar estimación',
            style: mSemibold(sw, color: AppColors.white, size: 13),
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
                  const Color.fromARGB(255, 46, 195, 38),
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
                  const Color.fromARGB(255, 219, 26, 26),
                  sw,
                  () => Navigator.pushReplacementNamed(
                    context,
                    '/principal_pasajero',
                  ),
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
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        l,
        textAlign: TextAlign.center,
        style: mSemibold(sw, color: AppColors.white, size: 12),
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxHeight,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              'Agenda tu viaje',
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
          bottom:20,
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
          right: 20,
          bottom: -20,
          child: MicButton(isActive: isVoiceActive, onTap: onVoiceTap, size: 42),
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
