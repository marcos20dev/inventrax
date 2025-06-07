import 'package:flutter/cupertino.dart';

class UserSession extends ChangeNotifier {
  String? _uid;

  String? get uid => _uid;

  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }
}
