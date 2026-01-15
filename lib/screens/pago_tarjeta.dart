import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagoTarjetaScreen extends StatefulWidget {
  final double totalAPagar; 

  const PagoTarjetaScreen({super.key, this.totalAPagar = 100.00});

  @override
  State<PagoTarjetaScreen> createState() => _PagoTarjetaScreenState();
}

class _PagoTarjetaScreenState extends State<PagoTarjetaScreen> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  int _selectedIndex = 1; 
  String tipoTarjetaSeleccionada = 'Crédito'; 

  TextStyle mSemibold({Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 18}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
    );
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
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: containerBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tarjeta de crédito o débito', 
                        style: mExtrabold(color: primaryBlue, size: 18)),
                      Text('Seleccione un método', 
                        style: mSemibold(size: 12)),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(child: _buildSelectorTarjeta('Crédito', 'assets/tarjeta_credito.png')),
                          const SizedBox(width: 15),
                          Expanded(child: _buildSelectorTarjeta('Débito', 'assets/tarjeta_debito.png')),
                        ],
                      ),
                      
                      const SizedBox(height: 25),
                      Text('Detalles de Tarjeta', 
                        style: mExtrabold(color: primaryBlue, size: 18)),
                      Text('Selecciona para ingresar los datos de tu tarjeta crédito / débito', 
                        style: mSemibold(size: 11)),
                      const SizedBox(height: 15),
                      
                      // CONTENEDOR DE DETALLES REDONDEADO Y CON SOMBRA
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25), // Redondeado solicitado
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 5), // Sombra por abajo
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/tarjeta.png',
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Container(
                                height: 180,
                                child: const Icon(Icons.credit_card, size: 80, color: primaryBlue),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      _buildBottomPayBar(),
                    ],
                  ),
                ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 45), 
          Text('Pago con tarjeta', style: mExtrabold(size: 22)),
          Transform.translate(
            offset: const Offset(0, 50),
            child: Image.asset(
              'assets/control_voz.png', 
              height: 65, width: 65, 
              errorBuilder: (c, e, s) => const CircleAvatar(backgroundColor: primaryBlue, child: Icon(Icons.mic, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTarjeta(String tipo, String assetPath) {
    bool isSelected = tipoTarjetaSeleccionada == tipo;
    return GestureDetector(
      onTap: () => setState(() => tipoTarjetaSeleccionada = tipo),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? primaryBlue : Colors.transparent, width: 2),
              // SOMBRA POR ABAJO PARA CRÉDITO/DÉBITO
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 3), 
                ),
              ],
            ),
            child: Image.asset(
              assetPath,
              errorBuilder: (c, e, s) => const Icon(Icons.credit_card, size: 50, color: primaryBlue),
            ),
          ),
          const SizedBox(height: 5),
          Text(tipo, style: mSemibold(color: primaryBlue, size: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomPayBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(20),
        // SOMBRA POR ABAJO PARA LA BARRA DE PAGO
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total', style: mSemibold(color: Colors.white, size: 12)),
              Text('\$${widget.totalAPagar.toStringAsFixed(2)}', 
                style: mExtrabold(color: Colors.white, size: 22)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            ),
            child: Text('Pagar', style: mExtrabold(color: Colors.white, size: 16)),
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
        decoration: BoxDecoration(color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 28),
      ),
    );
  }
}