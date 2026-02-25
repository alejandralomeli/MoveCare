import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth/auth_service.dart';
import 'widgets/modals/terminos_modal.dart';

class PerfilPasajero extends StatefulWidget {
  const PerfilPasajero({super.key});

  @override
  State<PerfilPasajero> createState() => _PerfilPasajeroState();
}

class _PerfilPasajeroState extends State<PerfilPasajero> {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color navBarBg = Color(0xFFD6E8FF);
  static const Color buttonLightBlue = Color(0xFF64A1F4);
  static const Color statusRed = Color(0xFFEF5350);

  int _selectedIndex = 3;
  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({
    Color color = Colors.black,
    double size = 14,
    required BuildContext context,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        color: lightBlueBg,
                        child: Column(
                          children: [
                            const SizedBox(height: 35),
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: 20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/pasajero.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -35,
                        left: 130,
                        child: Text(
                          'Mi Perfil',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                    child: Column(
                      children: [
                        _profileItem(
                          Icons.person,
                          "Información personal",
                          context,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/completar_perfil_pasajero',
                            );
                          },
                        ),
                        _profileItem(
                          Icons.notifications,
                          "Notificaciones",
                          context,
                        ),
                        _profileItem(
                          Icons.credit_card,
                          "Métodos de pago",
                          context,
                          onTap: () {
                            Navigator.pushNamed(context, '/metodos_pago_lista');
                          },
                        ),
                        // _profileItem(Icons.security, "Seguridad", context),
                        _profileItem(
                          Icons
                              .policy, // Cambiamos el icono para que haga sentido
                          "Términos y Privacidad",
                          context,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors
                                  .transparent, // Transparente para que se vean las esquinas redondeadas
                              isScrollControlled: true,
                              builder: (context) => const TerminosModal(),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context),
    );
  }

  Widget _profileItem(
    IconData icon,
    String title,
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    // 🔥 Envolvemos todo en un GestureDetector para que sea clickeable
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(width: 15),
            Text(title, style: mExtrabold(size: 14, context: context)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // 🔥 Aquí conectamos la función y la ruta
        onPressed: () async {
          // 1. Borramos el token del celular
          await AuthService.logout();

          // 2. Redirigimos y destruimos el historial de navegación
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/bienvenido', // Tu ruta de destino
              (route) => false, // Esto elimina todas las pantallas anteriores
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: statusRed,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'Cerrar sesión',
          style: mExtrabold(color: Colors.white, size: 16, context: context),
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context) {
    return Container(
      height: sp(85, context),
      padding: EdgeInsets.symmetric(horizontal: sp(10, context)),
      decoration: const BoxDecoration(
        color: navBarBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(0, Icons.home, context),
          _navIcon(1, Icons.location_on, context),
          _navIcon(2, Icons.history, context),
          _navIcon(3, Icons.person, context),
        ],
      ),
    );
  }

  Widget _navIcon(int index, IconData icon, BuildContext context) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 0) Navigator.pop(context);
      },
      child: Container(
        width: sp(45, context),
        height: sp(45, context),
        decoration: BoxDecoration(
          color: active ? primaryBlue : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : primaryBlue,
          size: sp(26, context),
        ),
      ),
    );
  }
}
