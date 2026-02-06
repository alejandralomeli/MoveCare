import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/pagos/pagos_service.dart'; 
// 1. IMPORTAR AUTH HELPER (Ajusta la ruta si es necesario)
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
  bool _isLoading = false; 

  // --- CONTROLLERS ---
  final TextEditingController _numeroCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _expiraCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  // Estilos
  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
        color: color, fontSize: size, fontWeight: FontWeight.w600);
  }

  TextStyle mBold({Color color = primaryBlue, double size = 14}) {
    return GoogleFonts.montserrat(
        color: color, fontSize: size, fontWeight: FontWeight.w800);
  }

  // --- LÓGICA DE GUARDADO CON AUTH HELPER ---
  Future<void> _guardarTarjeta() async {
    final numero = _numeroCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();

    if (numero.length < 16 || nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor verifica los datos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. SIMULACIÓN DE TOKENIZACIÓN 
      final ultimos4 = numero.substring(numero.length - 4);
      final tokenSimulado = "tok_simulado_${DateTime.now().millisecondsSinceEpoch}";
      
      String marca = "Desconocida";
      if (numero.startsWith("4")) marca = "visa";
      if (numero.startsWith("5")) marca = "mastercard";

      // 2. ENVIAR AL BACKEND
      // Nota: El servicio usa HttpClient internamente, el cual inyecta el token Auth.
      await PagosService.agregarTarjeta(
        token: tokenSimulado,
        ultimosCuatro: ultimos4,
        marca: marca,
        alias: "Tarjeta de $nombre", 
      );

      if (!mounted) return;
      
      // Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Tarjeta guardada con éxito!"),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); 

    } catch (e) {
      // 3. USO DEL AUTH HELPER PARA ERRORES
      if (mounted) {
        // Esto validará si es 'TOKEN_INVALIDO' (401) y expulsará al usuario,
        // o mostrará un SnackBar normal si es otro error.
        AuthHelper.manejarError(context, e);
      }
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                child: Column(
                  children: [
                    // Banner informativo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Ingrese los datos de su tarjeta',
                            style: mBold(color: Colors.white, size: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // CONTENEDOR PRINCIPAL
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
                          // Imagen tarjeta (Placeholder)
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(Icons.credit_card, size: 80, color: primaryBlue),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // CAMPOS CON CONTROLLERS
                          _buildTextField(
                            'Número de la tarjeta',
                            controller: _numeroCtrl,
                            circleColor: Colors.white,
                            inputType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Nombre Completo',
                            controller: _nombreCtrl,
                            circleColor: primaryBlue,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildTextField(
                                  'Fecha Exp (MM/AA)',
                                  controller: _expiraCtrl,
                                  circleColor: Colors.white,
                                  inputType: TextInputType.datetime,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  'CVV',
                                  controller: _cvvCtrl,
                                  circleColor: primaryBlue,
                                  inputType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // BOTÓN CON ACCIÓN
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarTarjeta, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 5,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Agregar Tarjeta', style: mBold(color: Colors.white, size: 15)),
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

  Widget _buildTextField(String hint, {
    required Color circleColor,
    required TextEditingController controller, 
    TextInputType inputType = TextInputType.text, 
  }) {
    return Container(
      decoration: BoxDecoration(
        color: textFieldBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller, 
        keyboardType: inputType, 
        style: mBold(size: 14),
        decoration: InputDecoration(
          hintText: hint,
          // ignore: deprecated_member_use
          hintStyle: mSemibold(color: primaryBlue.withOpacity(0.6), size: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: CircleAvatar(
              backgroundColor: circleColor,
              radius: 10,
            ),
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
            child: const CircleAvatar( 
              backgroundColor: primaryBlue,
              radius: 30,
              child: Icon(Icons.mic, color: Colors.white, size: 30),
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
          _navIcon(0, Icons.home),
          _navIcon(1, Icons.location_on),
          _navIcon(2, Icons.history),
          _navIcon(3, Icons.person),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: active ? primaryBlue : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              if (!active)
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
            ]),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: 28,
        ),
      ),
    );
  }
}