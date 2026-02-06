import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import './providers/user_provider.dart';

import 'screens/splash_screen.dart'; 
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
        textTheme: GoogleFonts.montserratTextTheme(),
      ),

      home: const SplashScreen(), 

      routes: {
        // Rutas existentes
        '/menu_vistas': (context) => const MenuVistas(),
        
        '/': (context) => const Bienvenido(),
        
        '/iniciar_sesion': (context) => const IniciarSesion(), 
        '/olvide_contrasena': (context) => const OlvideContrasena(),
        '/confirmar-correo': (context) => const ConfirmarCorreoScreen(),
        
        // Registro
        '/registro': (context) => const Registro(),
        
        // Conductor
        '/registro_conductor': (context) => const RegistroConductor(),
        '/continue_driver_register_screen': (context) => const ContinuarRegistroConductor(),
        
        // Pasajero
        '/registro_pasajero': (context) => const RegistroPasajero(),
        '/principal_pasajero': (context) => const PrincipalPasajero(),

        '/codigo_verificacion': (context) => const CodigoVerificacion(),//SE ELIMINARA

        '/completar_perfil_pasajero': (context) => const CompletarPerfilPasajero(),//VERIFICAR DETALLES
        '/agendar_viaje': (context) => const AgendarViaje(), 
        '/mi_perfil_pasajero': (context) => const MiPerfilPasajero(),
        '/agendar_varios_destinos': (context) => const AgendarVariosDestinos(),
        '/pago_tarjeta': (context) => const PagoTarjetaScreen(),//FALTA
        '/registro_tarjeta': (context) => const RegistroTarjetaScreen(),
        '/registro_acompanante': (context) => const RegistrarAcompanante(),
        '/historial_viajes_pasajero': (context) => const HistorialViajesPasajero(),
        '/viaje_confirmado': (context) => const ViajeConfirmado(),
        '/estimacion_costo': (context) => const EstimacionViaje(),//FALTA
      },
    );
  }
}
