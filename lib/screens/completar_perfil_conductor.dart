import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

// Importa tus servicios y proveedores (Ajusta las rutas según tu proyecto)
import '../providers/user_provider.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/validacion_service.dart';

// -------------------------------------------------------------------
// VISTA PRINCIPAL
// -------------------------------------------------------------------
class CompletarPerfilConductor extends StatefulWidget {
  const CompletarPerfilConductor({super.key});

  @override
  State<CompletarPerfilConductor> createState() => _CompletarPerfilConductorState();
}

class _CompletarPerfilConductorState extends State<CompletarPerfilConductor> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color accentBlue = Color(0xFF64A1F4);
  
  int _selectedIndex = 3;
  bool _isVoiceActive = false;
  bool _isLoading = false;
  bool _isInit = false; // Para cargar datos solo una vez

  late AnimationController _pulseController;

  // Controladores Perfil adaptados al Backend
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController(); 
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _fechaNacCtrl = TextEditingController();

  // Almacenamiento Base64 (Documentos y Foto de perfil)
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
        // Precargamos los datos del usuario desde el Provider
        _nombreCtrl.text = user.nombre ?? user.nombre ?? ''; 
        _correoCtrl.text = user.correo ?? '';
        _telefonoCtrl.text = user.telefono ?? ''; 
        _direccionCtrl.text = user.direccion ?? '';
        
        if (user.fechaNacimiento != null) {
          _fechaNacCtrl.text = user.fechaNacimiento!;
        }

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
      setState(() {
        fotoPerfilB64 = base64Encode(bytes);
      });
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
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El PDF es muy pesado. Máximo 3MB.')));
        return;
      }
      setState(() {
        polizaPdfB64 = base64Encode(result.files.single.bytes!);
      });
    }
  }

  // --- LLAMADAS REALES AL BACKEND ---
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
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Error al actualizar'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔥 ESTA ES LA FUNCIÓN CORREGIDA PARA VALIDACIONSERVICE 🔥
  Future<void> _enviarDocumentos() async {
    if (ineFrenteB64 == null || ineReversoB64 == null || licenciaFrenteB64 == null || licenciaReversoB64 == null || polizaPdfB64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, sube todos los documentos', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red)
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Ahora sí, pasamos todos los campos como los espera tu ValidacionService
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
      if (mounted) {
        // En caso de error (como token inválido o fallo de la API) mostramos el mensaje que lanza tu excepción
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarModalVehiculo(double sw) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ModalInfoVehiculo(sw: sw), 
    );
  }

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(color: color, fontSize: sp(size, sw), fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final user = context.watch<UserProvider>().user;
    final String nombreHeader = user?.nombre ?? user?.nombre ?? "Conductor";
    final bool isActivo = user?.activo ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _ConductorHeaderDelegate(
                  maxHeight: 110,
                  minHeight: 85,
                  isVoiceActive: _isVoiceActive,
                  pulseAnimation: _pulseController,
                  onVoiceTap: _toggleVoice,
                  onPhotoTap: _cambiarFotoPerfil, 
                  fotoPerfilBase64: fotoPerfilB64, 
                  nombreUsuario: nombreHeader, 
                  sw: sw,
                  mBold: mBold,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sp(25, sw)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: sp(80, sw)), 
                      
                      if (!isActivo) ...[
                        _buildCompleteProfileBanner(sw),
                        SizedBox(height: sp(25, sw)),
                      ],

                      // DATOS PERSONALES
                      Text('Información Personal', style: mBold(sw, size: 18, color: primaryBlue)),
                      SizedBox(height: sp(15, sw)),
                      _buildTextField(sw, 'Nombre Completo', _nombreCtrl),
                      _buildTextField(sw, 'Correo Electrónico', _correoCtrl, readOnly: true), // Correo bloqueado
                      _buildTextField(sw, 'Teléfono', _telefonoCtrl, isPhone: true),
                      _buildTextField(sw, 'Dirección', _direccionCtrl),
                      _buildTextField(sw, 'Fecha de Nacimiento (YYYY-MM-DD)', _fechaNacCtrl),
                      
                      SizedBox(height: sp(10, sw)),
                      Center(
                        child: ElevatedButton(
                          onPressed: _actualizarPerfil,
                          style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
                          child: Text('Actualizar Datos', style: mBold(sw, color: Colors.white)),
                        ),
                      ),
                      Divider(height: sp(50, sw), thickness: 2, color: Colors.grey[200]),

                      // DOCUMENTOS
                      Text('Validación de Documentos', style: mBold(sw, size: 18, color: primaryBlue)),
                      SizedBox(height: sp(15, sw)),

                      Text('Foto de INE', style: mBold(sw, size: 14)),
                      SizedBox(height: sp(10, sw)),
                      Row(
                        children: [
                          Expanded(child: _buildDocumentCard(sw, 'Anverso', ineFrenteB64 != null, () => _pickImage('ineFrente'))),
                          SizedBox(width: sp(15, sw)),
                          Expanded(child: _buildDocumentCard(sw, 'Reverso', ineReversoB64 != null, () => _pickImage('ineReverso'))),
                        ],
                      ),

                      SizedBox(height: sp(25, sw)),
                      Text('Foto de Licencia de Conducir', style: mBold(sw, size: 14)),
                      SizedBox(height: sp(10, sw)),
                      Row(
                        children: [
                          Expanded(child: _buildDocumentCard(sw, 'Anverso', licenciaFrenteB64 != null, () => _pickImage('licenciaFrente'))),
                          SizedBox(width: sp(15, sw)),
                          Expanded(child: _buildDocumentCard(sw, 'Reverso', licenciaReversoB64 != null, () => _pickImage('licenciaReverso'))),
                        ],
                      ),

                      SizedBox(height: sp(25, sw)),
                      Text('Póliza de Seguro', style: mBold(sw, size: 14)),
                      SizedBox(height: sp(10, sw)),
                      GestureDetector(
                        onTap: _pickPdf,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: sp(20, sw), vertical: sp(15, sw)),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryBlue, width: 2),
                            borderRadius: BorderRadius.circular(10),
                            color: polizaPdfB64 != null ? lightBlueBg : Colors.white,
                          ),
                          child: Text(polizaPdfB64 != null ? 'PDF Cargado ✓' : 'Subir PDF (Máx 3MB)', style: mBold(sw, color: primaryBlue, size: 14)),
                        ),
                      ),

                      SizedBox(height: sp(30, sw)),
                      SizedBox(
                        width: double.infinity, height: sp(50, sw),
                        child: ElevatedButton(
                          onPressed: _enviarDocumentos,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: Text('Enviar Documentos a Revisión', style: mBold(sw, color: Colors.white, size: 16)),
                        ),
                      ),
                      Divider(height: sp(50, sw), thickness: 2, color: Colors.grey[200]),

                      // ACCIONES EXTRA
                      Center(
                        child: _buildActionButton(sw, 'Datos de mi Vehículo', () => _mostrarModalVehiculo(sw)),
                      ),
                      SizedBox(height: sp(50, sw)), 
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(sw),
    );
  }

  Widget _buildTextField(double sw, String label, TextEditingController controller, {bool isPhone = false, bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp(15, sw)),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? Colors.grey[700] : Colors.black),
        decoration: InputDecoration(
          labelText: label, labelStyle: mBold(sw, size: 12, color: Colors.grey),
          fillColor: readOnly ? Colors.grey[100] : Colors.white,
          filled: readOnly,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: accentBlue.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: readOnly ? accentBlue.withOpacity(0.5) : primaryBlue)),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(double sw, String label, bool isLoaded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: sp(90, sw), width: double.infinity,
            decoration: BoxDecoration(
              color: isLoaded ? lightBlueBg : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentBlue.withOpacity(0.3)),
            ),
            child: Center(
              child: Icon(isLoaded ? Icons.check_circle : Icons.camera_alt, color: primaryBlue, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: mBold(sw, color: primaryBlue, size: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(double sw, String label, VoidCallback onTap) {
    return SizedBox(
      width: sp(280, sw), height: sp(50, sw),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: accentBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(label, style: mBold(sw, color: Colors.white, size: 16)),
      ),
    );
  }

  Widget _buildCompleteProfileBanner(double sw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFEF5350), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text('Completar perfil', style: mBold(sw, color: Colors.white, size: 14)),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(double sw) {
    return Container(
      height: 70, decoration: const BoxDecoration(color: Color(0xFFD6E8FF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(sw, 0, Icons.home), _navIcon(sw, 1, Icons.location_on),
          _navIcon(sw, 2, Icons.history), _navIcon(sw, 3, Icons.person),
        ],
      ),
    );
  }

  Widget _navIcon(double sw, int index, IconData icon) {
    bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(color: active ? primaryBlue : Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: active ? Colors.white : primaryBlue, size: 25),
      ),
    );
  }
}

// -------------------------------------------------------------------
// DELEGATE DEL HEADER (Arriba)
// -------------------------------------------------------------------
class _ConductorHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight; final double minHeight; final bool isVoiceActive; 
  final Animation<double> pulseAnimation; final VoidCallback onVoiceTap; 
  final VoidCallback onPhotoTap; final String? fotoPerfilBase64; 
  final String nombreUsuario; 
  final double sw; final TextStyle Function(double, {Color color, double size}) mBold;

  _ConductorHeaderDelegate({
    required this.maxHeight, required this.minHeight, required this.isVoiceActive,
    required this.pulseAnimation, required this.onVoiceTap, required this.onPhotoTap,
    this.fotoPerfilBase64, required this.nombreUsuario, required this.sw, required this.mBold,
  });

  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = shrinkOffset / maxHeight;
    final double opacity = (1.0 - percent * 2.5).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: maxHeight, width: double.infinity, decoration: const BoxDecoration(color: Color(0xFFB3D4FF))),
        Positioned(left: 10, bottom: 35, child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1559B2), size: 20), onPressed: () => Navigator.of(context).pop())),
        
        Positioned(
          left: sw * (135 / 375), top: sw * (100 / 375) - shrinkOffset, 
          child: Opacity(
            opacity: opacity, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(nombreUsuario, style: mBold(sw, size: 20)), 
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(Icons.star, color: Colors.orange, size: sw * (16/375))), 
                    Text(' 5.00', style: mBold(sw, size: 12, color: const Color(0xFF1559B2)))
                  ]
                )
              ]
            )
          )
        ),
        
        // FOTO DE PERFIL CLICKABLE
        Positioned(
          top: sw * (50 / 375) - shrinkOffset, left: sw * (20 / 375), 
          child: Opacity(
            opacity: opacity, 
            child: GestureDetector(
              onTap: onPhotoTap,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: sw * (50 / 375), 
                    backgroundColor: Colors.white,
                    backgroundImage: fotoPerfilBase64 != null && fotoPerfilBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(fotoPerfilBase64!)) as ImageProvider
                        : const AssetImage('assets/conductor.png'),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF1559B2), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  )
                ],
              ),
            ),
          )
        ),

        Positioned(
          top: sw * (75 / 375) - (shrinkOffset * 0.4), right: sw * (25 / 375), 
          child: GestureDetector(onTap: onVoiceTap, child: ScaleTransition(scale: pulseAnimation, child: Image.asset(isVoiceActive ? 'assets/escuchando.png' : 'assets/controlvoz.png', width: 65, height: 65)))
        ),
      ],
    );
  }
  @override double get maxExtent => maxHeight;
  @override double get minExtent => minHeight;
  @override bool shouldRebuild(covariant _ConductorHeaderDelegate oldDelegate) => true;
}

// -------------------------------------------------------------------
// COMPONENTE EXTRAÍDO: MODAL DEL VEHÍCULO
// -------------------------------------------------------------------
class ModalInfoVehiculo extends StatelessWidget {
  final double sw;
  const ModalInfoVehiculo({super.key, required this.sw});

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(color: color, fontSize: sp(size, sw), fontWeight: FontWeight.bold);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: mBold(sw, size: 12, color: Colors.grey[700]!)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
            child: Text(value, style: mBold(sw, size: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Text('Datos de mi Vehículo', style: mBold(sw, size: 18, color: const Color(0xFF1559B2))),
          const SizedBox(height: 15),
          _buildReadOnlyField('Marca', 'Nissan'),
          _buildReadOnlyField('Modelo', 'Versa 2021'),
          _buildReadOnlyField('Color', 'Plata'),
          _buildReadOnlyField('Placas', 'XYZ-987-A'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1559B2)),
              child: Text('Cerrar', style: mBold(sw, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}