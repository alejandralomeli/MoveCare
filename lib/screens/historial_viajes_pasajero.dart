import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/auth_helper.dart'; // Ajusta la ruta
import '../services/viaje/viaje_service.dart';

class HistorialViajesPasajero extends StatefulWidget {
  const HistorialViajesPasajero({super.key});

  @override
  State<HistorialViajesPasajero> createState() => _HistorialViajesPasajero();
}

class _HistorialViajesPasajero extends State<HistorialViajesPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  int _selectedIndex = 2; // Historial seleccionado en el menú inferior
  String _filterSelected = 'Todos';

  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  bool _isLoading = true;
  List<dynamic> _viajesCompletos = []; // Todos los datos del back
  List<dynamic> _viajesFiltrados = []; // Los que se muestran

  // Filtros actualizados según tu requerimiento
  final List<String> filters = [
    'Todos',
    'Pendiente',
    'Agendado',
    'En curso',
    'Finalizado',
    'Cancelado',
  ];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      final data = await ViajeService.obtenerHistorial();
      if (mounted) {
        setState(() {
          _viajesCompletos = data;
          _viajesFiltrados = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AuthHelper.manejarError(context, e);
      }
    }
  }

  void _aplicarFiltro(String filtro) {
    setState(() {
      _filterSelected = filtro;
      if (filtro == 'Todos') {
        _viajesFiltrados = _viajesCompletos;
      } else {
        // Mapeo: "En curso" -> "En_curso" para comparar con la BD
        String filtroNormalizado = filtro.replaceAll(" ", "_");
        _viajesFiltrados = _viajesCompletos
            .where(
              (v) =>
                  v['estado'].toString().toLowerCase() ==
                  filtroNormalizado.toLowerCase(),
            )
            .toList();
      }
    });
  }

  // Helper para asignar colores según el estado
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_curso':
        return const Color(0xFF1559B2);
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'agendado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFilterMenu(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    )
                  : _viajesFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        "No hay viajes en esta categoría",
                        style: mBold(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: _viajesFiltrados.length,
                      itemBuilder: (context, index) {
                        final viaje = _viajesFiltrados[index];
                        return _buildTripCard(
                          // Reemplaza guión bajo por espacio para la vista
                          viaje['estado'].toString().replaceAll("_", " "),
                          _getStatusColor(viaje['estado']),
                          viaje['fecha_inicio'],
                          viaje['punto_inicio'],
                          viaje['destino'] ?? 'Múltiples destinos',
                          viaje['nombre_conductor'],
                          viaje['foto_conductor'],
                        );
                      },
                    ),
            ),
          ],
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Historial de Viajes',
            style: mBold(size: 22, color: Colors.black),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: const Offset(10, 45),
              child: Image.asset(
                'assets/control_voz.png',
                height: 65,
                width: 65,
                errorBuilder: (c, e, s) => const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.mic, color: primaryBlue, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = _filterSelected == filter;
          return GestureDetector(
            onTap: () =>
                _aplicarFiltro(filter), // Llamada a la función de filtrado
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue : lightBlueBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: mBold(
                  color: isSelected ? Colors.white : primaryBlue,
                  size: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripCard(
    String status,
    Color statusColor,
    String date,
    String origen,
    String destino,
    String? conductor,
    String? foto,
  ) {
    return Container(
      // ... (Mantenemos la decoración del Container igual) ...
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(status, style: mBold(color: Colors.white, size: 11)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        origen,
                        style: mBold(size: 14, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Colors.black26,
                    ),
                    Expanded(
                      child: Text(
                        destino,
                        textAlign: TextAlign.end,
                        style: mBold(size: 14, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text('Fecha $date', style: mBold(size: 11, color: accentBlue)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: containerBlue,
                      backgroundImage: (foto != null && foto.isNotEmpty)
                          ? NetworkImage(foto) as ImageProvider
                          : const AssetImage('assets/conductor.png'),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conductor ?? 'Buscando...',
                          style: mBold(size: 14, color: Colors.black),
                        ),
                        // ... (Resto de la info: Estrellas y Badge Verificado igual) ...
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: Color(0xFFE3F2FD)),
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
        // Solo navegamos si no estamos ya en esa pantalla
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
