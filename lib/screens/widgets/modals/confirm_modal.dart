import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//MIRA ESTO ALE APARIENCIA 
//Son modales que genero en la creacion de viajes
void showConfirmModal({
  required BuildContext context,
  required String title,
  required VoidCallback onConfirm,
  String confirmText = 'Confirmar',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}

