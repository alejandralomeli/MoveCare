import 'package:flutter/material.dart';
import 'package:movecare/screens/login.dart'; 

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
      // Quita el banner de "DEBUG"
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // Define el esquema de color principal para toda la app
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      // La pantalla de inicio es la LoginScreen que creamos en el otro archivo
      home: const LoginScreen(),
    );
  }
}