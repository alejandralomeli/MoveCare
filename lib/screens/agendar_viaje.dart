import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../app_theme.dart';
import '../screens/widgets/modals/confirm_modal.dart';
import '../screens/widgets/route_map_widget.dart';
import '../services/acompanante/acompanante_service.dart';
import '../services/viaje/viaje_service.dart';
import '../services/pagos/pagos_service.dart';
import '../services/map/osm_service.dart';
import '../core/utils/auth_helper.dart';
import 'widgets/mic_button.dart';
import '../services/voz/voz_mixin.dart';

class AgendarViaje extends StatefulWidget {
  const AgendarViaje({super.key});

  @override
  State<AgendarViaje> createState() => _AgendarViajeState();
}

class _AgendarViajeState extends State<AgendarViaje> with VozMixin {
  // --- VARIABLES DE LÓGICA (HEAD) ---
  bool _isCreatingTrip = false;

  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();

  String origen = '';
  String destino = '';

  // Variables de Fecha y Hora
  DateTime _weekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );
  DateTime? _selectedDateTime;
  String? selectedHour;
  String? selectedMinute;

  // Variables de Selección
  String? selectedNeed;
  String? especificaciones;
  String? selectedPayment;

  // Variables Acompañante
  bool hasCompanion = false;
  String? selectedAcompananteId;
  List<Map<String, String>> acompanantes = [];
  bool cargandoAcompanantes = false;

  // Variables Tarjeta
  String? selectedTarjetaId;
  List<Map<String, String>> tarjetas = [];
  bool cargandoTarjetas = false;

  // 1. --- VARIABLES DE ESTADO DEL MAPA ---
  LatLng? startCoord;
  LatLng? endCoord;
  List<LatLng> routePoints = [];
  double? distanciaTotalKm;
  int? duracionMin;
  String? polylineRuta;
  bool calculandoRuta = false;

  // Listas Estáticas
  final List<String> hoursList = List.generate(
    24,
    (index) => index.toString().padLeft(2, '0'),
  );
  final List<String> minutesList = List.generate(
    12,
    (index) => (index * 5).toString().padLeft(2, '0'),
  );
  final List<String> zmgLocations = [
    'Guadalajara Centro',
    'Zapopan Centro',
    'Tlaquepaque Centro',
    'Andares',
    'Providencia',
    'Puerta de Hierro',
    'Colonia Americana',
    'Tonalá',
    'Tlajomulco',
  ];
  final List<String> needsList = [
    'Tercera Edad',
    'Movilidad reducida',
    'Discapacidad auditiva',
    'Obesidad',
    'Discapacidad visual',
  ];

  // --- VARIABLES DE UI ---

  // --- MÉTODOS DE FECHA ---
  String _dayLetter(DateTime d) {
    const days = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    return days[d.weekday - 1];
  }

  DateTime _inicioSemana(DateTime date) {
    final day = date.weekday;
    return date.subtract(Duration(days: day - 1));
  }

  List<DateTime> get _diasSemana =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  // --- INIT & DISPOSE ---
  @override
  void initState() {
    super.initState();
    inicializarVoz();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    origenController.dispose();
    destinoController.dispose();
    super.dispose();
  }

  // --- CARGA DE DATOS ---
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
      debugPrint("Error cargando tarjetas: $e");
    }
    if (mounted) setState(() => cargandoTarjetas = false);
  }

  // --- LÓGICA DE VOZ ---
  void _toggleVoice() => escucharComando({
    'establecer_destino': (e) {
      final d = e['destino'] as String?;
      if (d != null && d.isNotEmpty) setState(() => destinoController.text = d);
    },
    'establecer_origen': (e) {
      final o = e['origen'] as String?;
      if (o != null && o.isNotEmpty) setState(() => origenController.text = o);
    },
    'confirmar': (_) => _crearViaje(),
    'cancelar_accion': (_) => Navigator.pop(context),
    'ir_atras': (_) => Navigator.pop(context),
  });

  // 2. --- FUNCIÓN _calcularRutaYDistancia() ---
  Future<void> _calcularRutaYDistancia() async {
    if (origenController.text.isEmpty || destinoController.text.isEmpty) return;
    setState(() => calculandoRuta = true);

    try {
      startCoord = await OsmService.obtenerCoordenadas(origenController.text);
      endCoord = await OsmService.obtenerCoordenadas(destinoController.text);

      if (startCoord != null && endCoord != null) {
        final rutaData = await OsmService.obtenerRuta(startCoord!, endCoord!);
        if (rutaData != null) {
          setState(() {
            distanciaTotalKm = rutaData['distancia'];
            routePoints = rutaData['puntos'];
            duracionMin = rutaData['duracion']?.toInt();
            polylineRuta = rutaData['polyline'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error calculando ruta: $e");
    } finally {
      setState(() => calculandoRuta = false);
    }
  }

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

  TextStyle mExtrabold(
    double sw, {
    Color color = Colors.black,
    double size = 22,
  }) {
    double finalSize = sw < 350 ? size - 2 : size;
    return GoogleFonts.montserrat(
      color: color,
      fontSize: finalSize,
      fontWeight: FontWeight.w800,
    );
  }

  // --- BUILD PRINCIPAL ---
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
              isVoiceActive: vozEscuchando || vozProcesando,
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildInstructionBadge(sw),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Seleccionar fecha', style: mSemibold(sw, size: 18)),
                      _buildCalendarControls(sw),
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
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(
                            () => _weekStart = picked.subtract(
                              Duration(days: picked.weekday - 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined, size: 16),
                      label: const Text('Ver más'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contenedor Formulario
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
                                sw,
                                'Hora',
                                hoursList,
                                selectedHour,
                                (v) => setState(() => selectedHour = v),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTimeDropdown(
                                sw,
                                'Minutos',
                                minutesList,
                                selectedMinute,
                                (v) => setState(() => selectedMinute = v),
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
                        const SizedBox(height: 8),
                        _buildZMGAutocomplete(
                          'Lugar de destino',
                          destinoController,
                          sw,
                        ),

                        // 3. --- EL WIDGET DEL MAPA RouteMapWidget ---
                        const SizedBox(height: 15),
                        RouteMapWidget(
                          startCoord: startCoord,
                          endCoord: endCoord,
                          routePoints: routePoints,
                          distanciaTotalKm: distanciaTotalKm,
                          isLoading: calculandoRuta,
                        ),

                        // 4. --- BOTÓN AGREGAR MÁS DESTINOS ---
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/agendar_varios_destinos',
                            ),
                            icon: const Icon(
                              Icons.add_location_alt_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            label: Text(
                              'Agregar más destinos',
                              style: mSemibold(sw, color: AppColors.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),
                        Text('Necesidad especial', style: mSemibold(sw)),
                        const SizedBox(height: 8),
                        _buildSimpleDropdown(
                          sw,
                          'Selecciona una necesidad',
                          Icons.accessibility_new,
                          needsList,
                          selectedNeed,
                          (v) => setState(() => selectedNeed = v),
                        ),
                        if (selectedNeed != null) ...[
                          const SizedBox(height: 10),
                          _buildTextField(
                            sw,
                            'Especificaciones (Opcional)',
                            (v) => especificaciones = v,
                          ),
                        ],
                        const SizedBox(height: 15),

                        _buildCompanionSection(sw),
                        if (hasCompanion) ...[
                          const SizedBox(height: 8),
                          _buildAcompananteDropdown(sw),
                        ],
                        const SizedBox(height: 15),

                        Text('Método de pago', style: mSemibold(sw)),
                        const SizedBox(height: 8),
                        _buildSimpleDropdown(
                          sw,
                          'Selecciona método de pago',
                          Icons.payments_outlined,
                          [
                            'Efectivo',
                            'Tarjeta de crédito',
                            'Tarjeta de débito',
                          ],
                          selectedPayment,
                          (v) => setState(() => selectedPayment = v),
                        ),
                        if (isCardPayment) ...[
                          const SizedBox(height: 10),
                          _buildTarjetaDropdown(sw),
                        ],
                        const SizedBox(height: 25),

                        // Modificado para incluir el botón de Mostrar Estimación
                        _buildActionButtons(sw),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildInstructionBadge(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: AppColors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'Ingresa los datos para agendar',
            style: mSemibold(sw, color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarControls(double sw) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primary),
          onPressed: () {
            final prev = _weekStart.subtract(const Duration(days: 7));
            if (!prev.isBefore(_inicioSemana(DateTime.now())))
              setState(() => _weekStart = prev);
          },
        ),
        const SizedBox(width: 15),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.primary),
          onPressed: () => setState(
            () => _weekStart = _weekStart.add(const Duration(days: 7)),
          ),
        ),
      ],
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
              opacity: isPast ? 0.4 : 1.0,
              child: Container(
                height: 65,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayLetter(date),
                      style: mSemibold(
                        sw,
                        color: isSelected ? AppColors.white : AppColors.primary,
                        size: 12,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: mExtrabold(
                        sw,
                        color: isSelected ? AppColors.white : AppColors.primary,
                        size: 16,
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

  // 6. --- LA LUPA Y EL ONSUBMITTED EN _buildZMGAutocomplete (Con corrección de prefixIcon) ---
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
      onSelected: (v) {
        controller.text = v;
        _calcularRutaYDistancia(); // Ya calcula al seleccionar de la lista
      },
      fieldViewBuilder: (c, ct, f, o) {
        if (ct.text.isEmpty && controller.text.isNotEmpty) {
          ct.text = controller.text;
        }
        return TextField(
          controller: ct,
          focusNode: f,
          onChanged: (text) => controller.text = text,
          textInputAction:
              TextInputAction.search, // Botón de buscar en el teclado
          onSubmitted: (_) {
            controller.text = ct.text;
            _calcularRutaYDistancia();
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: mSemibold(sw, color: AppColors.textSecondary, size: 13),
            prefixIcon: const Icon(
              Icons.location_on_outlined, // Mismo ícono
              color: AppColors.primary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: () {
                controller.text = ct.text;
                _calcularRutaYDistancia();
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
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
    double sw,
    String hint,
    List<String> items,
    String? val,
    Function(String?) onChange,
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
          value: val,
          style: mSemibold(sw, color: AppColors.primary),
          hint: Text(
            hint,
            style: mSemibold(sw, color: AppColors.textSecondary, size: 12),
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: mSemibold(sw, color: AppColors.primary),
                  ),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(
    double sw,
    String hint,
    IconData icon,
    List<String> items,
    String? val,
    Function(String?) onChange,
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
          value: val,
          style: mSemibold(sw, color: AppColors.primary),
          hint: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                hint,
                style: mSemibold(sw, color: AppColors.textSecondary, size: 13),
              ),
            ],
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: mSemibold(sw, color: AppColors.primary),
                  ),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildTextField(double sw, String hint, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: mSemibold(sw, color: AppColors.textSecondary, size: 13),
          border: InputBorder.none,
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
        const Spacer(),
        if (hasCompanion)
          Text(
            '* Requerido',
            style: mSemibold(sw, color: AppColors.error, size: 9),
          ),
      ],
    );
  }

  Widget _buildAcompananteDropdown(double sw) {
    if (cargandoAcompanantes)
      return const Center(child: LinearProgressIndicator());
    return _buildSimpleDropdown(
      sw,
      'Selecciona acompañante',
      Icons.person_outline,
      acompanantes.map((a) => a["nombre"]!).toList(),
      acompanantes.firstWhere(
        (a) => a["id"] == selectedAcompananteId,
        orElse: () => {"nombre": ""},
      )["nombre"],
      (v) {
        final selected = acompanantes.firstWhere((a) => a["nombre"] == v);
        setState(() => selectedAcompananteId = selected["id"]);
      },
    );
  }

  Widget _buildTarjetaDropdown(double sw) {
    if (cargandoTarjetas) return const Center(child: LinearProgressIndicator());
    String hintText = tarjetas.isEmpty
        ? 'Registrar Tarjeta'
        : 'Selecciona tu tarjeta';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTarjetaId,
          hint: Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                hintText,
                style: mSemibold(sw, color: AppColors.textSecondary, size: 13),
              ),
            ],
          ),
          isExpanded: true,
          items: tarjetas
              .map(
                (t) => DropdownMenuItem(
                  value: t["id"],
                  child: Text(
                    t["texto"]!,
                    style: mSemibold(sw, color: AppColors.primary),
                  ),
                ),
              )
              .toList(),
          onChanged: tarjetas.isEmpty
              ? null
              : (v) => setState(() => selectedTarjetaId = v),
        ),
      ),
    );
  }

  // BOTÓN RECUPERADO DE "MOSTRAR ESTIMACIÓN" Y ACCIONES
  Widget _buildActionButtons(double sw) {
    return Column(
      children: [
        // BOTÓN MOSTRAR ESTIMACIÓN (Recuperado del viejo, con diseño del nuevo)
        ElevatedButton(
          onPressed: _calcularRutaYDistancia,
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
            style: mSemibold(sw, color: Colors.white, size: 13),
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
                  'Agendar',
                  const Color.fromARGB(255, 46, 195, 38),
                  sw,
                  () => showConfirmModal(
                    context: context,
                    title: '¿Confirmar agendado?',
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
                  () => showConfirmModal(
                    context: context,
                    title: '¿Desea cancelar y volver al inicio?',
                    onConfirm: () => Navigator.pushReplacementNamed(
                      context,
                      '/principal_pasajero',
                    ),
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

  // 5. --- EL PAYLOAD COMPLETO EN _crearViaje() ---
  Future<void> _crearViaje() async {
    if (_isCreatingTrip) return;

    bool esPagoConTarjeta =
        (selectedPayment == 'Tarjeta de crédito' ||
        selectedPayment == 'Tarjeta de débito');

    // Validaciones
    if (esPagoConTarjeta && selectedTarjetaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tarjeta'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedDateTime == null ||
        selectedHour == null ||
        selectedMinute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona fecha y hora'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (hasCompanion && selectedAcompananteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un acompañante o desmarque la casilla'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validación para asegurar que se buscaron las rutas
    if (startCoord == null || endCoord == null || distanciaTotalKm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor busca las direcciones presionando la lupa para calcular la ruta.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreatingTrip = true);
    try {
      final fechaBase = _selectedDateTime!;
      final fechaHoraInicio = DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        int.parse(selectedHour!),
        int.parse(selectedMinute!),
      );

      // Creación del diccionario rutaJson
      Map<String, dynamic> rutaJson = {
        "origen": {
          "lat": startCoord!.latitude,
          "lng": startCoord!.longitude,
          "direccion": origenController.text,
        },
        "destino": {
          "lat": endCoord!.latitude,
          "lng": endCoord!.longitude,
          "direccion": destinoController.text,
        },
        "polyline": polylineRuta,
        "distancia_km": double.parse(distanciaTotalKm!.toStringAsFixed(2)),
        "duracion_aprox_min": duracionMin ?? 0,
      };

      // Inyectado rutaJson a la llamada del backend
      final viajeId = await ViajeService.crearViaje(
        ruta: rutaJson,
        puntoInicio: origenController.text.trim(),
        destino: destinoController.text.trim(),
        checkVariosDestinos: false,
        fechaHoraInicio: fechaHoraInicio.toIso8601String(),
        metodoPago: selectedPayment ?? 'Efectivo',
        idMetodo: esPagoConTarjeta ? selectedTarjetaId : null,
        especificaciones: especificaciones,
        checkAcompanante: hasCompanion,
        idAcompanante: hasCompanion ? selectedAcompananteId : null,
        costo: null,
        duracionEstimada: duracionMin,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/principal_pasajero',
          arguments: viajeId,
        );
      }
    } catch (e) {
      if (mounted) AuthHelper.manejarError(context, e);
    } finally {
      if (mounted) setState(() => _isCreatingTrip = false);
    }
  }
}

// --- HEADER DINÁMICO ---
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
          right: 20,
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
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}
