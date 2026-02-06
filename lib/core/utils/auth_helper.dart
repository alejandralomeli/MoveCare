import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';
import '../../screens/iniciar_sesion.dart'; // Ajusta la importación según tu estructura

class AuthHelper {
  
  /// Esta función se encarga de cerrar sesión y mandar al usuario al Login
  static Future<void> expulsarUsuario(BuildContext context) async {
    // 1. Borrar datos seguros
    await SecureStorage.deleteAll();

    // 2. Verificar que la pantalla siga existiendo
    if (!context.mounted) return;

    // 3. Navegar al Login borrando el historial
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IniciarSesion()),
      (route) => false,
    );
  }

  /// Esta función analiza el error. Si es 401, expulsa. Si no, muestra alerta.
  static void manejarError(BuildContext context, Object error) {
    final mensaje = error.toString();

    // Si el error dice "TOKEN_INVALIDO" o "401", adiós sesión.
    if (mensaje.contains('TOKEN_INVALIDO') || mensaje.contains('401')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tu sesión ha expirado. Ingresa nuevamente."),
          backgroundColor: Colors.red,
        ),
      );
      expulsarUsuario(context);
    } else {
      // Si es otro error (internet, datos mal, etc), solo avisa.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $mensaje")),
      );
    }
  }
}