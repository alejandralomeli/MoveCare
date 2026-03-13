import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/vehicle/vehicle_service.dart';
import '../app_theme.dart';

class ContinuarRegistroConductor extends StatefulWidget {
  const ContinuarRegistroConductor({super.key});

  @override
  State<ContinuarRegistroConductor> createState() =>
      _ContinuarRegistroConductorState();
}

class _ContinuarRegistroConductorState
    extends State<ContinuarRegistroConductor> {
  double sp(double size, double sw) => sw * (size / 375);

  late String idUsuario;
  String? idConductor;

  final TextEditingController modeloController = TextEditingController();
  final TextEditingController placasController = TextEditingController();

  final List<String> marcas = [
    'Toyota Hiace',
    'Nissan Urvan',
    'Mercedes-Benz Sprinter',
    'Ford Transit',
    'Volkswagen Transporter',
    'Chevrolet Express',
  ];

  final List<String> colores = [
    'Blanco',
    'Gris Plata',
    'Negro',
    'Azul Marino',
    'Rojo',
    'Arena/Beige',
    'Verde Oscuro',
  ];

  final List<String> accesorios = [
    'Rampa Hidráulica',
    'Escalón Retráctil',
    'Anclajes para Silla de Ruedas',
    'Asientos Giratorios',
    'Pasamanos Adicionales',
    'Ninguno',
  ];

  String? marcaSeleccionada;
  String? colorSeleccionado;
  String? accesorioSeleccionado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      idUsuario = args;
      _obtenerIdConductor();
    }
  }

  Future<void> _obtenerIdConductor() async {
    final response = await VehicleService.getConductorId(idUsuario: idUsuario);
    if (response["ok"]) {
      setState(() {
        idConductor = response["id_conductor"];
      });
    } else {
      _showError(response["error"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppHeader(title: 'Datos del Vehículo'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro de Vehículo',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Completa los datos de tu van de traslado',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _sectionLabel('Marca del vehículo'),
              const SizedBox(height: 8),
              _buildDropdown(
                options: marcas,
                value: marcaSeleccionada,
                hint: 'Selecciona la marca',
                icon: Icons.directions_car_outlined,
                onChanged: (val) => setState(() => marcaSeleccionada = val),
              ),

              const SizedBox(height: 16),

              _sectionLabel('Modelo (Año)'),
              const SizedBox(height: 8),
              TextField(
                controller: modeloController,
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ej. 2022',
                  prefixIcon:
                      Icon(Icons.calendar_today_outlined),
                ),
              ),

              const SizedBox(height: 16),

              _sectionLabel('Color'),
              const SizedBox(height: 8),
              _buildDropdown(
                options: colores,
                value: colorSeleccionado,
                hint: 'Selecciona el color',
                icon: Icons.palette_outlined,
                onChanged: (val) => setState(() => colorSeleccionado = val),
              ),

              const SizedBox(height: 16),

              _sectionLabel('Placas'),
              const SizedBox(height: 8),
              TextField(
                controller: placasController,
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ej. ABC-123-D',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
              ),

              const SizedBox(height: 16),

              _sectionLabel('Accesorios especiales'),
              const SizedBox(height: 8),
              _buildDropdown(
                options: accesorios,
                value: accesorioSeleccionado,
                hint: 'Selecciona un accesorio',
                icon: Icons.build_outlined,
                onChanged: (val) =>
                    setState(() => accesorioSeleccionado = val),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registrarVehiculo,
                  child: const Text('Registrarme'),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/iniciar_sesion'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                          color: AppColors.textSecondary, fontSize: 13),
                      children: [
                        const TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Inicia Sesión',
                          style: GoogleFonts.montserrat(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> options,
    required String? value,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(hint,
          style: GoogleFonts.montserrat(
              color: AppColors.textSecondary, fontSize: 14)),
      icon: const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
      ),
      dropdownColor: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      items: options
          .map((opt) => DropdownMenuItem<String>(
                value: opt,
                child: Text(opt,
                    style: GoogleFonts.montserrat(
                        fontSize: 14, color: AppColors.textPrimary)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _registrarVehiculo() async {
    if (idConductor == null) {
      _showError('No se pudo obtener el conductor');
      return;
    }

    if (marcaSeleccionada == null ||
        colorSeleccionado == null ||
        modeloController.text.isEmpty ||
        placasController.text.isEmpty) {
      _showError('Por favor completa todos los campos requeridos');
      return;
    }

    final response = await VehicleService.registerVehicle(
      idConductor: idConductor!,
      marca: marcaSeleccionada!,
      modelo: modeloController.text,
      color: colorSeleccionado!,
      placas: placasController.text,
      accesorios: accesorioSeleccionado,
    );

    if (!mounted) return;
    if (response["ok"]) {
      Navigator.pushReplacementNamed(context, '/iniciar_sesion');
    } else {
      _showError(response["error"]);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
