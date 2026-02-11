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

class _AgendarViajeState extends State<AgendarViaje>
    with TickerProviderStateMixin {
  // --- CONSTANTES DE COLOR ---
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  // --- VARIABLES DE LÓGICA (HEAD) ---
  bool _isCreatingTrip = false;

  final TextEditingController origenController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();

  String origen = '';
  String destino = '';

  // Variables de Fecha y Hora
  DateTime _weekStart = DateTime.now();
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

  // --- VARIABLES DE UI/ANIMACIÓN (MAIN) ---
  int _selectedIndex = 1;
  bool _isVoiceActive = false;
  late AnimationController _pulseController;

  // --- MÉTODOS DE FECHA ---
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

  // --- INIT & DISPOSE ---
  @override
  void initState() {
    super.initState();
    // Carga de datos
    _cargarDatosIniciales();

    // Inicialización de Animación de Voz
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Dinámico con Animación
          SliverPersistentHeader(
            pinned: true,
            delegate: _DynamicHeaderDelegate(
              maxHeight: 110,
              minHeight: 85,
              isVoiceActive: _isVoiceActive,
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
              pulseAnimation: _pulseController,
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
                  Center(child: _buildDateRow(sw)),
                  const SizedBox(height: 20),

                  // Contenedor Azul Claro
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
                            style: mSemibold(sw, color: primaryBlue, size: 13),
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
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  // --- WIDGETS AUXILIARES ---

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
          const Icon(Icons.info_outline, color: Colors.white, size: 18),
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
          icon: const Icon(Icons.chevron_left, color: primaryBlue),
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
          icon: const Icon(Icons.chevron_right, color: primaryBlue),
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
    // Usamos la lógica dinámica de HEAD pero el estilo visual de Main
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
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
            onTap: isPast
                ? null
                : () => setState(() => _selectedDateTime = date),
            child: Opacity(
              opacity: isPast ? 0.4 : 1.0,
              child: Container(
                width: sw * 0.13, // Ancho responsivo
                height: 65,
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
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        _dayLetter(date),
                        textAlign: TextAlign.center,
                        style: mSemibold(sw, color: Colors.white, size: 11),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: mExtrabold(sw, color: primaryBlue, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildZMGAutocomplete({
    required double sw,
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
          if (controller.text.isNotEmpty && textController.text.isEmpty) {
            textController.text = controller.text;
          }
          return TextField(
            controller: textController,
            focusNode: focusNode,
            style: mSemibold(sw, color: primaryBlue),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: mSemibold(sw, color: accentBlue, size: 13),
              icon: const Icon(Icons.location_on, color: primaryBlue, size: 20),
              border: InputBorder.none,
            ),
            onChanged: (value) => onSelected(value),
          );
        },
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(hint, style: mSemibold(sw, color: accentBlue, size: 12)),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(sw, color: primaryBlue)),
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
          activeColor: primaryBlue,
          onChanged: (v) => setState(() => hasCompanion = v!),
        ),
        Text(
          'Registrar acompañante',
          style: mSemibold(sw, color: accentBlue, size: 13),
        ),
        const Spacer(),
        if (hasCompanion)
          Text('* Requerido', style: mSemibold(sw, color: Colors.red, size: 9)),
      ],
    );
  }

  Widget _buildAcompananteDropdown(double sw) {
    if (cargandoAcompanantes)
      return const Center(child: LinearProgressIndicator());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedAcompananteId,
          hint: Text(
            acompanantes.isEmpty
                ? 'Sin acompañantes'
                : 'Selecciona acompañante',
            style: mSemibold(sw, color: accentBlue, size: 13),
          ),
          isExpanded: true,
          items: acompanantes.map((a) {
            return DropdownMenuItem(
              value: a["id"],
              child: Text(
                a["nombre"]!,
                style: mSemibold(sw, color: primaryBlue),
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
        icon: const Icon(Icons.person_add, size: 18, color: primaryBlue),
        label: Text(
          "Nuevo acompañante",
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
          hint: Text(
            'Necesidad especial',
            style: mSemibold(sw, color: accentBlue, size: 13),
          ),
          isExpanded: true,
          items: needsList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(sw, color: primaryBlue)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Row(
            children: [
              Icon(icon, color: primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(hint, style: mSemibold(sw, color: accentBlue, size: 13)),
            ],
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: mSemibold(sw, color: primaryBlue)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentBlue.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTarjetaId,
          hint: Row(
            children: [
              const Icon(Icons.credit_card, color: primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(hintText, style: mSemibold(sw, color: accentBlue, size: 13)),
            ],
          ),
          isExpanded: true,
          items: tarjetas.map((t) {
            return DropdownMenuItem(
              value: t["id"],
              child: Text(
                t["texto"]!,
                style: mSemibold(sw, color: primaryBlue),
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
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
          backgroundColor: primaryBlue,
          minimumSize: Size(sw * 0.7, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
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
            // Lógica de estimación futura
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Estimación calculada: \$150.00")),
            );
          },
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
            _actionBtn(
              sw,
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
              sw,
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

  Widget _actionBtn(
    double sw,
    String label,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(sw * 0.35, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: mSemibold(sw, color: Colors.white, size: 12)),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: containerBlue),
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
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 26),
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
      Navigator.pushReplacementNamed(context, '/home_pasajero');
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
  final Animation<double> pulseAnimation;

  _DynamicHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.isVoiceActive,
    required this.onVoiceTap,
    required this.screenWidth,
    required this.pulseAnimation,
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
          bottom: -28,
          child: GestureDetector(
            onTap: onVoiceTap,
            child: ScaleTransition(
              scale: pulseAnimation,
              child: Container(
                height: 65,
                width: 65,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  isVoiceActive
                      ? 'assets/escuchando.png'
                      : 'assets/control_voz.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => CircleAvatar(
                    backgroundColor: isVoiceActive
                        ? Colors.red
                        : const Color(0xFF1559B2),
                    child: Icon(
                      isVoiceActive ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
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
