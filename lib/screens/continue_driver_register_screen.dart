import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueDriverRegisterScreen extends StatefulWidget {
  const ContinueDriverRegisterScreen({super.key});

  @override
  State<ContinueDriverRegisterScreen> createState() => _ContinueDriverRegisterScreenState();
}

class _ContinueDriverRegisterScreenState extends State<ContinueDriverRegisterScreen> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  // --- LISTAS DE OPCIONES ---
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

  // Variables para guardar la selección
  String? marcaSeleccionada;
  String? colorSeleccionado;
  String? accesorioSeleccionado;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo del Mapa
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Logo Circular Centrado
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
                  boxShadow: [
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
          
          // 3. Tarjeta Blanca de Formulario
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

                    // --- CAMPOS ---
                    _buildDropdownField(
                      label: 'Marca del auto (Van)',
                      options: marcas,
                      value: marcaSeleccionada,
                      onChanged: (val) => setState(() => marcaSeleccionada = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    _buildTextField(
                      label: 'Modelo (Año)',
                      iconColor: Colors.blue.shade400,
                    ),

                    _buildDropdownField(
                      label: 'Color',
                      options: colores,
                      value: colorSeleccionado,
                      onChanged: (val) => setState(() => colorSeleccionado = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    _buildTextField(
                      label: 'Placas',
                      iconColor: Colors.blue.shade400,
                    ),

                    _buildDropdownField(
                      label: 'Accesorios especiales',
                      options: accesorios,
                      value: accesorioSeleccionado,
                      onChanged: (val) => setState(() => accesorioSeleccionado = val),
                      iconColor: Colors.blue.shade900,
                    ),

                    const SizedBox(height: 30),

                    // Botón Registrarme
                    SizedBox(
                      width: size.width * 0.75,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Aquí iría la lógica final de registro
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
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

  // WIDGET DROP DOWN (CORREGIDO Y CENTRADO)
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
          icon: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.arrow_drop_down, color: primaryBlue),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            // PrefixIcon ajustado para centrar el círculo
            prefixIcon: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CircleAvatar(
                  backgroundColor: iconColor,
                  radius: 10,
                ),
              ),
            ),
            // Padding vertical para centrar el texto seleccionado
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
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // WIDGET TEXTFIELD ESTÁNDAR
  Widget _buildTextField({required String label, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: fieldBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          style: GoogleFonts.montserrat(color: primaryBlue, fontSize: 14),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.montserrat(
              color: primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: UnconstrainedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CircleAvatar(
                  backgroundColor: iconColor,
                  radius: 10,
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black54),
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