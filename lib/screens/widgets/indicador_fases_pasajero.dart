import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class IndicadorFases extends StatelessWidget {
  final String estadoViaje;
  final bool esConductor; // <-- Agregamos esta propiedad

  const IndicadorFases({
    super.key, 
    required this.estadoViaje, 
    this.esConductor = true, // Por defecto conductor para no romper lo anterior
  });

  // Definimos las fases dinámicamente
  List<Map<String, String>> get _phases {
    if (esConductor) {
      return [
        {'label': 'En camino', 'sub': 'Dirígete al punto de recogida'},
        {'label': 'En ruta', 'sub': 'Pasajero a bordo'},
        {'label': 'Llegando', 'sub': 'Próximo al destino'},
      ];
    } else {
      return [
        {'label': 'En camino', 'sub': 'El conductor va a tu ubicación'},
        {'label': 'En ruta', 'sub': 'Vas de camino'},
        {'label': 'Llegando', 'sub': 'Ya casi llegas'},
      ];
    }
  }

  TextStyle mBold({Color color = AppColors.textPrimary, double size = 14}) {
    return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    int faseIndex = 0;
    if (estadoViaje == 'En_curso') {
      faseIndex = 1;
    } else if (estadoViaje == 'Finalizado') {
      faseIndex = 3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == faseIndex;
          final done = i < faseIndex;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: done || active
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phases[i]['label']!,
                        textAlign: TextAlign.center,
                        style: mBold(
                          size: 9,
                          color: active
                              ? AppColors.primary
                              : done
                                  ? AppColors.textSecondary
                                  : AppColors.border,
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
}