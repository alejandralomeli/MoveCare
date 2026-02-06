import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/widgets/modals/confirm_modal.dart';
import '../services/acompanante/acompanante_service.dart';
import '../services/viaje/viaje_service.dart';
import '../core/utils/auth_helper.dart';

class AgendarVariosDestinos extends StatefulWidget {
  const AgendarVariosDestinos({super.key});

  @override
  State<AgendarVariosDestinos> createState() => _AgendarVariosDestinosState();
}

class _AgendarVariosDestinosState extends State<AgendarVariosDestinos> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  bool _isCreatingTrip = false;

  final List<TextEditingController> _destinoControllers = [];

  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();

  //String origen = '';
  //String destino = '';

  DateTime? fechaSeleccionada;

  String? metodoPago;
  String? especificaciones;
  String? idAcompananteSeleccionado;

  String? selectedAcompananteId;
  List<Map<String, String>> acompanantes = [];
  bool cargandoAcompanantes = false;

  // Variables de estado
  //String _selectedDate = '28';
  int _selectedIndex = 1;
  int _cantidadDestinos = 2; // Control de paradas dinámicas
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

  // Estilo base para consistencia
  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 18}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  @override
  void initState() {
    super.initState();

    _syncDestinoControllers();
    _cargarAcompanantes();
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
      if (mounted) {
        AuthHelper.manejarError(context, e);
      }
    }

    if (mounted) {
      setState(() => cargandoAcompanantes = false);
    }
  }

  @override
  void dispose() {
    origenController.dispose();
    destinoController.dispose();
    for (var controller in _destinoControllers) {
      controller.dispose();
    }
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                    const SizedBox(height: 15),
                    Text('Seleccionar fecha', style: mExtrabold()),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            final prev = _weekStart.subtract(
                              const Duration(days: 7),
                            );
                            if (!prev.isBefore(_inicioSemana(DateTime.now()))) {
                              setState(() => _weekStart = prev);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(
                              () => _weekStart = _weekStart.add(
                                const Duration(days: 7),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
                          Row(
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
                          ),
                          const SizedBox(height: 15),
                          Text('Lugar', style: mSemibold()),
                          const SizedBox(height: 8),
                          _buildZMGAutocomplete(
                            'Ubicación actual',
                            origenController,
                          ),

                          // Lógica de cantidad de destinos
                          const SizedBox(height: 10),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Cantidad de destinos',
                                  style: mSemibold(
                                    color: primaryBlue,
                                    size: 12,
                                  ),
                                ),
                                _buildStepperDestinos(),
                              ],
                            ),
                          ),

                          // Generación dinámica de paradas
                          ...List.generate(_cantidadDestinos, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildZMGAutocomplete(
                                'Parada ${index + 1}',
                                _destinoControllers[index],
                              ),
                            );
                          }),

                          const SizedBox(height: 10),
                          _buildOneDestinationButton(),
                          const SizedBox(height: 15),
                          _buildCompanionSection(),
                          const SizedBox(height: 10),
                          _buildAcompananteDropdown(),
                          const SizedBox(height: 15),
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
                            (v) => setState(() => selectedPayment = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 30),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 45),
          Text('Agenda tu viaje', style: mExtrabold(size: 22)),
          Transform.translate(
            offset: const Offset(0, 40), // Posición exacta solicitada
            child: Image.asset(
              'assets/control_voz.png',
              height: 65,
              width: 65,
              errorBuilder: (c, e, s) => const CircleAvatar(
                backgroundColor: primaryBlue,
                child: Icon(Icons.mic, color: Colors.white),
              ),
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

  Widget _buildStepperDestinos() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => setState(() {
            if (_cantidadDestinos > 2) {
              _cantidadDestinos--;
              _syncDestinoControllers();
            }
          }),
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
            style: mSemibold(color: Colors.white, size: 16),
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            if (_cantidadDestinos < 5) {
              _cantidadDestinos++;
              _syncDestinoControllers();
            }
          }),
          icon: const Icon(Icons.add_circle, color: primaryBlue, size: 28),
        ),
      ],
    );
  }

  Widget _buildZMGAutocomplete(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (value) {
          if (value.text.isEmpty) return const Iterable<String>.empty();
          return zmgLocations.where(
            (loc) => loc.toLowerCase().contains(value.text.toLowerCase()),
          );
        },
        onSelected: (value) {
          controller.text = value;
        },
        fieldViewBuilder: (context, _, focusNode, __) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: mSemibold(color: primaryBlue, size: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: mSemibold(color: accentBlue, size: 13),
              icon: const Icon(Icons.location_on, color: primaryBlue),
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  // --- REUTILIZACIÓN DE WIDGETS DE BASE ---
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

  Widget _buildAcompananteDropdown() {
    if (!hasCompanion) return const SizedBox();

    if (cargandoAcompanantes) {
      return const Center(child: CircularProgressIndicator());
    }

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
                ? 'Registra acompañantes...'
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
          onPressed: () {}, // estimación pendiente
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
                  onConfirm: () {
                    Navigator.pushReplacementNamed(context, '/home_pasajero');
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOneDestinationButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/agendar_viaje');
        },
        icon: const Icon(Icons.alt_route, color: Colors.white),
        label: Text(
          'Agendar un solo destino',
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

  DateTime _buildFechaHoraInicio() {
    if (_selectedDateTime == null) {
      throw Exception('Selecciona una fecha');
    }
    if (selectedHour == null || selectedMinute == null) {
      throw Exception('Selecciona una hora');
    }

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

      if (text.isEmpty) {
        throw Exception('Completa todos los destinos');
      }

      destinos.add({"direccion": text, "orden": i + 1});
    }

    return destinos;
  }

  Future<void> _crearViaje() async {
    // 1. Validaciones previas para no ensuciar la lógica asíncrona
    if (_isCreatingTrip) return;

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

    // Validar que los destinos no estén vacíos
    for (int i = 0; i < _cantidadDestinos; i++) {
      if (_destinoControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El destino ${i + 1} está vacío')),
        );
        return;
      }
    }

    setState(() => _isCreatingTrip = true);

    try {
      final fechaHoraInicio = _buildFechaHoraInicio();
      final destinos = _buildDestinosPayload();

      // Llamada al servicio
      final viajeId = await ViajeService.crearViaje(
        puntoInicio: origenController.text.trim(),
        destino: null, // Correcto, es null porque hay múltiples
        destinos:
            destinos, // Asegúrate que el servicio reciba List<Map<String, dynamic>>
        checkVariosDestinos: true,
        fechaHoraInicio: fechaHoraInicio.toIso8601String(),
        metodoPago: selectedPayment ?? 'Efectivo', // Valor por defecto seguro
        especificaciones: especificaciones,
        checkAcompanante: hasCompanion,
        idAcompanante: hasCompanion ? selectedAcompananteId : null,
      );

      if (!mounted) return;

      // Navegación exitosa
      Navigator.pushReplacementNamed(
        context,
        '/principal_pasajero',
        arguments: viajeId,
      );
    } catch (e) {
      if (!mounted) return;
      AuthHelper.manejarError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isCreatingTrip = false);
      }
    }
  }
}
