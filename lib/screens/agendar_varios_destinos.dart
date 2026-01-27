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
  // Color azul claro para los labels solicitados
  static const Color labelBlue = Color(0xFF42A5F5);

  bool _isVoiceActive = false;
  String _selectedDate = '28';
  int _selectedIndex = 1;
  int _cantidadDestinos = 2;

  String? selectedHour;
  String? selectedMinute;
  String? selectedNeed;
  String? selectedPayment;
  bool hasCompanion = false;

  final List<String> hoursList = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  final List<String> minutesList = List.generate(60, (index) => index.toString().padLeft(2, '0'));
  final List<String> zmgLocations = ['Guadalajara Centro', 'Zapopan Centro', 'Tlaquepaque', 'Andares', 'Plaza del Sol'];
  final List<String> needsList = ['Tercera Edad', 'Movilidad reducida', 'Discapacidad auditiva', 'Obesidad', 'Discapacidad visual'];

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 11}) =>
      GoogleFonts.montserrat(color: color, fontSize: (sw * (size / 375)), fontWeight: FontWeight.bold);

  TextStyle labelStyle(double sw, {double size = 14}) =>
      GoogleFonts.montserrat(color: labelBlue, fontSize: (sw * (size / 375)), fontWeight: FontWeight.w700);

  TextStyle mSemibold(double sw, {Color color = Colors.black, double size = 14}) =>
      GoogleFonts.montserrat(color: color, fontSize: (sw * (size / 375)), fontWeight: FontWeight.w600);

  TextStyle mExtrabold(double sw, {Color color = Colors.black, double size = 18}) =>
      GoogleFonts.montserrat(color: color, fontSize: (sw * (size / 375)), fontWeight: FontWeight.w800);

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
              onVoiceTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
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
                  Text('Seleccionar fecha', style: mExtrabold(sw, size: 20)),
                  const SizedBox(height: 10),
                  _buildDateRow(sw),
                  const SizedBox(height: 20),
                  _buildFormContainer(sw),
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

  Widget _buildFormContainer(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(color: containerBlue, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seleccionar hora', style: mSemibold(sw)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTimeDropdown('Hora', hoursList, selectedHour, (v) => setState(() => selectedHour = v), sw)),
              const SizedBox(width: 10),
              Expanded(child: _buildTimeDropdown('Minutos', minutesList, selectedMinute, (v) => setState(() => selectedMinute = v), sw)),
            ],
          ),
          const SizedBox(height: 15),
          Text('Lugar', style: mSemibold(sw)),
          const SizedBox(height: 8),
          _buildZMGAutocomplete('Ubicación actual', sw),
          const SizedBox(height: 15),
          Center(
            child: Column(
              children: [
                Text('Cantidad de destinos', style: mSemibold(sw, color: primaryBlue, size: 12)),
                _buildStepperDestinos(sw),
              ],
            ),
          ),
          ...List.generate(_cantidadDestinos, (index) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildZMGAutocomplete('Parada ${index + 1}', sw),
          )),
          const SizedBox(height: 15),
          _buildCompanionSection(sw),
          const SizedBox(height: 15),
          _buildSpecialNeedDropdown(sw),
          const SizedBox(height: 15),
          Center(child: Text('Seleccionar forma de pago', style: mSemibold(sw, color: primaryBlue, size: 13))),
          const SizedBox(height: 8),
          _buildSimpleDropdown('Forma de pago', Icons.monetization_on_outlined, ['Tarjeta', 'Efectivo'], selectedPayment, (v) => setState(() => selectedPayment = v), sw),
        ],
      ),
    );
  }

  Widget _buildDateRow(double sw) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [_dateItem('D', '26', sw), _dateItem('L', '27', sw), _dateItem('M', '28', sw), _dateItem('M', '29', sw), _dateItem('J', '30', sw)],
      ),
    );
  }

  Widget _dateItem(String day, String num, double sw) {
    bool isSelected = _selectedDate == num;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        width: sw * 0.155,
        height: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? primaryBlue : Colors.transparent, width: 2)),
        child: Column(
          children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 2), decoration: const BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(10))), child: Text(day, textAlign: TextAlign.center, style: mSemibold(sw, color: Colors.white, size: 11))),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(num, style: mExtrabold(sw, color: primaryBlue, size: 16)), Icon(Icons.circle, size: 4, color: isSelected ? Colors.red : Colors.transparent), Text('Oct', style: mSemibold(sw, size: 9))]))
          ],
        ),
      ),
    );
  }

  Widget _buildStepperDestinos(double sw) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: () => setState(() => _cantidadDestinos > 1 ? _cantidadDestinos-- : null), icon: const Icon(Icons.remove_circle, color: primaryBlue, size: 28)),
      Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5), decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)), child: Text('$_cantidadDestinos', style: mSemibold(sw, color: Colors.white, size: 16))),
      IconButton(onPressed: () => setState(() => _cantidadDestinos < 5 ? _cantidadDestinos++ : null), icon: const Icon(Icons.add_circle, color: primaryBlue, size: 28))
    ]);
  }

  Widget _buildZMGAutocomplete(String hint, double sw) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Autocomplete<String>(optionsBuilder: (v) => v.text.isEmpty ? const Iterable.empty() : zmgLocations.where((l) => l.toLowerCase().contains(v.text.toLowerCase())), fieldViewBuilder: (c, ct, f, o) => TextField(controller: ct, focusNode: f, decoration: InputDecoration(hintText: hint, hintStyle: labelStyle(sw), icon: const Icon(Icons.location_on, color: primaryBlue, size: 20), border: InputBorder.none))));
  }

  Widget _buildTimeDropdown(String h, List<String> i, String? v, Function(String?) o, double sw) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: v, hint: Text(h, style: labelStyle(sw, size: 12)), isExpanded: true, items: i.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: o)));
  }

  Widget _buildSpecialNeedDropdown(double sw) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selectedNeed, hint: Text('Necesidad especial', style: labelStyle(sw, size: 13)), isExpanded: true, items: needsList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => selectedNeed = v))));
  }

  Widget _buildSimpleDropdown(String h, IconData i, List<String> it, String? v, Function(String?) o, double sw) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: v, hint: Row(children: [Icon(i, color: primaryBlue, size: 20), const SizedBox(width: 10), Text(h, style: labelStyle(sw, size: 13))]), isExpanded: true, items: it.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: o)));
  }

  Widget _buildCompanionSection(double sw) {
    return Row(children: [Checkbox(value: hasCompanion, activeColor: primaryBlue, onChanged: (v) => setState(() => hasCompanion = v!)), Text('Registrar acompañante', style: mSemibold(sw, color: accentBlue, size: 13))]);
  }

  Widget _buildInstructionBadge(double sw) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.info_outline, color: Colors.white, size: 20), const SizedBox(width: 8), Text('Ingresa los datos para agendar', style: mSemibold(sw, color: Colors.white, size: 12))]));
  }

  Widget _buildActionButtons(double sw) {
    return Column(children: [
      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, minimumSize: Size(sw * 0.6, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: Text('Mostrar estimación', style: mSemibold(sw, color: Colors.white, size: 16))),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: _actionBtn('Agenda tu viaje', accentBlue, sw))),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: _actionBtn('Cancelar', accentBlue, sw))),
      ])
    ]);
  }

  Widget _actionBtn(String l, Color c, double sw) {
    return ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: c, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text(l, textAlign: TextAlign.center, style: mSemibold(sw, color: Colors.white, size: 12)));
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(height: sw * 0.2, decoration: const BoxDecoration(color: containerBlue), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_navIcon(0, Icons.home), _navIcon(1, Icons.location_on), _navIcon(2, Icons.history), _navIcon(3, Icons.person)]));
  }

  Widget _navIcon(int i, IconData ic) {
    bool a = _selectedIndex == i;
    return GestureDetector(onTap: () => setState(() => _selectedIndex = i), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: a ? primaryBlue : Colors.white, shape: BoxShape.circle), child: Icon(ic, color: a ? Colors.white : primaryBlue, size: 28)));
  }
}

class _DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;
  final double screenWidth;

  _DynamicHeaderDelegate({required this.maxHeight, required this.minHeight, required this.isVoiceActive, required this.onVoiceTap, required this.screenWidth});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = shrinkOffset / maxHeight;
    final double opacity = 1.0 - percent.clamp(0.0, 1.0);

    return _VoicePulseWrapper(
      maxHeight: maxHeight,
      opacity: opacity,
      isVoiceActive: isVoiceActive,
      onVoiceTap: onVoiceTap,
    );
  }

  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _DynamicHeaderDelegate oldDelegate) => true;
}

class _VoicePulseWrapper extends StatefulWidget {
  final double maxHeight;
  final double opacity;
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  const _VoicePulseWrapper({required this.maxHeight, required this.opacity, required this.isVoiceActive, required this.onVoiceTap});

  @override
  State<_VoicePulseWrapper> createState() => _VoicePulseWrapperState();
}

class _VoicePulseWrapperState extends State<_VoicePulseWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
          bottom: -25,
          child: GestureDetector(
            onTap: widget.onVoiceTap,
            child: ScaleTransition(
              scale: _animation,
              child: Image.asset(
                widget.isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
                height: 65,
                width: 65,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}