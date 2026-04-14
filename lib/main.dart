import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movecare/providers/font_size_provider.dart' show FontSizeProvider;
import './providers/user_provider.dart';
import 'app_theme.dart';

// Screens Generales y Auth
import 'screens/splash_screen.dart'; 
import 'screens/bienvenido.dart';
import 'package:movecare/screens/iniciar_sesion.dart';
import 'screens/registro.dart';
import 'screens/olvide_contrasena.dart';
import 'screens/confirmar_correo.dart';
import 'screens/nueva_contrasena.dart';
import 'screens/menu_vistas.dart';

// Screens Pasajero
import 'screens/registro_pasajero.dart';
import 'screens/principal_pasajero.dart';
import 'screens/completar_perfil_pasajero.dart';
import 'screens/perfil_pasajero.dart';
import 'screens/agendar_viaje.dart';
import 'screens/agendar_varios_destinos.dart';
import 'screens/pago_tarjeta.dart';
import 'screens/registro_tarjeta.dart';
import 'screens/registro_acompanante.dart';
import 'screens/historial_viajes_pasajero.dart';
import 'screens/reporte_incidencia_pasajero.dart';
import 'screens/reporte_incidencia_conductor.dart';
import 'screens/viaje_confirmado.dart';
import 'screens/estimacion_costo.dart';
import 'screens/metodos_pago_vista.dart';
import 'screens/terminos_vista.dart';

// Screens Conductor
import 'screens/registro_conductor.dart';
import 'screens/continuar_registro_conductor.dart';
import 'screens/principal_conductor.dart';
import 'screens/mi_perfil_conductor.dart';
import 'screens/viaje_actual.dart';
import 'screens/solicitud_viaje.dart';
import 'screens/solicitudes_viaje_conductor.dart';
import 'screens/historial_viajes_conductor.dart';  
import 'screens/completar_perfil_conductor.dart';
import 'screens/agregar_ine.dart';
import 'screens/agregar_licencia.dart';
import 'screens/metricas_conductor.dart';

// Screens Administrativo
import 'screens/principal_administrador.dart';
import 'screens/reporte_incidencia.dart';
import 'screens/gestion_usuarios.dart';
import 'screens/historial_auditoria.dart';

const Color primaryColor = Color(0xFF2E6FFC);
const Color cardBackgroundColor = Color(0xFFE3F2FD);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
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
      theme: AppTheme.light(),
      builder: (context, child) {
        final scale = context.watch<FontSizeProvider>().scaleFactor;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },

      // Mantenemos la lógica del Splash como entrada
      home: const SplashScreen(),

      routes: {
        // Rutas de Autenticación y Sistema
        '/bienvenido': (context) => const Bienvenido(),
        '/menu_vistas': (context) => const MenuVistas(),
        '/iniciar_sesion': (context) => const IniciarSesion(),
        '/olvide_contrasena': (context) => const OlvideContrasena(),
        '/nueva_contrasena': (context) => const NuevaContrasena(),
        '/confirmar-correo': (context) => const ConfirmarCorreoScreen(), 
        //'/menu_vistas': (context) => const MenuVistas(),
        '/registro': (context) => const Registro(),

        // Módulo Pasajero
        '/registro_pasajero': (context) => const RegistroPasajero(),
        '/principal_pasajero': (context) => const PrincipalPasajero(),
        '/completar_perfil_pasajero': (context) => const CompletarPerfilPasajero(),
        '/perfil_pasajero': (context) => const PerfilPasajero(),
        '/agendar_viaje': (context) => const AgendarViaje(), //FALTA LA IA
        '/agendar_varios_destinos': (context) => const AgendarVariosDestinos(), //FALTA LA IA
        '/pago_tarjeta': (context) => const PagoTarjetaScreen(), //FALTA STRIPE
        '/registro_tarjeta': (context) => const RegistroTarjetaScreen(),
        '/registro_acompanante': (context) => const RegistrarAcompanante(),
        '/historial_viajes_pasajero': (context) => const HistorialViajesPasajero(),
        '/reporte_incidencia_pasajero': (context) => const ReporteIncidenciaPasajero(), // ESTA ME QUEDA POR CONECTAR
        '/viaje_confirmado': (context) => const ViajeConfirmado(), // ESTA ME QUEDA POR CONECTAR
        '/estimacion_costo': (context) => const EstimacionViaje(), // ESTA ME QUEDA POR CONECTAR
        '/metodos_pago_lista': (context) => const MetodosPagoVista(),
        '/terminos_condiciones': (context) => const TerminosVista(),
        '/aviso_privacidad': (context) => const PrivacidadVista(),

        // Módulo Conductor
        '/registro_conductor': (context) => const RegistroConductor(),
        '/continue_driver_register_screen': (context) => const ContinuarRegistroConductor(),
        '/principal_conductor': (context) => const PrincipalConductor(),
        '/mi_perfil_conductor': (context) => const MiPerfilConductor(),
        '/viaje_actual': (context) => const ViajeActualMapa(),
        '/solicitud_viaje': (context) => const SolicitudViaje(),
        '/viajes_conductor': (context) => const SolicitudesViajesConductor(),
        '/historial_viajes_conductor': (context) => const HistorialViajesConductor(),
        '/completar_perfil_conductor': (context) => const CompletarPerfilConductor(),
        '/reporte_incidencia_conductor': (context) => const ReporteIncidenciaConductor(), //ESTO ES NUEVO
        '/metricas_conductor': (context) => const MetricasConductor(),

        // Módulo Administrativo
        '/principal_administrador': (context) => const PrincipalAdministrador(),
        '/reporte_incidencia': (context) => const ReporteIncidencia(),
        '/gestion_usuarios': (context) => const GestionUsuarios(),
        '/historial_auditorias': (context) => const HistorialAuditoria(),
      },
    );
  }
}