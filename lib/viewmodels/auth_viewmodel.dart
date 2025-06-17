import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _repository;
  User? _user;

  bool _isLoading = false;
  String? _error;
  User? get user => _user;

  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthViewModel(this._repository);

  Future<void> registerUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerUser(user);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loginUser(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.loginUser(email, password);
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



}
