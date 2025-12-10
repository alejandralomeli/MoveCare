# movecare
MoveCare 

Introducción
MoveCare es un proyecto inicial de Flutter centrado en la creación de interfaces de usuario modernas y funcionales. Esta primera fase presenta una pantalla de inicio de sesión (Login Screen) con un diseño centrado en la temática de la movilidad y el transporte, utilizando un fondo visualmente impactante y un diseño de tarjeta limpio.

Este repositorio sirve como punto de partida para una aplicación más grande orientada a la gestión o el seguimiento de vehículos/rutas.

Características de la Interfaz de Usuario (UI)
La pantalla de inicio de sesión incluye los siguientes elementos:
Fondo Temático: Una imagen de carretera que se desvanece suavemente para destacar la tarjeta de inicio de sesión.
Diseño Responsivo: El Login Card central se adapta bien tanto a dispositivos móviles como a pantallas más grandes.
Identidad Visual: Un logo distintivo (el ícono del carro) y uso de paleta de colores (primaryColor y cardBackgroundColor).

Campos de Formulario:
Campo de Correo Electrónico.
Campo de Contraseña (oculta el texto).

Métodos de Acceso:
Botón principal de "Ingresar".
Botón de "Iniciar Sesión con Google" 
Enlaces de Utilidad: "Regístrate" y "Olvidé mi contraseña".

Estructura del Proyecto
movecare/
├── android/
├── assets/
│   ├── app_logo.png       (Ícono del carro)
│   ├── fondo_ruta.jpg     (Fondo de la carretera)
│   └── icono_google.png   (Ícono para el Social Login)
├── lib/
│   ├── main.dart          (Punto de entrada)
│   └── screens/
│       └── login_screen.dart (Implementación del diseño de la UI)
└── pubspec.yaml           (Registro de dependencias y assets)


Tecnología Utilizada
Framework: Flutter
Lenguaje: Dart 3.x
Plataformas de Destino: iOS, Android, Web (enfocado en Mobile-first).
Assets: Imágenes personalizadas alojadas en la carpeta assets/.

Guía de Instalación y Ejecución
Para ejecutar este proyecto localmente, asegúrate de tener instalado el SDK de Flutter (versión 3.9.2 o superior).

1. Clonar el Repositorio
git clone <movecare>
cd movecare

2. Obtener Dependencias
Instala los paquetes necesarios y genera los archivos de assets:
flutter pub get

3. Ejecutar la Aplicación
Selecciona un emulador o dispositivo conectado y ejecuta:
flutter run

Recursos de Flutter
Estos son algunos recursos útiles para comenzar si este es tu primer proyecto Flutter:
Lab: Write your first Flutter app
Cookbook: Useful Flutter samples
Para obtener ayuda para comenzar con el desarrollo de Flutter, consulta la documentación en línea, que ofrece tutoriales, ejemplos, orientación sobre desarrollo móvil y una referencia completa de la API.