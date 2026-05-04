import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/auditoria_model.dart';
import '../services/auditoria/auditoia_service.dart';
import 'widgets/modals/detalle_auditoria.dart';

class HistorialAuditoria extends StatelessWidget {
  const HistorialAuditoria({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color lightBlueBg = Color(0xFFB3D4FF);
  static const Color cardBlue = Color(0xFFD6E8FF);

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({
    Color color = Colors.black,
    double size = 14,
    required BuildContext context,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: sp(size, context),
      fontWeight: FontWeight.bold,
    );
  }

  // Función para formatear la fecha que viene de la BD
  String _formatearFecha(DateTime fecha) {
    String dia = fecha.day.toString().padLeft(2, '0');
    String mes = fecha.month.toString().padLeft(2, '0');
    String anio = fecha.year.toString();
    String hora = fecha.hour.toString().padLeft(2, '0');
    String minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio - $hora:$minuto hrs';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: AppColors.primaryLight,
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  bottom: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: Text(
                    'Historial de Movimientos',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Auditoria>>(
              future: AuditoriaService.obtenerHistorial(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Hubo un problema al cargar el historial.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay registros de movimientos.',
                      style: GoogleFonts.montserrat(color: Colors.black54),
                    ),
                  );
                }

                final auditorias = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.06,
                    vertical: 20,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: auditorias.length,
                  itemBuilder: (context, index) {
                    final registro = auditorias[index];

                    // Formateamos la tabla: reemplazamos guiones bajos y convertimos a mayúsculas
                    final tablaFormateada = registro.tablaAfectada
                        .replaceAll('_', ' ')
                        .toUpperCase();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: cardBlue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryBlue.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          // Icono que ahora abre el modal
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    DetalleAuditoriaModal(registro: registro),
                              );
                            },
                            // Le puse un contenedor invisible extra para que el área táctil sea un poco más grande
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.history,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: sp(12, context),
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${registro.nombreAdmin} ', // Nombre completo
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: '${registro.accion} en '),
                                      TextSpan(
                                        text:
                                            tablaFormateada, // Tabla en mayúsculas
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              primaryBlue, // Lo dejé azul para que resalte, si lo prefieres negro pon Colors.black
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatearFecha(registro.fecha),
                                  style: GoogleFonts.montserrat(
                                    fontSize: sp(10, context),
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
