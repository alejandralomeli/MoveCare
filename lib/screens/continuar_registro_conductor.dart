import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/vehicle/vehicle_service.dart';

class ContinuarRegistroConductor extends StatefulWidget {
  const ContinuarRegistroConductor({super.key});

  @override
  State<ContinuarRegistroConductor> createState() =>
      _ContinueDriverRegisterScreenState();
}

class _ContinueDriverRegisterScreenState
    extends State<ContinuarRegistroConductor> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  // ================== IDS ==================
  late String idUsuario;
  String? idConductor;

  // ================== CONTROLLERS ==================
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController placasController = TextEditingController();

  // ================== LISTAS ==================
  final List<String> marcas = [
    'Toyota Hiace',
    'Nissan Urvan',
    'Mercedes-Benz Sprinter',
    'Ford Transit',
    'Volkswagen Transporter',
    'Chevrolet Express'
  ];

  final List<String> colores = [
    'Blanco',
    'Gris Plata',
    'Negro',
    'Azul Marino',
    'Rojo',
    'Arena/Beige',
    'Verde Oscuro'
  ];

  final List<String> accesorios = [
    'Rampa Hidráulica',
    'Escalón Retráctil',
    'Anclajes para Silla de Ruedas',
    'Asientos Giratorios',
    'Pasamanos Adicionales',
    'Ninguno'
  ];

  // ================== SELECCIONES ==================
  String? marcaSeleccionada;
  String? colorSeleccionado;
  String? accesorioSeleccionado;

  // ================== INIT ==================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    idUsuario = ModalRoute.of(context)!.settings.arguments as String;
    _obtenerIdConductor();
  }

  Future<void> _obtenerIdConductor() async {
    final response =
        await VehicleService.getConductorId(idUsuario: idUsuario);

    if (response["ok"]) {
      setState(() {
        idConductor = response["id_conductor"];
      });
    } else {
      _showError(response["error"]);
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset('assets/movecare.png'),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.68,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    Text(
                      'Datos de mi Vehículo',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildDropdownField(
                      label: 'Marca del auto (Van)',
                      options: marcas,
                      value: marcaSeleccionada,
                      onChanged: (val) =>
                          setState(() => marcaSeleccionada = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    _buildTextField(
                      label: 'Modelo (Año)',
                      iconColor: Colors.blue.shade400,
                      controller: modeloController,
                    ),

                    _buildDropdownField(
                      label: 'Color',
                      options: colores,
                      value: colorSeleccionado,
                      onChanged: (val) =>
                          setState(() => colorSeleccionado = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    _buildTextField(
                      label: 'Placas',
                      iconColor: Colors.blue.shade400,
                      controller: placasController,
                    ),

                    _buildDropdownField(
                      label: 'Accesorios especiales',
                      options: accesorios,
                      value: accesorioSeleccionado,
                      onChanged: (val) =>
                          setState(() => accesorioSeleccionado = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: size.width * 0.75,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _registrarVehiculo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Registrarme',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildFooter(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== LOGICA ==================
  Future<void> _registrarVehiculo() async {
    if (idConductor == null) {
      _showError('No se pudo obtener el conductor');
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

    if (response["ok"]) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showError(response["error"]);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ================== WIDGETS ==================
  Widget _buildDropdownField({
    required String label,
    required List<String> options,
    required String? value,
    required Function(String?) onChanged,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            label,
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          decoration: const InputDecoration(border: InputBorder.none),
          items: options
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Color iconColor,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            'Inicia Sesión',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
