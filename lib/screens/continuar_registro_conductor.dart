import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/vehicle/vehicle_service.dart';

class ContinuarRegistroConductor extends StatefulWidget {
  const ContinuarRegistroConductor({super.key});

  @override
  State<ContinuarRegistroConductor> createState() =>
      _ContinuarRegistroConductorState();
}

class _ContinuarRegistroConductorState
    extends State<ContinuarRegistroConductor> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  // ================== UI HELPERS ==================
  double sp(double size, double sw) => sw * (size / 375);

  // ================== IDS & LOGIC ==================
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

  // ================== SELECCIONES ==================
  String? marcaSeleccionada;
  String? colorSeleccionado;
  String? accesorioSeleccionado;

  // ================== INIT ==================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recuperamos el ID del argumento de la ruta
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

  // ================== UI BUILD ==================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Image.asset('assets/ruta.png', fit: BoxFit.cover),
          ),

          // Botón de regresar (UI de Main)
          Positioned(
            top: sp(35, sw),
            left: sp(15, sw),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryBlue,
                  size: sp(22, sw),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Logo (UI de Main)
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: sp(100, sw),
                height: sp(100, sw),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset('assets/movecare.png'),
                ),
              ),
            ),
          ),

          // Formulario
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sp(30, sw)),
                child: Column(
                  children: [
                    SizedBox(height: sp(35, sw)),
                    Text(
                      'Datos de mi Vehículo',
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(20, sw),
                      ),
                    ),
                    SizedBox(height: sp(25, sw)),

                    // Campos del formulario (Estilo Main + Lógica Head)
                    _buildDropdownField(
                      sw: sw,
                      label: 'Marca del auto (Van)',
                      options: marcas,
                      value: marcaSeleccionada,
                      onChanged: (val) =>
                          setState(() => marcaSeleccionada = val),
                      iconColor: Colors.blue.shade900,
                    ),
                    _buildTextField(
                      sw: sw,
                      label: 'Modelo (Año)',
                      iconColor: Colors.blue.shade400,
                      controller: modeloController,
                    ),
                    _buildDropdownField(
                      sw: sw,
                      label: 'Color',
                      options: colores,
                      value: colorSeleccionado,
                      onChanged: (val) =>
                          setState(() => colorSeleccionado = val),
                      iconColor: Colors.blue.shade900,
                    ),
                    _buildTextField(
                      sw: sw,
                      label: 'Placas',
                      iconColor: Colors.blue.shade400,
                      controller: placasController,
                    ),
                    _buildDropdownField(
                      sw: sw,
                      label: 'Accesorios especiales',
                      options: accesorios,
                      value: accesorioSeleccionado,
                      onChanged: (val) =>
                          setState(() => accesorioSeleccionado = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    SizedBox(height: sp(30, sw)),

                    // Botón de Registrar (Estilo Main + Lógica Head)
                    SizedBox(
                      width: sw * 0.75,
                      height: sp(55, sw),
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
                            fontSize: sp(16, sw),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sp(20, sw)),
                    _buildFooter(context, sw),
                    SizedBox(height: sp(40, sw)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== LOGICA DEL NEGOCIO ==================
  Future<void> _registrarVehiculo() async {
    if (idConductor == null) {
      _showError('No se pudo obtener el conductor');
      return;
    }

    // Validación básica de campos vacíos
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

    if (response["ok"]) {
      if (mounted) Navigator.pushReplacementNamed(context, '/iniciar_sesion');
    } else {
      _showError(response["error"]);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ================== WIDGETS PERSONALIZADOS ==================

  Widget _buildDropdownField({
    required double sw,
    required String label,
    required List<String> options,
    required String? value,
    required Function(String?) onChanged,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(12, sw)),
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
              fontSize: sp(14, sw),
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.arrow_drop_down, color: primaryBlue),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CircleAvatar(
                  backgroundColor: iconColor,
                  radius: sp(10, sw),
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
          dropdownColor: fieldBlue,
          borderRadius: BorderRadius.circular(20),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: GoogleFonts.montserrat(
                  color: primaryBlue,
                  fontSize: sp(14, sw),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required double sw,
    required String label,
    required Color iconColor,
    required TextEditingController controller, // Fusionado: Agregado controller
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(12, sw)),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller, // Fusionado: Usando el controller
          style: GoogleFonts.montserrat(
            color: primaryBlue,
            fontSize: sp(14, sw),
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue,
              fontSize: sp(14, sw),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CircleAvatar(
                  backgroundColor: iconColor,
                  radius: sp(10, sw),
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: GoogleFonts.montserrat(
            fontSize: sp(13, sw),
            color: Colors.black54,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/iniciar_sesion'),
          child: Text(
            'Inicia Sesión',
            style: GoogleFonts.montserrat(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: sp(13, sw),
            ),
          ),
        ),
      ],
    );
  }
}
