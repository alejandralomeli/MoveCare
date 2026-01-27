//MENU PROVISIONAL PARA PRUEBAS
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './providers/user_provider.dart';

import 'screens/bienvenido.dart';
import 'package:movecare/screens/iniciar_sesion.dart';
import 'screens/registro.dart';
import 'screens/continuar_registro_conductor.dart';
import 'screens/olvide_contrasena.dart';
import 'screens/registro_conductor.dart';
import 'screens/registro_pasajero.dart';
import 'screens/codigo_verificacion.dart';
import 'screens/principal_pasajero.dart';
import 'screens/completar_perfil_pasajero.dart';
import 'screens/agendar_viaje.dart';
import 'screens/menu_vistas.dart';
import 'screens/mi_perfil_pasajero.dart';
import 'screens/agendar_varios_destinos.dart';
import 'screens/pago_tarjeta.dart';
import 'screens/registro_tarjeta.dart';
import 'screens/registro_acompanante.dart';
import 'screens/historial_viajes_pasajero.dart';
import 'screens/viaje_confirmado.dart';
import 'screens/estimacion_costo.dart';
import 'screens/confirmar_correo.dart';

// Colores constantes compartidos
const Color primaryColor = Color(0xFF2E6FFC);
const Color cardBackgroundColor = Color(0xFFE3F2FD);

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveCare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
        // Configuración global de fuentes para toda la app
        textTheme: GoogleFonts.montserratTextTheme(),
      ),

      initialRoute: '/menu_vistas',

      routes: {
        // Ruta del menú provisional
        '/menu_vistas': (context) => const MenuVistas(),

        // Rutas existentes
        '/': (context) => const Bienvenido(),
        '/iniciar_sesion': (context) => const IniciarSesion(), 
        '/olvide_contrasena': (context) => const OlvideContrasena(), //Pendiente, debo ver lo del correo
        '/confirmar-correo': (context) => const ConfirmarCorreoScreen(),
        
        // Registro Principal (Selección de rol)
        '/registro': (context) => const Registro(),
        
        // Flujo del Conductor
        '/registro_conductor': (context) => const RegistroConductor(),
        '/continue_driver_register_screen': (context) => const ContinuarRegistroConductor(),
        
        // Flujo del Pasajero
        '/registro_pasajero': (context) => const RegistroPasajero(),
        '/principal_pasajero': (context) => const PrincipalPasajero(), //Hoy debe kuedar

        '/codigo_verificacion': (context) => const CodigoVerificacion(), //Posiblemente se elimine

        '/completar_perfil_pasajero': (context) => const CompletarPerfilPasajero(), //Formulario (Pendiente temas con Ale)
        '/agendar_viaje': (context) => const AgendarViaje(), //Hoy debe kuedar
        '/mi_perfil_pasajero': (context) => const MiPerfilPasajero(), //Consulta
        '/agendar_varios_destinos': (context) => const AgendarVariosDestinos(), //Hoy debe kuedar
        '/pago_tarjeta': (context) => const PagoTarjetaScreen(), //Este sera el mayor pendiente a futuro
        '/registro_tarjeta': (context) => const RegistroTarjetaScreen(), //Hoy debe kuedar
        '/registro_acompanante': (context) => const RegistrarAcompanante(), //Hoy debe kuedar
        '/historial_viajes_pasajero': (context) => const HistorialViajesPasajero(), //Hoy debe kuedar
        '/viaje_confirmado': (context) => const ViajeConfirmado(), //Consulta
        '/estimacion_costo': (context) => const EstimacionViaje(), //Consulta con calculo en proceso
      },
    );
  }
}
