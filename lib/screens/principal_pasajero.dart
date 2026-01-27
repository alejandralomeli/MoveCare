import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrincipalPasajero extends StatefulWidget {
  const PrincipalPasajero({super.key});

  @override
  State<PrincipalPasajero> createState() => _PrincipalPasajeroState();
}

class _PrincipalPasajeroState extends State<PrincipalPasajero>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color buttonLightBlue = Color(0xFF64A1F4);
  static const Color darkBlue = Color(0xFF0D47A1);

  int _selectedIndex = 0;
  String _selectedDate = '28';
  bool _isListening = false;

  late AnimationController _pulseController;

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
        } else if (status == AnimationStatus.dismissed && _isListening) {
          _pulseController.forward();
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold(
      {Color color = Colors.black,
      double size = 14,
      required BuildContext context}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: lightBlueBg,
                      child: Column(
                        children: [
                          const SizedBox(height: 35),
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: primaryBlue, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/pasajero.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Info Usuario
                    Positioned(
                      bottom: -35,
                      left: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bienvenido!',
                              style: GoogleFonts.montserrat(
                                  fontSize: 24, fontWeight: FontWeight.w900)),
                          Text('Username',
                              style: GoogleFonts.montserrat(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, 'completar_perfil_pasajero'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                  color: buttonLightBlue,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text('Completa tu perfil',
                                      style: mExtrabold(
                                          color: Colors.white,
                                          size: 10,
                                          context: context)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 130, top: 45),
                  child: Row(
                    children: [
                      ...List.generate(
                          5,
                          (index) => const Icon(Icons.star,
                              color: Colors.orange, size: 16)),
                      Text(' 5.00',
                          style: mExtrabold(
                              color: primaryBlue, size: 12, context: context)),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubicación actual',
                          style: mExtrabold(size: 18, context: context)),
                      const SizedBox(height: 10),
                      _buildMapSection(),
                      const SizedBox(height: 25),
                      Text('Próximo viaje',
                          style: mExtrabold(size: 18, context: context)),
                      const SizedBox(height: 10),
                      _buildNextTripCard(context),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _calendarDay('D', '26', context),
                          _calendarDay('L', '27', context),
                          _calendarDay('M', '28', context),
                          _calendarDay('M', '29', context),
                          _calendarDay('J', '30', context),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildAgendarButton(context),
                      ),
                      const SizedBox(height: 25),
                      Text('Historial de viajes',
                          style: mExtrabold(size: 18, context: context)),
                      const SizedBox(height: 10),
                      _buildTripHistory(context),
                      const SizedBox(height: 30),
                      _buildReportButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 87.5,
            right: 20,
            child: GestureDetector(
              onTap: _toggleListening,
              child: ScaleTransition(
                scale: _pulseController,
                child: Image.asset(
                  _isListening
                      ? 'assets/escuchando.png'
                      : 'assets/controlvoz.png',
                  width: 65,
                  height: 65,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  Widget _calendarDay(String day, String num, BuildContext context) {
    bool isSelected = _selectedDate == num;
    double sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        width: sw * 0.15,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? primaryBlue : Colors.transparent, width: 2),
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
              child: Text(day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(num,
                      style: mExtrabold(
                          color: primaryBlue, size: 16, context: context)),
                  if (isSelected)
                    const Icon(Icons.circle, size: 6, color: Colors.red)
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/mapa.png', fit: BoxFit.cover)),
    );
  }

  Widget _buildNextTripCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: cardBlue, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Martes 28 Octubre',
                  style: mExtrabold(size: 15, context: context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: darkBlue, borderRadius: BorderRadius.circular(8)),
                child: Text('9:30am',
                    style: mExtrabold(
                        color: Colors.white, size: 12, context: context)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            _actionBtn('Ver detalles', context),
            const SizedBox(width: 10),
            _actionBtn('Cancelar cita', context)
          ])
        ],
      ),
    );
  }

  Widget _actionBtn(String label, BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: buttonLightBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0),
        child: Text(label,
            style: mExtrabold(color: Colors.white, size: 11, context: context)),
      ),
    );
  }

  Widget _buildAgendarButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
          backgroundColor: buttonLightBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Text('Agendar viaje',
          style: mExtrabold(color: Colors.black, size: 13, context: context)),
    );
  }

  Widget _buildTripHistory(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBlue, width: 1.5)),
      child: Column(
        children: [
          _historyItem('Oct 13', 'Centro médico', 'En curso', context),
          const Divider(height: 1, color: primaryBlue),
          _historyItem('Oct 1', 'Banco', 'Finalizado', context),
        ],
      ),
    );
  }

  Widget _historyItem(
      String date, String title, String status, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(date, style: mExtrabold(size: 12, context: context)),
          const SizedBox(width: 15),
          Expanded(
              child: Text(title,
                  style: mExtrabold(
                      color: primaryBlue, size: 13, context: context))),
          Text(status,
              style: mExtrabold(
                  color: status == 'En curso' ? Colors.green : statusRed,
                  size: 10,
                  context: context)),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.error, color: Colors.white),
        label: Text('Reportar incidencia',
            style: mExtrabold(color: Colors.white, size: 15, context: context)),
        style: ElevatedButton.styleFrom(
            backgroundColor: statusRed,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFD6E8FF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
            4,
            (index) => _navIcon(index,
                [Icons.home, Icons.location_on, Icons.history, Icons.person][index])),
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 26),
      ),
    );
  }
}