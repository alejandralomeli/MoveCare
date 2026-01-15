import 'package:flutter/material.dart';
import 'screens/welcomescreen.dart';
import 'package:movecare/screens/login.dart'; 
import 'screens/register_screen.dart';
import 'screens/continue_driver_register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/driver_register_screen.dart';
import 'screens/passenger_register_screen.dart';
import 'screens/verification_code_screen.dart';
import 'screens/home_passenger_screen.dart';

// Colores constantes compartidos con la pantalla de login
const Color primaryColor = Color(0xFF2E6FFC);
const Color cardBackgroundColor = Color(0xFFE3F2FD); 

void main() {
  runApp(const MyApp());
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
      ),
      initialRoute: '/',
     routes: {
        '/': (context) => const WelcomeScreen(), //No necesita conectar
        '/login': (context) => const LoginScreen(), //Conectado
        '/forgot_password_screen': (context) => const ForgotPasswordScreen(),
        
        // Registro Principal (Selección de rol)
        '/register_screen': (context) => const RegisterScreen(), //No necesita conectar
        
        // Flujo del Conductor
        '/driver_register_screen': (context) => const DriverRegisterScreen(), //Conectado
        '/continue_driver_register_screen': (context) => const ContinueDriverRegisterScreen(), //Conectado
        
        // Flujo del Pasajero
        '/passenger_register_screen': (context) => const PassengerRegisterScreen(), //Conectado
        '/home_passenger_screen': (context) => const HomePassengerScreen(),
        '/verification_code': (context) => const VerificationCodeScreen(),
      },
    );
  }
}