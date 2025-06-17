import 'package:flutter/cupertino.dart';

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
}
