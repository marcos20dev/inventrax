import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../views/usuarios_auth/login_screen.dart';

class UserSession extends ChangeNotifier {
  String? _uid;
  int? _rolId;

  String? get uid => _uid;
  int? get rolId => _rolId;

  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  void setRolId(int rolId) {
    _rolId = rolId;
    notifyListeners();
  }

  void clearSession() {
    _uid = null;
    _rolId = null;
    notifyListeners();
  }
  void cerrarSesion(BuildContext context) {
    _uid = null;
    _rolId = null;
    notifyListeners();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()), // O el nombre de tu login
    );
  }
}
