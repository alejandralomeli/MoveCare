import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class HistorialAuditoria extends StatelessWidget {
  const HistorialAuditoria({super.key});

  double sp(double size, BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double res = sw * (size / 375);
    return (size <= 20 && res > 20) ? 20 : res;
  }

  TextStyle mExtrabold({Color color = Colors.black, double size = 14, required BuildContext context}) {
    return GoogleFonts.montserrat(color: color, fontSize: sp(size, context), fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
      body: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: AppColors.primaryLight,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Historial de Auditoría',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                String tipoUsuario = index % 2 == 0 ? 'Conductor' : 'Pasajero';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: AppColors.primary),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.montserrat(color: AppColors.textPrimary, fontSize: sp(12, context)),
                                children: [
                                  const TextSpan(text: 'Admin_Carlos ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: index % 2 == 0 ? 'aprobó a ' : 'rechazó a '),
                                  TextSpan(
                                    text: '$tipoUsuario ',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                  TextSpan(
                                    text: 'Usuario_$index',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '28/01/2026 - 14:30 PM',
                              style: GoogleFonts.montserrat(
                                fontSize: sp(10, context),
                                color: AppColors.textSecondary,
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
            ),
          ),
        ],
      ),
    );
  }
}
