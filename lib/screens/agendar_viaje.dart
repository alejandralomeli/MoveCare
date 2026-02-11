import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/widgets/modals/confirm_modal.dart';
import '../services/acompanante/acompanante_service.dart';
import '../services/viaje/viaje_service.dart';
import '../services/pagos/pagos_service.dart';
import '../core/utils/auth_helper.dart';

class AgendarViaje extends StatefulWidget {
  const AgendarViaje({super.key});

  @override
  State<AgendarViaje> createState() => _AgendarViajeState();
}

class _AgendarViajeState extends State<AgendarViaje> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  bool _isCreatingTrip = false;

  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();

  String origen = '';
  String destino = '';

  DateTime? fechaSeleccionada;

  String? metodoPago;
  String? especificaciones;
  String? idAcompananteSeleccionado;

  String? selectedAcompananteId;
  List<Map<String, String>> acompanantes = [];
  bool cargandoAcompanantes = false;

  String? selectedTarjetaId;
  List<Map<String, String>> tarjetas = [];
  bool cargandoTarjetas = false;

  int _selectedIndex = 1;
  DateTime _weekStart = DateTime.now();
  DateTime? _selectedDateTime;

  String _dayLetter(DateTime d) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[d.weekday - 1];
  }

  DateTime _inicioSemana(DateTime date) {
    final day = date.weekday;
    return date.subtract(Duration(days: day - 1));
  }

  List<DateTime> get _diasSemana =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  String? selectedHour;
  String? selectedMinute;
  String? selectedNeed;
  String? selectedPayment;
  bool hasCompanion = false;

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
  ];

  final List<String> needsList = [
    'Tercera Edad',
    'Movilidad reducida',
    'Discapacidad auditiva',
    'Obesidad',
    'Discapacidad visual',
  ];

  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

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

  @override
  Widget build(BuildContext context) {
    bool isCardPayment =
        selectedPayment == 'Tarjeta de crédito' ||
        selectedPayment == 'Tarjeta de débito';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    _buildInstructionBadge(),
                    const SizedBox(height: 10),
                    Text('Seleccionar fecha', style: mSemibold(size: 18)),
                    const SizedBox(height: 10),
                    // Calendario (resumido)
                    _buildCalendarControls(),
                    Center(child: _buildDateRow()),
                    const SizedBox(height: 20),

                    // Contenedor del Formulario
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: containerBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seleccionar hora', style: mSemibold()),
                          const SizedBox(height: 8),
                          _buildTimeSelectors(),
                          const SizedBox(height: 15),

                          Text('Lugar', style: mSemibold()),
                          const SizedBox(height: 8),
                          _buildZMGAutocomplete(
                            hint: 'Ubicación actual',
                            controller: origenController,
                            onSelected: (value) => origen = value,
                          ),
                          const SizedBox(height: 8),
                          _buildZMGAutocomplete(
                            hint: 'Lugar de destino',
                            controller: destinoController,
                            onSelected: (value) => destino = value,
                          ),
                          const SizedBox(height: 10),
                          _buildMultipleDestinationsButton(),
                          const SizedBox(height: 15),

                          // SECCIÓN ACOMPAÑANTE
                          _buildCompanionSection(), // Checkbox
                          const SizedBox(height: 10),
                          if (hasCompanion) ...[
                            _buildAcompananteDropdown(),
                            const SizedBox(height: 10),
                            // 🔥 BOTÓN NUEVO: Registrar Acompañante
                            _buildRegistrarAcompananteButton(),
                            const SizedBox(height: 15),
                          ],

                          _buildSpecialNeedDropdown(),
                          const SizedBox(height: 15),

                          Center(
                            child: Text(
                              'Seleccionar forma de pago',
                              style: mSemibold(color: primaryBlue, size: 13),
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
                              // Resetear tarjeta seleccionada al cambiar metodo
                              if (!isCardPayment) selectedTarjetaId = null;
                            }),
                          ),

                          // 🔥 LOGICA DE TARJETAS (Select + Botón)
                          if (isCardPayment) ...[
                            const SizedBox(height: 15),
                            _buildTarjetaDropdown(),
                            const SizedBox(height: 10),
                            _buildRegistrarTarjetaButton(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGETS AUXILIARES NUEVOS Y MODIFICADOS ---

  Widget _buildRegistrarAcompananteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Navegar y recargar al volver
          Navigator.pushNamed(
            context,
            '/registro_acompanante',
          ).then((_) => _cargarAcompanantes());
        },
        icon: const Icon(Icons.person_add, size: 18, color: primaryBlue),
        label: Text(
          "Registrar nuevo acompañante",
          style: mSemibold(color: primaryBlue),
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

  Widget _buildTarjetaDropdown() {
    if (cargandoTarjetas) {
      return const Center(child: CircularProgressIndicator());
    }

    // Texto dinámico si no hay tarjetas
    String hintText = tarjetas.isEmpty
        ? 'Registrar Tarjeta'
        : 'Selecciona tu tarjeta';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentBlue.withOpacity(0.5),
        ), // Borde sutil para resaltar
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTarjetaId,
          dropdownColor: Colors.white,
          hint: Row(
            children: [
              const Icon(Icons.credit_card, color: primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(hintText, style: mSemibold(color: accentBlue)),
            ],
          ),
          isExpanded: true,
          // Si está vacío, deshabilitamos el select (items null) o mostramos lista vacia
          items: tarjetas.isEmpty
              ? []
              : tarjetas.map((t) {
                  return DropdownMenuItem(
                    value: t["id"],
                    child: Text(
                      t["texto"]!,
                      style: mSemibold(color: primaryBlue),
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

  Widget _buildRegistrarTarjetaButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navegar y recargar al volver
          Navigator.pushNamed(
            context,
            '/registro_tarjeta',
          ).then((_) => _cargarTarjetas());
        },
        icon: const Icon(Icons.add_card, color: Colors.white, size: 18),
        label: Text("Registrar Tarjeta", style: mSemibold(color: Colors.white)),
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

  // --- RESTO DE WIDGETS (Casi iguales, solo organizados) ---

  Widget _buildCalendarControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = _weekStart.subtract(const Duration(days: 7));
            if (!prev.isBefore(_inicioSemana(DateTime.now()))) {
              setState(() => _weekStart = prev);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(
              () => _weekStart = _weekStart.add(const Duration(days: 7)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeDropdown(
            'Hora',
            hoursList,
            selectedHour,
            (v) => setState(() => selectedHour = v),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTimeDropdown(
            'Minutos',
            minutesList,
            selectedMinute,
            (v) => setState(() => selectedMinute = v),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 45),
          Text(
            'Agenda tu viaje',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 45),
            child: Image.asset(
              'assets/control_voz.png',
              height: 65,
              width: 65,
              errorBuilder: (c, e, s) => const Icon(Icons.mic, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _diasSemana.map((date) {
        final isPast = date.isBefore(
          DateTime.now().subtract(const Duration(days: 1)),
        );
        final isSelected =
            _selectedDateTime != null &&
            date.day == _selectedDateTime!.day &&
            date.month == _selectedDateTime!.month;

        return GestureDetector(
          onTap: isPast ? null : () => setState(() => _selectedDateTime = date),
          child: Opacity(
            opacity: isPast ? 0.4 : 1,
            child: _dateItem(_dayLetter(date), date.day.toString(), isSelected),
          ),
        );
      }).toList(),
    );
  }

  Widget _dateItem(String day, String num, bool isSelected) {
    return Container(
      width: 58,
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 3),
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
              style: mSemibold(color: Colors.white, size: 11),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                num,
                style: GoogleFonts.montserrat(
                  color: primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZMGAutocomplete({
    required String hint,
    required TextEditingController controller,
    required Function(String) onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Autocomplete<String>(
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
          textController.text = controller.text;
          return TextField(
            controller: textController,
            focusNode: focusNode,
            style: mSemibold(color: primaryBlue),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: mSemibold(color: accentBlue),
              icon: const Icon(Icons.location_on, color: primaryBlue),
              border: InputBorder.none,
            ),
            onChanged: (value) => onSelected(value),
          );
        },
      ),
    );
  }

  Widget _buildTimeDropdown(
    String hint,
    List<String> items,
    String? val,
    Function(String?) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          dropdownColor: Colors.white,
          hint: Text(hint, style: mSemibold(color: accentBlue)),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(color: primaryBlue)),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildCompanionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: hasCompanion,
              activeColor: primaryBlue,
              onChanged: (v) => setState(() => hasCompanion = v!),
            ),
            Text('Registrar acompañante', style: mSemibold(color: accentBlue)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 45),
          child: Text(
            '*Marcar solo en caso de llevar acompañante',
            style: mSemibold(color: Colors.red, size: 9),
          ),
        ),
      ],
    );
  }

  Widget _buildAcompananteDropdown() {
    // Nota: La lógica de visibilidad se movió al build principal
    if (cargandoAcompanantes)
      return const Center(child: CircularProgressIndicator());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedAcompananteId,
          dropdownColor: Colors.white,
          hint: Text(
            acompanantes.isEmpty
                ? 'Sin acompañantes'
                : 'Selecciona acompañante',
            style: mSemibold(color: accentBlue),
          ),
          isExpanded: true,
          items: acompanantes.map((a) {
            return DropdownMenuItem(
              value: a["id"],
              child: Text(a["nombre"]!, style: mSemibold(color: primaryBlue)),
            );
          }).toList(),
          onChanged: acompanantes.isEmpty
              ? null
              : (v) => setState(() => selectedAcompananteId = v),
        ),
      ),
    );
  }

  Widget _buildSpecialNeedDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedNeed,
          dropdownColor: Colors.white,
          hint: Row(
            children: [
              Image.asset(
                'assets/movecare.png',
                height: 24,
                width: 24,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.wb_sunny_outlined, color: primaryBlue),
              ),
              const SizedBox(width: 10),
              Text('Necesidad especial', style: mSemibold(color: accentBlue)),
            ],
          ),
          isExpanded: true,
          items: needsList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(color: primaryBlue)),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              selectedNeed = v;
              especificaciones = v;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(
    String hint,
    IconData icon,
    List<String> items,
    String? val,
    Function(String?) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          dropdownColor: Colors.white,
          hint: Row(
            children: [
              Icon(icon, color: primaryBlue),
              const SizedBox(width: 10),
              Text(hint, style: mSemibold(color: accentBlue)),
            ],
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(color: primaryBlue)),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildInstructionBadge() {
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
            style: mSemibold(color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            minimumSize: const Size(220, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            'Mostrar estimación',
            style: mSemibold(color: Colors.white),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionBtn(
              'Agendar viaje',
              accentBlue,
              onPressed: () {
                showConfirmModal(
                  context: context,
                  title: '¿Está seguro de que desea agendar el viaje?',
                  onConfirm: _crearViaje,
                );
              },
            ),
            _actionBtn(
              'Cancelar',
              accentBlue,
              onPressed: () {
                showConfirmModal(
                  context: context,
                  title: '¿Desea cancelar y volver al inicio?',
                  onConfirm: () =>
                      Navigator.pushReplacementNamed(context, '/home_pasajero'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultipleDestinationsButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () =>
            Navigator.pushNamed(context, '/agendar_varios_destinos'),
        icon: const Icon(Icons.alt_route, color: Colors.white),
        label: Text(
          'Agendar con varios destinos',
          style: mSemibold(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          minimumSize: const Size(260, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(140, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: mSemibold()),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, '/agendar_viaje'),
          _navIcon(2, Icons.history, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, '/mi_perfil_pasajero'),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, String routeName) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
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

  Future<void> _crearViaje() async {
    if (_isCreatingTrip) return;

    // 1. VALIDACIÓN DE TARJETA
    // Si eligió tarjeta pero no seleccionó cuál, mostramos error.
    bool esPagoConTarjeta =
        (selectedPayment == 'Tarjeta de crédito' ||
        selectedPayment == 'Tarjeta de débito');

    if (esPagoConTarjeta && selectedTarjetaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una tarjeta para continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. VALIDACIÓN DE FECHA Y HORA (Protección extra)
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
      // Construir fecha completa
      DateTime fechaBase = _selectedDateTime!;
      DateTime fechaHoraInicio = DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        int.parse(selectedHour!),
        int.parse(selectedMinute!),
      );

      // 3. LLAMADA AL SERVICIO
      await ViajeService.crearViaje(
        puntoInicio: origenController.text.isNotEmpty
            ? origenController.text
            : origen, // Usar controller si origen está vacío
        destino: destinoController.text.isNotEmpty
            ? destinoController.text
            : destino,
        fechaHoraInicio: fechaHoraInicio.toIso8601String(),
        metodoPago: selectedPayment,
        idMetodo: esPagoConTarjeta ? selectedTarjetaId : null,
        // -----------------------------------------
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

      Navigator.pushReplacementNamed(context, '/home_pasajero');
    } catch (e) {
      if (mounted) {
        AuthHelper.manejarError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isCreatingTrip = false);
    }
  }
}
