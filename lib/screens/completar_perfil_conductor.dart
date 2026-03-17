import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

// Estética y componentes del repositorio
import '../app_theme.dart';

// Servicios y lógica de usuario
import '../providers/user_provider.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/validacion_service.dart';

class CompletarPerfilConductor extends StatefulWidget {
  const CompletarPerfilConductor({super.key});

  @override
  State<CompletarPerfilConductor> createState() => _CompletarPerfilConductorState();
}

class _CompletarPerfilConductorState extends State<CompletarPerfilConductor> with TickerProviderStateMixin {
  // Lógica de estado
  bool _isVoiceActive = false;
  bool _isLoading = false;
  bool _isInit = false;

  late AnimationController _pulseController;

  // Controladores de texto
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _fechaNacCtrl = TextEditingController();

  // Almacenamiento de documentos en Base64
  String? fotoPerfilB64;
  String? ineFrenteB64;
  String? ineReversoB64;
  String? licenciaFrenteB64;
  String? licenciaReversoB64;
  String? polizaPdfB64;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _pulseController.reverse();
        if (status == AnimationStatus.dismissed && _isVoiceActive) _pulseController.forward();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        _nombreCtrl.text = user.nombre ?? '';
        _correoCtrl.text = user.correo ?? '';
        _telefonoCtrl.text = user.telefono ?? '';
        _direccionCtrl.text = user.direccion ?? '';
        if (user.fechaNacimiento != null) _fechaNacCtrl.text = user.fechaNacimiento!;
        
        if (user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty) {
          String base64String = user.fotoPerfil!;
          if (base64String.contains(',')) base64String = base64String.split(',').last;
          fotoPerfilB64 = base64String;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaNacCtrl.dispose();
    super.dispose();
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceActive = !_isVoiceActive;
      if (_isVoiceActive) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  // --- MÉTODOS DE SELECCIÓN DE ARCHIVOS ---

  Future<void> _cambiarFotoPerfil() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => fotoPerfilB64 = base64Encode(bytes));
    }
  }

  Future<void> _pickImage(String tipoDocumento) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        if (tipoDocumento == 'ineFrente') ineFrenteB64 = base64String;
        if (tipoDocumento == 'ineReverso') ineReversoB64 = base64String;
        if (tipoDocumento == 'licenciaFrente') licenciaFrenteB64 = base64String;
        if (tipoDocumento == 'licenciaReverso') licenciaReversoB64 = base64String;
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      if (result.files.single.size > 3000000) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El PDF es muy pesado. Máximo 3MB.')));
        return;
      }
      setState(() => polizaPdfB64 = base64Encode(result.files.single.bytes!));
    }
  }

  // --- LLAMADAS AL BACKEND ---

  Future<void> _actualizarPerfil() async {
    setState(() => _isLoading = true);
    try {
      final res = await AuthService.updateProfile(
        nombreCompleto: _nombreCtrl.text.isNotEmpty ? _nombreCtrl.text : null,
        telefono: _telefonoCtrl.text.isNotEmpty ? _telefonoCtrl.text : null,
        direccion: _direccionCtrl.text.isNotEmpty ? _direccionCtrl.text : null,
        fechaNacimiento: _fechaNacCtrl.text.isNotEmpty ? _fechaNacCtrl.text : null,
        fotoPerfil: fotoPerfilB64,
      );
      if (res['ok'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado con éxito'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarDocumentos() async {
    if (ineFrenteB64 == null || ineReversoB64 == null || licenciaFrenteB64 == null || licenciaReversoB64 == null || polizaPdfB64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, sube todos los documentos'), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final exito = await ValidacionService.enviarValidacionDocumentos(
        ineFrenteBase64: ineFrenteB64!,
        ineReversoBase64: ineReversoB64!,
        licenciaFrenteBase64: licenciaFrenteB64,
        licenciaReversoBase64: licenciaReversoB64,
        polizaBase64: polizaPdfB64,
      );
      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documentos enviados a revisión'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final bool isActivo = user?.activo ?? false;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  isVoiceActive: _isVoiceActive,
                  onVoiceTap: _toggleVoice,
                  fotoPerfilBase64: fotoPerfilB64,
                  onPhotoTap: _cambiarFotoPerfil,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),

                      if (!isActivo) _buildErrorBadge(),

                      const SizedBox(height: 28),

                      // INFORMACIÓN PERSONAL
                      _buildSectionTitle('Información ', 'Personal'),
                      const SizedBox(height: 18),
                      _buildTextField('Nombre Completo', _nombreCtrl),
                      _buildTextField('Correo Electrónico', _correoCtrl, readOnly: true),
                      _buildTextField('Teléfono', _telefonoCtrl, isPhone: true),
                      _buildTextField('Dirección', _direccionCtrl),
                      _buildTextField('Fecha de Nacimiento (YYYY-MM-DD)', _fechaNacCtrl),
                      
                      Center(
                        child: TextButton(
                          onPressed: _actualizarPerfil,
                          child: Text('Actualizar Datos Personales', 
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: AppColors.border, height: 1),
                      ),

                      // SECCIÓN INE
                      _buildSectionTitle('Foto de ', 'INE'),
                      _buildSubtitle('Sube una foto clara del anverso y reverso'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildDocCard('Anverso', 'assets/ine_anverso.png', ineFrenteB64 != null, () => _pickImage('ineFrente'))),
                          const SizedBox(width: 15),
                          Expanded(child: _buildDocCard('Reverso', 'assets/ine_reverso.png', ineReversoB64 != null, () => _pickImage('ineReverso'))),
                        ],
                      ),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 24),

                      // SECCIÓN LICENCIA
                      _buildSectionTitle('Licencia de ', 'Conducir'),
                      _buildSubtitle('Sube una foto clara del anverso y reverso'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildDocCard('Anverso', 'assets/ine_anverso.png', licenciaFrenteB64 != null, () => _pickImage('licenciaFrente'))),
                          const SizedBox(width: 15),
                          Expanded(child: _buildDocCard('Reverso', 'assets/ine_reverso.png', licenciaReversoB64 != null, () => _pickImage('licenciaReverso'))),
                        ],
                      ),

                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 24),

                      // SECCIÓN PÓLIZA
                      _buildSectionTitle('Póliza de ', 'Seguro'),
                      _buildSubtitle('Adjunta el PDF de tu póliza vigente'),
                      const SizedBox(height: 14),
                      _buildPdfPicker(),

                      const SizedBox(height: 36),

                      // ACCIONES FINALES
                      _buildOutlinedButton('Datos de mi Vehículo', Icons.directions_car_outlined, () {
                        Navigator.pushNamed(context, 'Datos_Vehiculo');
                      }),

                      const SizedBox(height: 14),

                      _buildPrimaryButton('Guardar y Enviar a Revisión', _enviarDocumentos),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 4),
    );
  }

  // --- WIDGETS DE ESTILO REPOSITORIO ---

  Widget _buildErrorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.white, size: 17),
          const SizedBox(width: 7),
          Text('Completar perfil', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String normal, String bold) {
    return Row(
      children: [
        Text(normal, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text(bold, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPhone = false, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: GoogleFonts.montserrat(fontSize: 14, color: readOnly ? AppColors.textSecondary : AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          filled: readOnly,
          fillColor: readOnly ? AppColors.border.withValues(alpha: 0.2) : AppColors.white,
          labelStyle: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildDocCard(String label, String placeholder, bool isLoaded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isLoaded ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isLoaded ? AppColors.primary : AppColors.border, width: isLoaded ? 1.5 : 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!isLoaded) Padding(padding: const EdgeInsets.all(8), child: Image.asset(placeholder, fit: BoxFit.contain, opacity: const AlwaysStoppedAnimation(.5))),
                  if (isLoaded) const Icon(Icons.check_circle, color: AppColors.primary, size: 40),
                  if (!isLoaded) const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildPdfPicker() {
    return GestureDetector(
      onTap: _pickPdf,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: polizaPdfB64 != null ? AppColors.primaryLight.withOpacity(0.3) : AppColors.white,
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(polizaPdfB64 != null ? Icons.picture_as_pdf : Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(polizaPdfB64 != null ? 'Póliza cargada ✓' : 'Adjuntar PDF',
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
      ),
    );
  }
}

// --- DELEGATE DEL HEADER ---

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isVoiceActive;
  final VoidCallback onVoiceTap;
  final String? fotoPerfilBase64;
  final VoidCallback onPhotoTap;

  _HeaderDelegate({
    required this.isVoiceActive,
    required this.onVoiceTap,
    this.fotoPerfilBase64,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: maxExtent,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Row(
            children: [
              const SizedBox(width: 60),
              Expanded(
                child: Center(
                  child: Text('Completar Perfil',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(width: 60),
            ],
          ),
        ),
        // Botón Atrás
        Positioned(
          left: 10,
          bottom: 15,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // Foto de Perfil (Tu Lógica)
        Positioned(
          left: 20,
          top: 10,
          child: GestureDetector(
            onTap: onPhotoTap,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.white,
              backgroundImage: fotoPerfilBase64 != null
                  ? MemoryImage(base64Decode(fotoPerfilBase64!)) as ImageProvider
                  : const AssetImage('assets/conductor.png'),
            ),
          ),
        ),
        // Micrófono (Estética Repo)
        Positioned(
          right: 15,
          bottom: 10,
          child: GestureDetector(
            onTap: onVoiceTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isVoiceActive ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(isVoiceActive ? Icons.mic : Icons.mic_none, color: AppColors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 85;
  @override
  double get minExtent => 85;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}