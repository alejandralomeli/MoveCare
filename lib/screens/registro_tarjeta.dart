import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importaciones de tu lógica
import '../services/pagos/pagos_service.dart';
import '../core/utils/auth_helper.dart';

class RegistroTarjetaScreen extends StatefulWidget {
  const RegistroTarjetaScreen({super.key});

  @override
  State<RegistroTarjetaScreen> createState() => _RegistroTarjetaScreenState();
}

class _RegistroTarjetaScreenState extends State<RegistroTarjetaScreen> {
  // Colores unificados
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color textFieldBlue = Color(0xFFB3D4FF);

  int _selectedIndex = 1;
  bool _isLoading = false; // Variable de carga

  // --- CONTROLLERS (Para capturar el texto) ---
  final TextEditingController _numeroCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _expiraCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  // Estilos
  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
  }

  // --- LÓGICA DE GUARDADO ---
  Future<void> _guardarTarjeta() async {
    final numero = _numeroCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();
    final expira = _expiraCtrl.text.trim();
    final cvv = _cvvCtrl.text.trim();

    // Validación simple
    if (numero.length < 16 ||
        nombre.isEmpty ||
        expira.isEmpty ||
        cvv.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor verifica todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulación de datos para el servicio
      final ultimos4 = numero.substring(numero.length - 4);
      final tokenSimulado = "tok_${DateTime.now().millisecondsSinceEpoch}";

      String marca = "Desconocida";
      if (numero.startsWith("4")) marca = "visa";
      if (numero.startsWith("5")) marca = "mastercard";

      // Llamada al servicio
      await PagosService.agregarTarjeta(
        token: tokenSimulado,
        ultimosCuatro: ultimos4,
        marca: marca,
        alias: "Tarjeta de $nombre",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Tarjeta guardada con éxito!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Regresar atrás
    } catch (e) {
      if (mounted) AuthHelper.manejarError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                  bottom: 20,
                  top: 40,
                ),
                child: Column(
                  children: [
                    // Banner informativo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ingrese los datos de su tarjeta',
                            style: mBold(color: Colors.white, size: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // CONTENEDOR PRINCIPAL SOMBREADO
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: containerBlue,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Imagen de tarjeta (Estática como pediste)
                          Container(
                            height:
                                180, // Altura fija para evitar errores si no carga la imagen
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/tarjeta.png', // Asegúrate de tener este asset o cambia por un Icon
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(
                                    Icons.credit_card,
                                    size: 80,
                                    color: primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // CAMPOS DE ENTRADA (Conectados a Controllers)
                          _buildTextField(
                            'Número de la tarjeta',
                            circleColor: Colors.white,
                            controller: _numeroCtrl,
                            inputType: TextInputType.number,
                            maxLength: 16,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Nombre Completo',
                            circleColor: primaryBlue,
                            controller: _nombreCtrl,
                            inputType: TextInputType.name,
                          ),
                          const SizedBox(height: 12),

                          // FILA CON DOS CAMPOS AL MISMO TIEMPO
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildTextField(
                                  'Fecha Exp (MM/AA)',
                                  circleColor: Colors.white,
                                  controller: _expiraCtrl,
                                  inputType: TextInputType.datetime,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  'CVV',
                                  circleColor: primaryBlue,
                                  controller: _cvvCtrl,
                                  inputType: TextInputType.number,
                                  maxLength: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // BOTÓN CON LÓGICA DE CARGA
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _guardarTarjeta, // Desactiva si carga
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Agregar Tarjeta',
                                style: mBold(color: Colors.white, size: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Widget TextField mejorado para recibir controladores
  Widget _buildTextField(
    String hint, {
    required Color circleColor,
    required TextEditingController controller, // Ahora requiere controller
    TextInputType inputType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: textFieldBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLength: maxLength,
        style: mBold(size: 14),
        decoration: InputDecoration(
          counterText: "", // Oculta el contador de caracteres
          hintText: hint,
          hintStyle: mSemibold(color: primaryBlue.withOpacity(0.6), size: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: CircleAvatar(backgroundColor: circleColor, radius: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: const BoxDecoration(color: lightBlueBg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Transform.translate(
            offset: const Offset(0, 50),
            child: CircleAvatar(
              // Cambié a un placeholder por si no tienes el asset 'control_voz'
              backgroundColor: primaryBlue,
              radius: 30,
              child: const Icon(Icons.mic, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(color: containerBlue),
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
          boxShadow: [
            if (!active)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}
