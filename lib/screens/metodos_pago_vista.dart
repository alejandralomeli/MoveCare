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
  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);

  // Variables de estado para la BD
  List<dynamic> tarjetas = [];
  bool isLoading = true; // Para mostrar indicador de carga

  @override
  void initState() {
    super.initState();
    _cargarTarjetas(); // Llamamos al back al abrir la vista
  }

  // 🔥 Método para traer las tarjetas reales
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar tarjetas: $e'), backgroundColor: statusRed),
      );
    }
  }

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 14, required BuildContext context}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  void _mostrarDialogoDesactivar(String idMetodo, String alias, String ultimosCuatro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Desactivar Tarjeta', style: mExtrabold(size: 18, context: context, color: primaryBlue)),
        content: Text(
          '¿Estás seguro que deseas eliminar la tarjeta $alias (terminación $ultimosCuatro)?',
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancelar', style: mExtrabold(size: 14, context: context, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: statusRed, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              Navigator.pop(context); // Cerramos el modal primero
              
              // 🔥 Llamamos al backend para desactivar
              try {
                await PagosService.desactivarTarjeta(idMetodo);
                
                // Si sale bien, la quitamos de la lista visual
                setState(() {
                  tarjetas.removeWhere((t) => t["id_metodo"] == idMetodo);
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarjeta desactivada correctamente'), backgroundColor: primaryBlue),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al desactivar: $e'), backgroundColor: statusRed),
                );
              }
            },
            child: Text('Eliminar', style: mExtrabold(color: Colors.white, size: 14, context: context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: lightBlueBg,
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Text(
                      'Métodos de Pago',
                      style: GoogleFonts.montserrat(fontSize: sp(20, context), fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            // 🔥 Mostramos loading mientras consulta la BD
            child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryBlue))
              : tarjetas.isEmpty 
                  ? Center(
                      child: Text(
                        "No tienes métodos de pago registrados.",
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: tarjetas.length,
                      itemBuilder: (context, index) {
                        final t = tarjetas[index];
                        // 🔥 Mapeamos usando las llaves de FastAPI
                        return _buildTarjetaCard(
                          idMetodo: t["id_metodo"], 
                          ultimosCuatro: t["ultimos_cuatro"],
                          alias: t["alias"] ?? "Tarjeta",
                        );
                      },
                    ),
          ),

          Padding(
            padding: EdgeInsets.all(sw * 0.06),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/registro_tarjeta').then((_) {
                    // Refrescamos la lista al regresar por si agregó una nueva
                    _cargarTarjetas();
                  });
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: Text('Registrar Método de Pago', style: mExtrabold(color: Colors.white, size: 16, context: context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PassengerBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildTarjetaCard({required String idMetodo, required String ultimosCuatro, required String alias}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBlue, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: primaryBlue.withOpacity(0.1))
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/tarjeta.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alias, style: mExtrabold(size: 16, context: context)),
                    const SizedBox(height: 4),
                    Text('**** **** **** $ultimosCuatro', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30, color: Colors.white),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _mostrarDialogoDesactivar(idMetodo, alias, ultimosCuatro),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: statusRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Desactivar tarjeta', style: mExtrabold(color: statusRed, size: 13, context: context)),
            ),
          )
        ],
      ),
    );
  }

}