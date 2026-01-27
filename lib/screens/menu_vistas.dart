import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuVistas extends StatelessWidget {
  const MenuVistas({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de rutas para generar el menú automáticamente
    final List<Map<String, String>> misRutas = [
      {'nombre': 'Bienvenida', 'ruta': '/'},
      {'nombre': 'Iniciar Sesión', 'ruta': '/iniciar_sesion'},
      {'nombre': 'Olvidé Contraseña', 'ruta': '/olvide_contrasena'},
      {'nombre': 'Selección de Registro', 'ruta': '/registro'},
      {'nombre': 'Registro Pasajero', 'ruta': '/registro_pasajero'},
      {'nombre': 'Código Verificación', 'ruta': '/codigo_verificacion'},
      {'nombre': 'Completar Perfil Pasajero', 'ruta': '/completar_perfil_pasajero'},
      {'nombre': 'Principal Pasajero', 'ruta': '/principal_pasajero'},
      {'nombre': 'Agendar Viaje', 'ruta': '/agendar_viaje'},
      {'nombre': 'Registro Conductor', 'ruta': '/registro_conductor'},
      {'nombre': 'Continuar Registro Conductor', 'ruta': '/continue_driver_register_screen'},
      {'nombre': 'Mi Perfil Pasajero', 'ruta': '/mi_perfil_pasajero'},
      {'nombre': 'Agendar Varios Destinos', 'ruta': '/agendar_varios_destinos'},
      {'nombre': 'Pago con Tarjeta', 'ruta': '/pago_tarjeta'},
      {'nombre': 'Registro de Tarjeta', 'ruta': '/registro_tarjeta'},
      {'nombre': 'Registro Acompañante', 'ruta': '/registro_acompanante'},
      {'nombre': 'Historial de Viajes Pasajero', 'ruta': '/historial_viajes_pasajero'},
      {'nombre': 'Viaje Confirmado', 'ruta': '/viaje_confirmado'},
      {'nombre': 'Estimación de Costo', 'ruta': '/estimacion_costo'},
      {'nombre': 'Principal Conductor', 'ruta': '/principal_conductor'},
      {'nombre': 'Mi Perfil Conductor', 'ruta': '/mi_perfil_conductor'},
      {'nombre': 'Viaje Actual', 'ruta': '/viaje_actual'},
      {'nombre': 'Solicitud de Viaje', 'ruta': '/solicitud_viaje'},
      {'nombre': 'Historial de Viajes Conductor', 'ruta': '/historial_viajes_conductor'},
      {'nombre': 'Completar Perfil Conductor', 'ruta': '/completar_perfil_conductor'},
      {'nombre': 'Agregar INE', 'ruta': '/agregar_ine'},
      {'nombre': 'Agregar Licencia', 'ruta': '/agregar_licencia'},
      {'nombre': 'Nueva Contraseña', 'ruta': '/nueva_contrasena'},
      {'nombre': 'Reporte de Incidencias', 'ruta': '/reporte_incidencia'},
      {'nombre': 'Gestión de Usuarios', 'ruta': '/gestion_usuarios'},
      {'nombre': 'Historial de Auditorías', 'ruta': '/historial_auditorias'},
    ];


    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text('MoveCare - Índice', 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1559B2),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: misRutas.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFB3D4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.ads_click, color: Color(0xFF1559B2)),
              ),
              title: Text(
                misRutas[index]['nombre']!,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: Text(misRutas[index]['ruta']!, 
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => Navigator.pushNamed(context, misRutas[index]['ruta']!),
            ),
          );
        },
      ),
    );
  }
}