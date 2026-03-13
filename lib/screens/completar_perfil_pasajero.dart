import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth/validacion_service.dart';
import '../services/auth/auth_service.dart'; // 🔥 IMPORTAMOS EL AUTH SERVICE
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CompletarPerfilPasajero extends StatefulWidget {
  const CompletarPerfilPasajero({super.key});

  @override
  State<CompletarPerfilPasajero> createState() =>
      _CompletarPerfilPasajeroState();
}

class _CompletarPerfilPasajeroState extends State<CompletarPerfilPasajero>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  static const Color statusRed = Color(0xFFEF5350);
  static const Color statusGreen = Color(0xFF4CAF50);

  final Set<String> _selectedNeeds = {};
  int _selectedIndex = 3;
  bool _isListening = false;
  bool _isInit = false;

  late AnimationController _pulseController;
  
  Uint8List? _ineAnversoBytes;
  Uint8List? _ineReversoBytes;
  Uint8List? _fotoPerfilBytes; 
  final ImagePicker _picker = ImagePicker();

  bool _isSavingIne = false;
  bool _isSavingProfile = false; // 🔥 NUEVO: Estado para el guardado de perfil

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
          lowerBound: 1.0,
          upperBound: 1.15,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed && _isListening) {
            _pulseController.forward();
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        // 1. Asignamos los textos directos
        _nombreController.text = user.nombre;
        _telefonoController.text = user.telefono; 
        _direccionController.text = user.direccion;

        // 2. Fecha de Nacimiento
        if (user.fechaNacimiento.isNotEmpty) {
          _fechaNacimiento = DateTime.tryParse(user.fechaNacimiento);
        }

        // 3. Foto de Perfil
        if (user.fotoPerfil.isNotEmpty) {
          try {
            String base64String = user.fotoPerfil;
            if (base64String.contains(',')) {
              base64String = base64String.split(',').last;
            }
            _fotoPerfilBytes = base64Decode(base64String);
          } catch (e) {
            debugPrint("Error decodificando foto de perfil: $e");
          }
        }

        // 4. Discapacidad (El backend envía: "Tercera Edad, Movilidad reducida")
        if (user.discapacidad.isNotEmpty) {
          final listaDiscapacidades = user.discapacidad.split(',').map((e) => e.trim());
          // 🔥 Esto asegura que los botones se pinten seleccionados al entrar
          _selectedNeeds.addAll(listaDiscapacidades);
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (seleccion != null && seleccion != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = seleccion;
      });
    }
  }

  // 🔥 NUEVA FUNCIÓN: Guardar datos personales, foto y discapacidades
  Future<void> _guardarPerfil() async {
    setState(() => _isSavingProfile = true);

    try {
      // 1. Formatear la foto a base64
      String? base64Foto;
      if (_fotoPerfilBytes != null) {
        base64Foto = base64Encode(_fotoPerfilBytes!);
      }

      // 2. Formatear la fecha (YYYY-MM-DD)
      String? fechaNacStr;
      if (_fechaNacimiento != null) {
        fechaNacStr = "${_fechaNacimiento!.year}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}";
      }

      // 3. Unir las discapacidades separadas por comas
      String? discapacidadesStr;
      if (_selectedNeeds.isNotEmpty) {
        discapacidadesStr = _selectedNeeds.join(", ");
      } else {
        discapacidadesStr = ""; // Opcional: enviar vacío si las desmarcó todas
      }

      // 4. Enviar al backend
      final res = await AuthService.updateProfile(
        nombreCompleto: _nombreController.text.isNotEmpty ? _nombreController.text : null,
        telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
        direccion: _direccionController.text.isNotEmpty ? _direccionController.text : null,
        fechaNacimiento: fechaNacStr,
        fotoPerfil: base64Foto,
        discapacidad: discapacidadesStr,
      );

      if (res['ok'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['mensaje'] ?? 'Perfil guardado con éxito'),
            backgroundColor: statusGreen,
          ),
        );
        // Opcional: Aquí podrías volver a llamar a la función que descarga 
        // los datos del usuario para actualizar el Provider en tiempo real.
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error'] ?? 'Error al guardar el perfil'),
            backgroundColor: statusRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: statusRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _guardarINE() async {
    if (_ineAnversoBytes == null || _ineReversoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona ambas fotos de la INE'),
          backgroundColor: statusRed,
        ),
      );
      return;
    }

    setState(() => _isSavingIne = true);

    try {
      final base64Anverso = base64Encode(_ineAnversoBytes!);
      final base64Reverso = base64Encode(_ineReversoBytes!);

      final exito = await ValidacionService.enviarValidacionDocumentos(
        ineFrenteBase64: base64Anverso,
        ineReversoBase64: base64Reverso,
      );

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documentos enviados a revisión correctamente'),
            backgroundColor: statusGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: statusRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingIne = false);
      }
    }
  }

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mBold(
    BuildContext context, {
    Color color = Colors.black,
    double size = 11,
  }) => GoogleFonts.montserrat(
    color: color,
    fontSize: sp(size, context),
    fontWeight: FontWeight.bold,
  );

  TextStyle mExtrabold(
    BuildContext context, {
    Color color = Colors.black,
    double size = 14,
  }) => GoogleFonts.montserrat(
    color: color,
    fontSize: sp(size, context),
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final user = context.watch<UserProvider>().user;
    final String nombreUsuario = user?.nombre ?? "Usuario";
    final bool isActivo = user?.activo ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, nombreUsuario, isActivo),
                const SizedBox(height: 110),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusButton(context, isActivo),
                      const SizedBox(height: 25),

                      _buildDatosPersonalesSection(context),
                      const SizedBox(height: 25),

                      Text(
                        '¿Presenta alguna necesidad especial?',
                        style: mExtrabold(context, size: 17),
                      ),
                      Text(
                        'Seleccione las casillas que se ajusten a su necesidad',
                        style: mBold(context, color: Colors.red, size: 10),
                      ),
                      const SizedBox(height: 25),
                      _buildNeedsGrid(context),
                      const SizedBox(height: 35),

                      // 🔥 BOTÓN GUARDAR PERFIL
                      Center(
                        child: _isSavingProfile
                            ? const CircularProgressIndicator(color: primaryBlue)
                            : ElevatedButton(
                                onPressed: _guardarPerfil,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Guardar Cambios de Perfil',
                                  style: mBold(
                                    context,
                                    color: Colors.white,
                                    size: 14, // Lo hice un poco más grande
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 35),

                      if (!isActivo) ...[
                        const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 25),
                        Text(
                          'Foto de INE',
                          style: mExtrabold(context, size: 18),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDocCard(
                                context,
                                'Anverso',
                                _ineAnversoBytes,
                                'assets/ine_anverso.png',
                                'anverso',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildDocCard(
                                context,
                                'Reverso',
                                _ineReversoBytes,
                                'assets/ine_reverso.png',
                                'reverso',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: _isSavingIne
                              ? const CircularProgressIndicator(
                                  color: primaryBlue,
                                )
                              : ElevatedButton(
                                  onPressed: _guardarINE,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 35,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Enviar INE a revisión',
                                    style: mBold(
                                      context,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 35),
                      ],

                      Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Cambié a blanco para que no compita visualmente con Guardar
                            side: const BorderSide(color: primaryBlue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Registrar un acompañante',
                            style: mBold(
                              context,
                              color: primaryBlue, // Texto azul
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 87.5,
            right: 20,
            child: GestureDetector(
              onTap: _toggleListening,
              child: ScaleTransition(
                scale: _pulseController,
                child: Image.asset(
                  _isListening
                      ? 'assets/escuchando.png'
                      : 'assets/controlvoz.png',
                  width: 65,
                  height: 65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosPersonalesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datos personales', style: mExtrabold(context, size: 18)),
        const SizedBox(height: 15),
        _buildTextField(
          context: context,
          label: 'Nombre completo',
          controller: _nombreController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context: context,
          label: 'Teléfono',
          controller: _telefonoController,
          icon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          context: context,
          label: 'Dirección',
          controller: _direccionController,
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 15),
        
        GestureDetector(
          onTap: () => _seleccionarFecha(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accentBlue.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: primaryBlue, size: 20),
                const SizedBox(width: 10),
                Text(
                  _fechaNacimiento == null
                      ? 'Fecha de nacimiento'
                      : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}',
                  style: GoogleFonts.montserrat(
                    color: _fechaNacimiento == null ? Colors.grey : Colors.black,
                    fontSize: 14,
                    fontWeight: _fechaNacimiento == null ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentBlue.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: primaryBlue, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String nombreUsuario,
    bool isActivo,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          color: lightBlueBg,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 35),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryBlue,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: GestureDetector(
            onTap: () => _pickImage('perfil'),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: _fotoPerfilBytes != null
                      ? MemoryImage(_fotoPerfilBytes!) as ImageProvider
                      : const AssetImage('assets/pasajero.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _nombreController.text.isNotEmpty ? _nombreController.text : nombreUsuario,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    '5.00',
                    style: mBold(context, color: primaryBlue, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (isActivo)
                _buildBadge(
                  "Verificado",
                  Icons.check_circle_outline,
                  statusGreen,
                )
              else
                _buildBadge(
                  "Pendiente de verificación",
                  Icons.error_outline,
                  statusRed,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(text, style: mBold(context, color: Colors.white, size: 10)),
        ],
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, bool isActivo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActivo ? statusGreen : statusRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActivo ? Icons.check_circle : Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isActivo ? 'Perfil completo' : 'Completar perfil',
            style: mBold(context, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(
    BuildContext context,
    String label,
    Uint8List? imageBytes,
    String placeholder,
    String type,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(type),
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: accentBlue.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : Image.asset(placeholder, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: mBold(context, color: primaryBlue, size: 14)),
      ],
    );
  }

  Widget _buildNeedsGrid(BuildContext context) {
    final needs = [
      {'label': 'Tercera Edad', 'icon': 'assets/tercera_edad.png'},
      {'label': 'Movilidad reducida', 'icon': 'assets/silla_ruedas.png'},
      {'label': 'Discapacidad auditiva', 'icon': 'assets/auditiva.png'},
      {'label': 'Obesidad', 'icon': 'assets/obesidad.png'},
      {'label': 'Discapacidad visual', 'icon': 'assets/visual.png'},
    ];

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 15,
        runSpacing: 20,
        children: needs
            .map((n) => _buildNeedItem(context, n['label']!, n['icon']!))
            .toList(),
      ),
    );
  }

  Widget _buildNeedItem(BuildContext context, String label, String iconPath) {
    // 🔥 Aquí funciona la magia: al cargar desde provider, verifica si el label existe en el Set.
    bool isSelected = _selectedNeeds.contains(label);
    
    return GestureDetector(
      onTap: () => setState(
        () => isSelected
            ? _selectedNeeds.remove(label)
            : _selectedNeeds.add(label),
      ),
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              height: 90,
              width: 90,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? primaryBlue : accentBlue,
                  width: isSelected ? 3 : 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(iconPath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label.replaceAll(' ', '\n'), 
                textAlign: TextAlign.center,
                style: mBold(context, color: Colors.white, size: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (type == 'anverso') {
          _ineAnversoBytes = bytes;
        } else if (type == 'reverso') {
          _ineReversoBytes = bytes;
        } else if (type == 'perfil') {
          _fotoPerfilBytes = bytes;
        }
      });
    }
  }
}