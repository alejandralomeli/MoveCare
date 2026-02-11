import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagoTarjetaScreen extends StatefulWidget {
  final double totalAPagar;

  const PagoTarjetaScreen({super.key, this.totalAPagar = 100.00});

  @override
  State<PagoTarjetaScreen> createState() => _PagoTarjetaScreenState();
}

class _PagoTarjetaScreenState extends State<PagoTarjetaScreen> {
  // Colores de la paleta estética
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color containerBlue = Color(0xFFD6E8FF);
  static const Color accentBlue = Color(0xFF64A1F4);

  int _selectedIndex = 1;
  String tipoTarjetaSeleccionada = 'Crédito';
  bool _isVoiceActive = false;

  // Función de escalado responsivo
  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mSemibold({Color color = Colors.black, double size = 14, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 18, required double sw}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, sw),
      fontWeight: FontWeight.w800,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(sw),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: sp(25, sw),
                right: sp(25, sw),
                bottom: sp(20, sw),
                top: sp(50, sw),
              ),
              child: Container(
                padding: EdgeInsets.all(sp(20, sw)),
                decoration: BoxDecoration(
                  color: containerBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarjeta de crédito o débito',
                        style: mExtrabold(color: primaryBlue, size: 18, sw: sw)),
                    Text('Seleccione un método',
                        style: mSemibold(size: 12, sw: sw)),
                    SizedBox(height: sp(20, sw)),
                    
                    Row(
                      children: [
                        Expanded(child: _buildSelectorTarjeta('Crédito', 'assets/tarjeta_credito.png', sw)),
                        SizedBox(width: sp(15, sw)),
                        Expanded(child: _buildSelectorTarjeta('Débito', 'assets/tarjeta_debito.png', sw)),
                      ],
                    ),
                    
                    SizedBox(height: sp(25, sw)),
                    Text('Detalles de Tarjeta',
                        style: mExtrabold(color: primaryBlue, size: 18, sw: sw)),
                    Text('Selecciona para ingresar los datos de tu tarjeta',
                        style: mSemibold(size: 11, sw: sw)),
                    SizedBox(height: sp(15, sw)),
                    
                    _buildVisualCard(sw),
                    
                    SizedBox(height: sp(30, sw)),
                    _buildBottomPayBar(sw),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildHeader(double sw) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: const BoxDecoration(color: lightBlueBg),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 10,
              top: 35,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Text(
                'Pago con tarjeta',
                style: mExtrabold(size: 20, color: Colors.black, sw: sw),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -32,
              child: _PulseVoiceButton(
                isActive: _isVoiceActive,
                size: sp(65, sw),
                onTap: () => setState(() => _isVoiceActive = !_isVoiceActive),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTarjeta(String tipo, String assetPath, double sw) {
    bool isSelected = tipoTarjetaSeleccionada == tipo;
    return GestureDetector(
      onTap: () => setState(() => tipoTarjetaSeleccionada = tipo),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(sp(8, sw)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? primaryBlue : Colors.transparent, width: 2),
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
              height: sp(50, sw),
              errorBuilder: (c, e, s) => Icon(Icons.credit_card, size: sp(50, sw), color: primaryBlue),
            ),
          ),
          SizedBox(height: sp(5, sw)),
          Text(tipo, style: mSemibold(color: primaryBlue, size: 12, sw: sw)),
        ],
      ),
    );
  }

  Widget _buildVisualCard(double sw) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
              height: sp(180, sw),
              width: double.infinity,
              color: Colors.white,
              child: Icon(Icons.credit_card, size: sp(80, sw), color: primaryBlue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPayBar(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp(20, sw), vertical: sp(12, sw)),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(20),
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
              Text('Total', style: mSemibold(color: Colors.white, size: 12, sw: sw)),
              Text('\$${widget.totalAPagar.toStringAsFixed(2)}',
                  style: mExtrabold(color: Colors.white, size: 22, sw: sw)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Lógica de pago aquí
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.symmetric(horizontal: sp(25, sw), vertical: sp(10, sw)),
            ),
            child: Text('Pagar', style: mExtrabold(color: Colors.white, size: 16, sw: sw)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: sp(75, sw),
      decoration: const BoxDecoration(color: containerBlue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, sw, '/principal_pasajero'),
          _navIcon(1, Icons.location_on, sw, '/agendar_viaje'),
          _navIcon(2, Icons.history, sw, '/historial_viajes_pasajero'),
          _navIcon(3, Icons.person, sw, '/mi_perfil_pasajero'),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, double sw, String routeName) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          Navigator.pushReplacementNamed(context, routeName);
        }
      },
      child: Container(
        padding: EdgeInsets.all(sp(10, sw)),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: sp(28, sw)),
      ),
    );
  }
}

class _PulseVoiceButton extends StatefulWidget {
  final bool isActive;
  final double size;
  final VoidCallback onTap;

  const _PulseVoiceButton({required this.isActive, required this.size, required this.onTap});

  @override
  State<_PulseVoiceButton> createState() => _PulseVoiceButtonState();
}

class _PulseVoiceButtonState extends State<_PulseVoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulseVoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: widget.isActive ? _animation : const AlwaysStoppedAnimation(1.0),
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (widget.isActive ? Colors.red : const Color(0xFF1559B2)).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Image.asset(
            widget.isActive ? 'assets/escuchando.png' : 'assets/controlvoz.png',
            errorBuilder: (c, e, s) => CircleAvatar(
              backgroundColor: widget.isActive ? Colors.red : const Color(0xFF1559B2),
              child: Icon(
                widget.isActive ? Icons.graphic_eq : Icons.mic,
                color: Colors.white,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}