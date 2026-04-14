import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pagos/pagos_service.dart';
import '../app_theme.dart';

class MetodosPagoVista extends StatefulWidget {
  const MetodosPagoVista({super.key});

  @override
  State<MetodosPagoVista> createState() => _MetodosPagoVistaState();
}

class _MetodosPagoVistaState extends State<MetodosPagoVista> {
  List<dynamic> tarjetas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTarjetas();
  }

  Future<void> _cargarTarjetas() async {
    setState(() => isLoading = true);
    try {
      final data = await PagosService.obtenerTarjetas();
      setState(() {
        tarjetas = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tarjetas: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _mostrarDialogoDesactivar(String idMetodo, String alias, String ultimosCuatro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Desactivar tarjeta',
          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Seguro que deseas eliminar $alias (•••• $ultimosCuatro)?',
          style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await PagosService.desactivarTarjeta(idMetodo);
                if (mounted) setState(() => tarjetas.removeWhere((t) => t["id_metodo"] == idMetodo));
                messenger.showSnackBar(
                  const SnackBar(content: Text('Tarjeta eliminada'), backgroundColor: AppColors.primary),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            child: Text('Eliminar', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(),
          ),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (tarjetas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card_off_outlined, size: 56, color: AppColors.border),
                    const SizedBox(height: 14),
                    Text(
                      'Sin métodos de pago',
                      style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Agrega una tarjeta para pagar tus viajes',
                      style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final t = tarjetas[index];
                    return _buildTarjetaCard(
                      idMetodo: t["id_metodo"],
                      ultimosCuatro: t["ultimos_cuatro"],
                      alias: t["alias"] ?? "Tarjeta",
                    );
                  },
                  childCount: tarjetas.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.05, 0, sw * 0.05, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/registro_tarjeta').then((_) => _cargarTarjetas()),
                icon: const Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                label: Text(
                  'Agregar tarjeta',
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          const PassengerBottomNav(selectedIndex: 3),
        ],
      ),
    );
  }

  Widget _buildTarjetaCard({required String idMetodo, required String ultimosCuatro, required String alias}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alias, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('•••• •••• •••• $ultimosCuatro', style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _mostrarDialogoDesactivar(idMetodo, alias, ultimosCuatro),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primaryLight,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            bottom: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Métodos de pago',
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override double get maxExtent => 80;
  @override double get minExtent => 80;
  @override bool shouldRebuild(covariant _HeaderDelegate old) => false;
}
