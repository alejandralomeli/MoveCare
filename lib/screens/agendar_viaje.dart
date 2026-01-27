import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendarViaje extends StatefulWidget {
  const AgendarViaje({super.key});

  @override
  State<AgendarViaje> createState() => _AgendarViajeState();
}

class _AgendarViajeState extends State<AgendarViaje> with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  String _selectedDate = '28';
  int _selectedIndex = 1;
  bool _isVoiceActive = false;

  late AnimationController _pulseController;

  String? selectedHour;
  String? selectedMinute;
  String? selectedNeed;
  String? selectedPayment;
  bool hasCompanion = false;

  final List<String> hoursList = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> minutesList = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  
  final List<String> zmgLocations = [
    'Guadalajara Centro', 'Zapopan Centro', 'Tlaquepaque Centro', 'Andares', 'Providencia'
  ];

  final List<String> needsList = [
    'Tercera Edad', 'Movilidad reducida', 'Discapacidad auditiva', 'Obesidad', 'Discapacidad visual'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
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
    super.dispose();
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

  TextStyle mSemibold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mExtrabold(double sw, {Color color = Colors.black, double size = 22}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sw * (size / 375),
      fontWeight: FontWeight.w800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sw = size.width;

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
              onVoiceTap: _toggleVoice,
              screenWidth: sw,
              pulseAnimation: _pulseController,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  _buildInstructionBadge(sw),
                  const SizedBox(height: 15),
                  Text('Seleccionar fecha', style: mSemibold(sw, size: 18)),
                  const SizedBox(height: 10),
                  Center(child: _buildDateRow(sw)),
                  const SizedBox(height: 20),
                  
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
                            Expanded(child: _buildTimeDropdown(sw, 'Hora', hoursList, selectedHour, (v) => setState(() => selectedHour = v))),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTimeDropdown(sw, 'Minutos', minutesList, selectedMinute, (v) => setState(() => selectedMinute = v))),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text('Lugar', style: mSemibold(sw)),
                        const SizedBox(height: 8),
                        _buildZMGAutocomplete(sw, 'Ubicación actual'),
                        const SizedBox(height: 8),
                        _buildZMGAutocomplete(sw, 'Lugar de destino'),
                        const SizedBox(height: 15),
                        _buildCompanionSection(sw),
                        const SizedBox(height: 15),
                        _buildSpecialNeedDropdown(sw),
                        const SizedBox(height: 15),
                        Center(child: Text('Seleccionar forma de pago', style: mSemibold(sw, color: primaryBlue, size: 13))),
                        const SizedBox(height: 8),
                        _buildSimpleDropdown(sw, 'Forma de pago', Icons.monetization_on_outlined, ['Tarjeta', 'Efectivo'], selectedPayment, (v) => setState(() => selectedPayment = v)),
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

  Widget _buildDateRow(double sw) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['26', '27', '28', '29', '30'].map((d) => _dateItem(sw, d == '26' ? 'D' : d == '27' ? 'L' : 'M', d)).toList(),
      ),
    );
  }

  Widget _dateItem(double sw, String day, String num) {
    bool isSelected = _selectedDate == num;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        width: sw * 0.15,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryBlue : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
              child: Text(day, textAlign: TextAlign.center, style: mSemibold(sw, color: Colors.white, size: 11)),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(num, style: mExtrabold(sw, color: primaryBlue, size: 16)),
                  Icon(Icons.circle, size: 4, color: isSelected ? Colors.red : Colors.transparent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZMGAutocomplete(double sw, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: mSemibold(sw, color: accentBlue, size: 13),
          icon: const Icon(Icons.location_on, color: primaryBlue, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(double sw, String hint, List<String> items, String? val, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Text(hint, style: mSemibold(sw, color: accentBlue, size: 12)),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: mSemibold(sw, color: primaryBlue)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildCompanionSection(double sw) {
    return Row(
      children: [
        Checkbox(value: hasCompanion, activeColor: primaryBlue, onChanged: (v) => setState(() => hasCompanion = v!)),
        Text('Registrar acompañante', style: mSemibold(sw, color: accentBlue, size: 13)),
      ],
    );
  }

  Widget _buildSpecialNeedDropdown(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedNeed,
          hint: Text('Necesidad especial', style: mSemibold(sw, color: accentBlue, size: 13)),
          isExpanded: true,
          items: needsList.map((e) => DropdownMenuItem(value: e, child: Text(e, style: mSemibold(sw, color: primaryBlue)))).toList(),
          onChanged: (v) => setState(() => selectedNeed = v),
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown(double sw, String hint, IconData icon, List<String> items, String? val, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          hint: Row(children: [Icon(icon, color: primaryBlue, size: 20), const SizedBox(width: 10), Text(hint, style: mSemibold(sw, color: accentBlue, size: 13))]),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: mSemibold(sw, color: primaryBlue)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildInstructionBadge(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('Ingresa los datos para agendar', style: mSemibold(sw, color: Colors.white, size: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double sw) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, minimumSize: Size(sw * 0.6, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: Text('Mostrar estimación', style: mSemibold(sw, color: Colors.white, size: 16)),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionBtn(sw, 'Agendar viaje', accentBlue),
            _actionBtn(sw, 'Cancelar', accentBlue),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(double sw, String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: Size(sw * 0.4, 42), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Text(label, style: mSemibold(sw, color: Colors.white, size: 12)),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: containerBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [0, 1, 2, 3].map((i) => _navIcon(i, i == 0 ? Icons.home : i == 1 ? Icons.location_on : i == 2 ? Icons.history : Icons.person)).toList(),
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
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 26),
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

  _DynamicHeaderDelegate({
    required this.maxHeight, 
    required this.minHeight, 
    required this.isVoiceActive, 
    required this.onVoiceTap, 
    required this.screenWidth,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 35, 
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1559B2), size: 20),
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
                height: 65, width: 65,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c,e,s) => CircleAvatar(
                    backgroundColor: isVoiceActive ? Colors.red : const Color(0xFF1559B2), 
                    child: Icon(isVoiceActive ? Icons.mic : Icons.mic_none, color: Colors.white)
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}