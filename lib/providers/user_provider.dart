import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  // ✅ Para cuando ya tienes el modelo
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // ✅ NUEVO: Para cuando viene del backend (JSON)
  void setUserFromJson(Map<String, dynamic> json) {
    _user = UserModel.fromJson(json);
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}

