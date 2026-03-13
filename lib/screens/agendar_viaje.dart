import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../screens/widgets/modals/confirm_modal.dart';
import '../services/acompanante/acompanante_service.dart';
import '../services/viaje/viaje_service.dart';
import '../services/pagos/pagos_service.dart';
import '../core/utils/auth_helper.dart';
import 'widgets/mic_button.dart';

class AgendarViaje extends StatefulWidget {
  const AgendarViaje({super.key});

  @override
  State<AgendarViaje> createState() => _AgendarViajeState();
}

class _AgendarViajeState extends State<AgendarViaje> {
  // --- VARIABLES DE LÓGICA (HEAD) ---
  bool _isCreatingTrip = false;

  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();

  String origen = '';
  String destino = '';

  // Variables de Fecha y Hora
  DateTime _weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
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

  // Listas Estáticas
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
  bool _isVoiceActive = false;

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
    // Carga de datos
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
      print("Error cargando tarjetas: $e");
    }
    if (mounted) setState(() => cargandoTarjetas = false);
  }

  // --- LÓGICA DE VOZ ---
  void _toggleVoice() {
    setState(() => _isVoiceActive = !_isVoiceActive);
  }

  // --- ESTILOS DE TEXTO ---
  TextStyle mSemibold(
    double sw, {
    Color color = Colors.black,
    double size = 14,
  }) {
    // Ajuste responsivo básico
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
          // Header Dinámico con Animación
          SliverPersistentHeader(
            pinned: true,
            delegate: _DynamicHeaderDelegate(
              maxHeight: 80,
              minHeight: 80,
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
            ),
          ),

          // Contenido del Formulario
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildInstructionBadge(sw),
                  const SizedBox(height: 15),

                  // Sección Fecha (Calendario)
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
                  const SizedBox(height: 12),

                  // Contenedor Azul Claro
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
                          sw: sw,
                          hint: 'Ubicación actual',
                          controller: origenController,
                          onSelected: (val) => origen = val,
                        ),
                        const SizedBox(height: 8),
                        _buildZMGAutocomplete(
                          sw: sw,
                          hint: 'Lugar de destino',
                          controller: destinoController,
                          onSelected: (val) => destino = val,
                        ),
                        const SizedBox(height: 10),
                        _buildMultipleDestinationsButton(sw),
                        const SizedBox(height: 15),

                        // Sección Acompañante
                        _buildCompanionSection(sw),
                        if (hasCompanion) ...[
                          const SizedBox(height: 10),
                          _buildAcompananteDropdown(sw),
                          const SizedBox(height: 10),
                          _buildRegistrarAcompananteButton(sw),
                        ],
                        const SizedBox(height: 15),

                        // Necesidad Especial
                        _buildSpecialNeedDropdown(sw),
                        const SizedBox(height: 15),

                        // Forma de Pago
                        Center(
                          child: Text(
                            'Seleccionar forma de pago',
                            style: mSemibold(sw, color: AppColors.primary, size: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSimpleDropdown(
                          sw,
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
                        ),

                        // Tarjetas (si aplica)
                        if (isCardPayment) ...[
                          const SizedBox(height: 15),
                          _buildTarjetaDropdown(sw),
                          const SizedBox(height: 10),
                          _buildRegistrarTarjetaButton(sw),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildActionButtons(sw),
                  const SizedBox(height: 40),
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
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            final prev = _weekStart.subtract(const Duration(days: 7));
            if (!prev.isBefore(_inicioSemana(DateTime.now()))) {
              setState(() => _weekStart = prev);
            }
          },
        ),
        const SizedBox(width: 15),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.primary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(
              () => _weekStart = _weekStart.add(const Duration(days: 7)),
            );
          },
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
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
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

  Widget _buildZMGAutocomplete({
    required double sw,
    required String hint,
    required TextEditingController controller,
    required Function(String) onSelected,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable<String>.empty();
        return zmgLocations.where(
          (loc) => loc.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
      onSelected: (selection) {
        controller.text = selection;
        onSelected(selection);
      },
      fieldViewBuilder: (context, textController, focusNode, _) {
        if (controller.text.isNotEmpty && textController.text.isEmpty) {
          textController.text = controller.text;
        }
        return TextField(
          controller: textController,
          focusNode: focusNode,
          style: mSemibold(sw, color: AppColors.primary),
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
          onChanged: (value) => onSelected(value),
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
          hint: Text(hint, style: mSemibold(sw, color: AppColors.textSecondary, size: 12)),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(sw, color: AppColors.primary)),
                ),
              )
              .toList(),
          onChanged: onChange,
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
          Text('* Requerido', style: mSemibold(sw, color: AppColors.error, size: 9)),
      ],
    );
  }

  Widget _buildAcompananteDropdown(double sw) {
    if (cargandoAcompanantes)
      return const Center(child: LinearProgressIndicator());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedAcompananteId,
          hint: Text(
            acompanantes.isEmpty
                ? 'Sin acompañantes'
                : 'Selecciona acompañante',
            style: mSemibold(sw, color: AppColors.textSecondary, size: 13),
          ),
          isExpanded: true,
          items: acompanantes.map((a) {
            return DropdownMenuItem(
              value: a["id"],
              child: Text(
                a["nombre"]!,
                style: mSemibold(sw, color: AppColors.primary),
              ),
            );
          }).toList(),
          onChanged: acompanantes.isEmpty
              ? null
              : (v) => setState(() => selectedAcompananteId = v),
        ),
      ),
    );
  }

  Widget _buildRegistrarAcompananteButton(double sw) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/registro_acompanante',
          ).then((_) => _cargarAcompanantes());
        },
        icon: const Icon(Icons.person_add, size: 18, color: AppColors.primary),
        label: Text(
          "Nuevo acompañante",
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
          hint: Text(
            'Necesidad especial',
            style: mSemibold(sw, color: AppColors.textSecondary, size: 13),
          ),
          isExpanded: true,
          items: needsList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(sw, color: AppColors.primary)),
                ),
              )
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
          hint: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(hint, style: mSemibold(sw, color: AppColors.textSecondary, size: 13)),
            ],
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(sw, color: AppColors.primary)),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
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
              Text(hintText, style: mSemibold(sw, color: AppColors.textSecondary, size: 13)),
            ],
          ),
          isExpanded: true,
          items: tarjetas.map((t) {
            return DropdownMenuItem(
              value: t["id"],
              child: Text(
                t["texto"]!,
                style: mSemibold(sw, color: AppColors.primary),
              ),
            );
          }).toList(),
          onChanged: tarjetas.isEmpty
              ? null
              : (v) => setState(() => selectedTarjetaId = v),
        ),
      ),
    );
  }

  Widget _buildRegistrarTarjetaButton(double sw) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/registro_tarjeta',
          ).then((_) => _cargarTarjetas());
        },
        icon: const Icon(Icons.add_card, color: Colors.white, size: 18),
        label: Text(
          "Registrar Tarjeta",
          style: mSemibold(sw, color: Colors.white),
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

  Widget _buildMultipleDestinationsButton(double sw) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () =>
            Navigator.pushNamed(context, '/agendar_varios_destinos'),
        icon: const Icon(Icons.alt_route, color: Colors.white, size: 18),
        label: Text(
          'Agendar varios destinos',
          style: mSemibold(sw, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: Size(sw * 0.7, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildActionButtons(double sw) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Estimación calculada: \$150.00")),
            );
          },
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
                    title: '¿Está seguro de que desea agendar el viaje?',
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
                    onConfirm: () =>
                        Navigator.pushReplacementNamed(context, '/principal_pasajero'),
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


  // --- LÓGICA DE ENVÍO AL BACKEND ---
  Future<void> _crearViaje() async {
    if (_isCreatingTrip) return;

    // 1. VALIDACIÓN
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
    if (_selectedDateTime == null ||
        selectedHour == null ||
        selectedMinute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora')),
      );
      return;
    }

    setState(() => _isCreatingTrip = true);

    try {
      DateTime fechaBase = _selectedDateTime!;
      DateTime fechaHoraInicio = DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        int.parse(selectedHour!),
        int.parse(selectedMinute!),
      );

      await ViajeService.crearViaje(
        puntoInicio: origenController.text.isNotEmpty
            ? origenController.text
            : origen,
        destino: destinoController.text.isNotEmpty
            ? destinoController.text
            : destino,
        fechaHoraInicio: fechaHoraInicio.toIso8601String(),
        metodoPago: selectedPayment,
        idMetodo: esPagoConTarjeta ? selectedTarjetaId : null,
        especificaciones: especificaciones,
        checkAcompanante: hasCompanion,
        idAcompanante: hasCompanion ? selectedAcompananteId : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Viaje agendado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/principal_pasajero');
    } catch (e) {
      if (mounted) AuthHelper.manejarError(context, e);
    } finally {
      if (mounted) setState(() => _isCreatingTrip = false);
    }
  }
}

// --- CLASE HEADER DINÁMICO (Sin cambios, solo añadida) ---
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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
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
  double get maxExtent => maxHeight;
  @override
  double get minExtent => minHeight;
  @override
  bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}
