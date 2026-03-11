import 'package:flutter/material.dart';

/// Escala un tamaño en base al ancho de pantalla de referencia (375px).
double sp(double size, BuildContext context) {
  final sw = MediaQuery.of(context).size.width;
  return sw * (size / 375);
}
