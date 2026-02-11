import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/map_widget.dart';
import '../providers/user_provider.dart';
import '../services/home/home_service.dart';
import '../core/utils/auth_helper.dart'; // Importas el ayudante

class PrincipalPasajero extends StatefulWidget {
  const PrincipalPasajero({super.key});

  @override
  State<PrincipalPasajero> createState() => _PrincipalPasajeroState();
}

class _PrincipalPasajeroState extends State<PrincipalPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color buttonLightBlue = Color(0xFF64A1F4);
  static const Color darkBlue = Color(0xFF0D47A1);

  int _selectedIndex = 0;
  String _selectedDate = '28';

  bool _loadingHome = true;

  List<DateTime> _calendarDates = [];
  DateTime? _nextTripDate;
  Map<String, dynamic>? _viajeProximo;
  List<dynamic> _historialViajes = [];

  String _dayLetter(DateTime d) =>
      ['D', 'L', 'M', 'M', 'J', 'V', 'S'][d.weekday % 7];

  String _monthName(DateTime d) => [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ][d.month - 1];

  String _dayName(DateTime d) => [
    'Domingo',
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
  ][d.weekday % 7];

  String _formatHour(DateTime d) =>
      '${d.hour > 12 ? d.hour - 12 : d.hour}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'pm' : 'am'}';

  String _formatDateTime(String isoDate) {
    final d = DateTime.parse(isoDate);

    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  void _buildCalendarDates(DateTime tripDate) {
    _calendarDates = List.generate(
      5,
      (i) => tripDate.add(Duration(days: i - 2)),
    );

    _selectedDate = tripDate.day.toString();
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final homeData = await HomeService.getHome(role: "pasajero");

      final userProvider = context.read<UserProvider>();
      userProvider.setUserFromJson(homeData["usuario"]);

      final fechaViaje = DateTime.parse(
        homeData['viaje_proximo']['fecha_hora_inicio'],
      );

      _nextTripDate = fechaViaje;
      _viajeProximo = homeData['viaje_proximo'];
      _historialViajes = homeData['historial'] ?? [];
      _buildCalendarDates(fechaViaje);

      setState(() => _loadingHome = false);
    } catch (e) {
      // EN LUGAR DE COPIAR Y PEGAR 10 LINEAS, USAS UNA SOLA:
      AuthHelper.manejarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 LOADER
    if (_loadingHome) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: lightBlueBg,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 55,
                    ),
                    child: _buildHeader(),
                  ),
                ),
                Positioned(
                  top: 10,
                  bottom: 3,
                  right: 20,
                  child: Image.asset(
                    'assets/control_voz.png',
                    width: 65,
                    height: 65,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusButton(),
                  const SizedBox(height: 25),
                  Text('Ubicación actual', style: mExtrabold(size: 18)),
                  const SizedBox(height: 10),
                  _buildMapSection(),
                  const SizedBox(height: 25),
                  Text('Próximo viaje', style: mExtrabold(size: 18)),
                  const SizedBox(height: 10),
                  _buildNextTripCard(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _calendarDates.map((date) {
                      return _calendarDay(
                        _dayLetter(date),
                        date.day.toString(),
                        date,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildAgendarButton(),
                  ),
                  const SizedBox(height: 25),
                  Text('Historial de viajes', style: mExtrabold(size: 18)),
                  const SizedBox(height: 10),
                  _buildTripHistory(_historialViajes),
                  const SizedBox(height: 30),
                  _buildReportButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<UserProvider>().user;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF81D4FA),
            backgroundImage: AssetImage('assets/pasajero.png'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.nombre ?? '', style: mExtrabold(size: 22)),
              Row(
                children: const [
                  Icon(Icons.star, color: Colors.orange, size: 18),
                  Icon(Icons.star, color: Colors.orange, size: 18),
                  Icon(Icons.star, color: Colors.orange, size: 18),
                  Icon(Icons.star, color: Colors.orange, size: 18),
                  Icon(Icons.star, color: Colors.orange, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              _buildBadge(Icons.check_circle, 'Verificado'),
              const SizedBox(height: 4),
              _buildBadge(Icons.info, 'Pendiente de verificación'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calendarDay(String day, String num, DateTime date) {
    bool isSelected = _selectedDate == num;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = num),
      child: Container(
        width: 55,
        height: 64,
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
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    num,
                    style: GoogleFonts.montserrat(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: isSelected ? Colors.red : Colors.transparent,
                  ),
                  Text(
                    _monthName(date),
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHistory(List<dynamic> historial) {
    if (historial.isEmpty) {
      return const Text('No hay viajes recientes');
    }

    final items = historial.length > 3 ? historial.sublist(0, 3) : historial;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue, width: 1.5),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final viaje = items[index];

          return Column(
            children: [
              _historyItem(
                _formatDateTime(viaje['fecha_hora_inicio']),
                viaje['destino'] ?? '',
                viaje['estado'] ?? '',
                viaje['conductor_nombre'] ?? '',
              ),
              if (index < items.length - 1)
                const Divider(height: 1, color: primaryBlue),
            ],
          );
        }),
      ),
    );
  }

  Widget _historyItem(
    String date,
    String title,
    String status,
    String conductorNombre,
  ) {
    final nombre = conductorNombre.isNotEmpty
        ? conductorNombre
        : 'Asignando...';

    return InkWell(
      onTap: () {
        print("Click en viaje: $title");
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Text(date, style: mExtrabold(size: 13)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: mExtrabold(color: primaryBlue, size: 14)),
                  Text(
                    'Conductor: $nombre',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Text(status, style: mExtrabold(color: statusRed, size: 11)),
          ],
        ),
      ),
    );
  }

  // ... (Los demás widgets de soporte: _buildBadge, _buildStatusButton, etc., se mantienen igual que en el código anterior)

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label, style: mExtrabold(color: Colors.white, size: 9)),
        ],
      ),
    );
  }

  Widget _buildStatusButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusRed,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Text('Completar perfil', style: mExtrabold(color: Colors.white)),
        ],
      ),
    );
  }

  //Cambio por google Maps listo
  Widget _buildMapSection() {
    return Container(
      height: 130,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: const MapWidget(),
    );
  }

  Widget _buildNextTripCard() {
    if (_nextTripDate == null || _viajeProximo == null) {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_dayName(_nextTripDate!)} ${_nextTripDate!.day} ${_monthName(_nextTripDate!)}',
                    style: mExtrabold(size: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chofer: ${_viajeProximo!['nombre_conductor'] ?? 'Asignando...'}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Lugar: ${_viajeProximo!['destino']}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _formatHour(_nextTripDate!),
                  style: mExtrabold(color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _tripActionBtn('Ver detalles'),
              const SizedBox(width: 10),
              _tripActionBtn('Cancelar cita'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tripActionBtn(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonLightBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: mExtrabold(color: Colors.white, size: 12)),
      ),
    );
  }

  Widget _buildAgendarButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/agendar_viaje');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonLightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        'Agendar viaje',
        style: mExtrabold(color: Colors.black, size: 14),
      ),
    );
  }

  //Pendiente cuando haga los reportes
  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.error, color: Colors.white),
        label: Text(
          'Reportar incidencia',
          style: mExtrabold(color: Colors.white, size: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: statusRed,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
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
}
