import 'package:flutter/material.dart';

enum FontSizeOption { pequeno, normal, grande, muyGrande }

class FontSizeProvider extends ChangeNotifier {
  FontSizeOption _option = FontSizeOption.normal;

  FontSizeOption get option => _option;

  double get scaleFactor {
    switch (_option) {
      case FontSizeOption.pequeno:
        return 0.85;
      case FontSizeOption.normal:
        return 1.0;
      case FontSizeOption.grande:
        return 1.2;
      case FontSizeOption.muyGrande:
        return 1.4;
    }
  }

  void setOption(FontSizeOption option) {
    if (_option != option) {
      _option = option;
      notifyListeners();
    }
  }
}
