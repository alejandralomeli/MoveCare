import 'dart:io';
import 'dart:convert'; // Necesario para base64
import 'dart:typed_data'; // Necesario para Uint8List
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Añadido para context.read/watch

// Importaciones de tu proyecto
import '../app_theme.dart';
import 'widgets/mic_button.dart';
// Asumo que tienes estos imports en tu archivo original para los servicios
import '../services/auth/auth_service.dart';
import '../services/auth/validacion_service.dart';
import '../providers/user_provider.dart';

class CompletarPerfilPasajero extends StatefulWidget {
  const CompletarPerfilPasajero({super.key});

  @override
  State<CompletarPerfilPasajero> createState() =>
      _CompletarPerfilPasajeroState();
}

class _CompletarPerfilPasajeroState extends State<CompletarPerfilPasajero>
    with SingleTickerProviderStateMixin {
  // --- ESTADO LÓGICO Y VISUAL ---
  final Set<String> _selectedNeeds = {};
  bool _isListening = false;
  bool _isInit = false;

  File? _ineAnverso;
  File? _ineReverso;
  final ImagePicker _picker = ImagePicker();

  bool _isSavingIne = false;
  bool _isSavingProfile = false;

  // Variables para la lógica de Provider/Guardado
  Uint8List? _fotoPerfilBytes;
  Uint8List? _ineAnversoBytes;
  Uint8List? _ineReversoBytes;
  late AnimationController _pulseController;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  DateTime? _fechaNacimiento;

  // --- CICLO DE VIDA ---
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
        _nombreController.text = user.nombre;
        _telefonoController.text = user.telefono;
        _direccionController.text = user.direccion;

        if (user.fechaNacimiento.isNotEmpty) {
          _fechaNacimiento = DateTime.tryParse(user.fechaNacimiento);
        }

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

        if (user.discapacidad.isNotEmpty) {
          final listaDiscapacidades = user.discapacidad
              .split(',')
              .map((e) => e.trim());
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

  // --- LÓGICA DE FUNCIONES ---
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
              primary: AppColors.primary,
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

  Future<void> _guardarPerfil() async {
    setState(() => _isSavingProfile = true);

    try {
      String? base64Foto;
      if (_fotoPerfilBytes != null) {
        base64Foto = base64Encode(_fotoPerfilBytes!);
      }

      String? fechaNacStr;
      if (_fechaNacimiento != null) {
        fechaNacStr =
            "${_fechaNacimiento!.year}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}";
      }

      const Map<String, String> _discapacidadKeys = {
        'Tercera Edad': 'adulto_mayor',
        'Movilidad reducida': 'motriz',
        'Disc. auditiva': 'auditiva',
        'Disc. visual': 'visual',
        'Obesidad': 'obesidad',
      };

      String? discapacidadesStr;
      if (_selectedNeeds.isNotEmpty) {
        discapacidadesStr = _selectedNeeds
            .map((n) => _discapacidadKeys[n] ?? n)
            .join(', ');
      } else {
        discapacidadesStr = "";
      }

      // Llama a tu servicio
      final res = await AuthService.updateProfile(
        nombreCompleto: _nombreController.text.isNotEmpty
            ? _nombreController.text
            : null,
        telefono: _telefonoController.text.isNotEmpty
            ? _telefonoController.text
            : null,
        direccion: _direccionController.text.isNotEmpty
            ? _direccionController.text
            : null,
        fechaNacimiento: fechaNacStr,
        fotoPerfil: base64Foto,
        discapacidad: discapacidadesStr,
      );

      if (res['ok'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['mensaje'] ?? 'Perfil guardado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error'] ?? 'Error al guardar el perfil'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
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
          backgroundColor: AppColors.error,
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingIne = false);
      }
    }
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (type == 'anverso') {
          _ineAnverso = File(image.path);
          _ineAnversoBytes = bytes;
        } else if (type == 'reverso') {
          _ineReverso = File(image.path);
          _ineReversoBytes = bytes;
        } else if (type == 'perfil') {
          _fotoPerfilBytes = bytes;
        }
      });
    }
  }

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    // 🔥 Variable de estado leída desde tu UserProvider
    final user = context.watch<UserProvider>().user;
    final bool isActivo = user?.activo ?? false;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              isVoiceActive: _isListening,
              onVoiceTap: _toggleListening,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),

                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActivo ? Colors.green : AppColors.error,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActivo
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          color: AppColors.white,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          isActivo ? 'Perfil verificado' : 'Completar perfil',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- FORMULARIO DE DATOS PERSONALES RESTAURADO ---

                  // Foto de perfil circular
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage('perfil'),
                      child: Stack(
                        children: [
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                              image: _fotoPerfilBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_fotoPerfilBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _fotoPerfilBytes == null
                                ? const Icon(
                                    Icons.person_outline,
                                    size: 45,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Datos personales',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Nombre completo',
                    controller: _nombreController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Teléfono',
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Dirección',
                    controller: _direccionController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildDateField(),

                  const SizedBox(height: 32),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 28),

                  // --- FIN FORMULARIO DE DATOS PERSONALES ---

                  // 🔥 CONDICIONAL DE LA INE (Solo se muestra si el usuario no es activo)
                  if (!isActivo) ...[
                    // Sección INE
                    Row(
                      children: [
                        Text(
                          'Foto de ',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'INE',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sube una foto clara del anverso y reverso',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDocCard(
                            'Anverso',
                            _ineAnverso,
                            'assets/ine_anverso.png',
                            'anverso',
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildDocCard(
                            'Reverso',
                            _ineReverso,
                            'assets/ine_reverso.png',
                            'reverso',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 28),
                  ],

                  // Sección necesidades
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      children: const [
                        TextSpan(text: '¿Presenta alguna '),
                        TextSpan(
                          text: 'necesidad especial',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: '?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Selecciona '),
                        TextSpan(
                          text: 'todas',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' las que apliquen a tu caso'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNeedsGrid(),

                  const SizedBox(height: 36),

                  // Botón acompañante
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      // 👇 Aquí agregamos la navegación a la ruta
                      onPressed: () {
                        Navigator.pushNamed(context, '/registro_acompanante');
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text(
                        'Registrar un acompañante',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSavingProfile || _isSavingIne)
                          ? null
                          : () async {
                              // Se ejecutan ambas lógicas al presionar el botón guardar
                              if (_ineAnverso != null && _ineReverso != null) {
                                await _guardarINE();
                              }
                              await _guardarPerfil();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: (_isSavingProfile || _isSavingIne)
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Guardar',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: const PassengerBottomNav(selectedIndex: 3), // Descomenta si usas tu nav
    );
  }

  // --- WIDGETS AUXILIARES PARA EL FORMULARIO RESTAURADO ---
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 22)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _seleccionarFecha(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              _fechaNacimiento != null
                  ? "${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}"
                  : "Fecha de nacimiento",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _fechaNacimiento != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ORIGINALES ---
  Widget _buildDocCard(
    String label,
    File? file,
    String placeholder,
    String type,
  ) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: file != null ? AppColors.primary : AppColors.border,
                width: file != null ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: file != null
                  ? Image.file(file, fit: BoxFit.cover)
                  : Image.asset(
                      placeholder,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsGrid() {
    final needs = [
      {'label': 'Tercera Edad', 'icon': 'assets/tercera_edad.png'},
      {'label': 'Movilidad reducida', 'icon': 'assets/silla_ruedas.png'},
      {'label': 'Disc. auditiva', 'icon': 'assets/auditiva.png'},
      {'label': 'Obesidad', 'icon': 'assets/obesidad.png'},
      {'label': 'Disc. visual', 'icon': 'assets/visual.png'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 14,
      children: needs
          .map((n) => _buildNeedItem(n['label']!, n['icon']!))
          .toList(),
    );
  }

  Widget _buildNeedItem(String label, String iconPath) {
    final isSelected = _selectedNeeds.contains(label);
    final itemWidth = (MediaQuery.of(context).size.width - 44 - 12 * 2) / 3;

    return GestureDetector(
      onTap: () => setState(
        () => isSelected
            ? _selectedNeeds.remove(label)
            : _selectedNeeds.add(label),
      ),
      child: SizedBox(
        width: itemWidth,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.07)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.accessible,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;

  _HeaderDelegate({required this.isVoiceActive, required this.onVoiceTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Center(
            child: Text(
              'Completar Perfil',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 20,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          right: 15,
          bottom: -20,
          child: MicButton(
            isActive: isVoiceActive,
            onTap: onVoiceTap,
            size: 42,
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}
