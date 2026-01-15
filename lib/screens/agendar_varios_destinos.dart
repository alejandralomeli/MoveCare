import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Variables de estado
  String _selectedDate = '28'; 
  int _selectedIndex = 1; 
  int _cantidadDestinos = 2; // Control de paradas dinámicas

  String? selectedHour;
  String? selectedMinute;
  String? selectedNeed;
  String? selectedPayment;
  bool hasCompanion = false;

  final List<String> hoursList = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> minutesList = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  
  final List<String> zmgLocations = [
    'Guadalajara Centro', 'Zapopan Centro', 'Tlaquepaque', 'Tonalá', 
    'Tlajomulco', 'Chapalita', 'Providencia', 'Puerta de Hierro', 'Colonia Americana',
    'Andares', 'Plaza del Sol', 'Estadio Jalisco', 'Expo Guadalajara'
  ];

  final List<String> needsList = [
    'Tercera Edad', 'Movilidad reducida', 'Discapacidad auditiva', 'Obesidad', 'Discapacidad visual'
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
                    _buildDateRow(),
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
                              Expanded(child: _buildTimeDropdown('Hora', hoursList, selectedHour, (v) => setState(() => selectedHour = v))),
                              const SizedBox(width: 10),
                              Expanded(child: _buildTimeDropdown('Minutos', minutesList, selectedMinute, (v) => setState(() => selectedMinute = v))),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text('Lugar', style: mSemibold()),
                          const SizedBox(height: 8),
                          _buildZMGAutocomplete('Ubicación actual'),
                          
                          // Lógica de cantidad de destinos
                          const SizedBox(height: 10),
                          Center(
                            child: Column(
                              children: [
                                Text('Cantidad de destinos', style: mSemibold(color: primaryBlue, size: 12)),
                                _buildStepperDestinos(),
                              ],
                            ),
                          ),
                          
                          // Generación dinámica de paradas
                          ...List.generate(_cantidadDestinos, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildZMGAutocomplete('Parada ${index + 1}'),
                            );
                          }),

                          const SizedBox(height: 15),
                          _buildCompanionSection(),
                          const SizedBox(height: 15),
                          _buildSpecialNeedDropdown(),
                          const SizedBox(height: 15),
                          Center(
                            child: Text('Seleccionar forma de pago', style: mSemibold(color: primaryBlue, size: 13)),
                          ),
                          const SizedBox(height: 8),
                          _buildSimpleDropdown('Forma de pago', Icons.monetization_on_outlined, ['Tarjeta de crédito', 'Tarjeta de débito', 'Efectivo'], selectedPayment, (v) => setState(() => selectedPayment = v)),
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
              errorBuilder: (c, e, s) => const CircleAvatar(backgroundColor: primaryBlue, child: Icon(Icons.mic, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dateItem('D', '26'),
        _dateItem('L', '27'),
        _dateItem('M', '28'),
        _dateItem('M', '29'),
        _dateItem('J', '30'),
      ],
    );
  }

  Widget _dateItem(String day, String num) {
    bool isSelected = _selectedDate == num;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        width: 58, height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryBlue : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
              child: Text(day, textAlign: TextAlign.center, style: mSemibold(color: Colors.white, size: 11)),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(num, style: mExtrabold(color: primaryBlue, size: 16)),
                  Icon(Icons.circle, size: 4, color: isSelected ? Colors.red : Colors.transparent),
                  Text('Oct', style: mSemibold(size: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperDestinos() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => setState(() => _cantidadDestinos > 1 ? _cantidadDestinos-- : null), 
          icon: const Icon(Icons.remove_circle, color: primaryBlue, size: 28)
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)),
          child: Text('$_cantidadDestinos', style: mSemibold(color: Colors.white, size: 16)),
        ),
        IconButton(
          onPressed: () => setState(() => _cantidadDestinos < 5 ? _cantidadDestinos++ : null), 
          icon: const Icon(Icons.add_circle, color: primaryBlue, size: 28)
        ),
      ],
    );
  }

  Widget _buildZMGAutocomplete(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue value) {
          if (value.text.isEmpty) return const Iterable<String>.empty();
          return zmgLocations.where((loc) => loc.toLowerCase().contains(value.text.toLowerCase()));
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: mSemibold(color: primaryBlue, size: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: mSemibold(color: accentBlue, size: 13),
              icon: const Icon(Icons.location_on, color: primaryBlue, size: 20),
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  // --- REUTILIZACIÓN DE WIDGETS DE BASE ---
  Widget _buildTimeDropdown(String hint, List<String> items, String? val, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(hint, style: mSemibold(color: accentBlue, size: 12)),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: mSemibold(color: primaryBlue)))).toList(),
          onChanged: onChange,
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
              // Reemplazo del icono por la imagen solicitada
              Image.asset(
                'assets/movecare.png', 
                height: 24, 
                width: 24, 
                errorBuilder: (c, e, s) => const Icon(Icons.accessible, color: primaryBlue),
              ),
              const SizedBox(width: 10),
              Text(
                'Necesidad especial', 
                style: mSemibold(color: accentBlue, size: 13),
              ),
            ],
          ),
          isExpanded: true,
          items: needsList.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e, style: mSemibold(color: primaryBlue)),
          )).toList(),
          onChanged: (v) => setState(() => selectedNeed = v),
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(String hint, IconData icon, List<String> items, String? val, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Row(children: [Icon(icon, color: primaryBlue, size: 20), const SizedBox(width: 10), Text(hint, style: mSemibold(color: accentBlue, size: 13))]),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: mSemibold(color: primaryBlue)))).toList(),
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
            Text('Registrar acompañante', style: mSemibold(color: accentBlue, size: 13)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Text('*Marcar solo en caso de llevar acompañante', style: mSemibold(color: Colors.red, size: 9)),
        ),
      ],
    );
  }

  Widget _buildInstructionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('Ingresa los datos para agendar', style: mSemibold(color: Colors.white, size: 12)),
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
            minimumSize: const Size(220, 48), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
          ),
          child: Text('Mostrar estimación', style: mSemibold(color: Colors.white, size: 16)),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionBtn('Agenda tu viaje', accentBlue),
            _actionBtn('Cancelar', accentBlue),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        minimumSize: const Size(140, 42), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
      ),
      child: Text(label, style: mSemibold(size: 13)),
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
        decoration: BoxDecoration(color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}