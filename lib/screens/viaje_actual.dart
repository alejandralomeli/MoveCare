import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'chat_viaje.dart';

class ViajeActualMapa extends StatefulWidget {
  const ViajeActualMapa({super.key});

  @override
  State<ViajeActualMapa> createState() => _ViajeActualMapaState();
}

class _ViajeActualMapaState extends State<ViajeActualMapa> {
  bool _panelExpanded = false;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // 0 = En camino al pasajero | 1 = Pasajero a bordo | 2 = Llegando al destino
  int _tripPhase = 1;

  final List<Map<String, String>> _phases = [
    {'label': 'En camino', 'sub': 'Dirígete al punto de recogida'},
    {'label': 'En ruta', 'sub': 'Pasajero a bordo'},
    {'label': 'Llegando', 'sub': 'Próximo al destino'},
  ];

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    final target = _panelExpanded ? 0.42 : 0.12;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    setState(() => _panelExpanded = !_panelExpanded);
  }

  void _colapsarPanel() {
    _sheetController.animateTo(
      0.12,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
    setState(() => _panelExpanded = true);
  }

  void _avanzarFase() {
    if (_tripPhase < 2) {
      setState(() => _tripPhase++);
      _colapsarPanel();
    } else {
      _mostrarFinViaje();
    }
  }

  void _mostrarFinViaje() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text('¿Finalizar viaje?', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Confirma que el pasajero llegó a su destino.', textAlign: TextAlign.center, style: mBold(color: AppColors.textSecondary, size: 13)),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar', style: mBold(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Finalizar', style: mBold(color: AppColors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa full-screen ──────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset('assets/mapa.png', fit: BoxFit.cover),
          ),

          // ── Barra de navegación (instrucción) ─────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.turn_right_rounded, color: AppColors.white, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'En 300m gire a la derecha por Av. Central',
                                style: mBold(color: AppColors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Indicador de fase ─────────────────────────────────────────────
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: _buildPhaseIndicator(),
          ),

          // ── Panel inferior deslizable ─────────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.42,
            minChildSize: 0.12,
            maxChildSize: 0.42,
            snap: true,
            snapSizes: const [0.12, 0.42],
            builder: (context, scrollController) => _buildBottomPanel(scrollController),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNav(selectedIndex: 1),
    );
  }

  // ── FASE INDICATOR ────────────────────────────────────────────────────────

  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == _tripPhase;
          final done = i < _tripPhase;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: done || active ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phases[i]['label']!,
                        textAlign: TextAlign.center,
                        style: mBold(
                          size: 9,
                          color: active ? AppColors.primary : done ? AppColors.textSecondary : AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── PANEL INFERIOR ────────────────────────────────────────────────────────

  Widget _buildBottomPanel(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // Pill
          GestureDetector(
            onTap: _togglePanel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ETA + distancia
          Row(
            children: [
              _etaChip(Icons.access_time_rounded, '15 min', AppColors.primary),
              const SizedBox(width: 10),
              _etaChip(Icons.route_rounded, '4.2 km', AppColors.textSecondary),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Llegada 10:45', style: mBold(color: AppColors.success, size: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Info pasajero
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage('assets/pasajero.png'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('María González', style: mBold(size: 15)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                        const SizedBox(width: 3),
                        Text('4.9', style: mBold(color: AppColors.textSecondary, size: 12)),
                        const SizedBox(width: 10),
                        const Icon(Icons.accessible_forward_rounded, color: AppColors.primary, size: 14),
                        const SizedBox(width: 3),
                        Text('Silla de ruedas', style: mBold(color: AppColors.textSecondary, size: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // Botones contacto
              _circleBtn(Icons.phone_rounded, AppColors.primary, () {}),
              const SizedBox(width: 10),
              _circleBtn(Icons.message_rounded, AppColors.primary, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ChatViaje(nombreContacto: 'María González', esConductor: true),
                ));
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Destino
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hospital General, Av. Insurgentes 3241',
                    style: mBold(size: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Botón de acción principal
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _avanzarFase,
              style: ElevatedButton.styleFrom(
                backgroundColor: _tripPhase == 2 ? AppColors.success : AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _tripPhase == 0
                    ? 'Confirmar recogida'
                    : _tripPhase == 1
                        ? 'Iniciar ruta'
                        : 'Finalizar viaje',
                style: mBold(color: AppColors.white, size: 15),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _etaChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: mBold(color: color, size: 13)),
      ],
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
