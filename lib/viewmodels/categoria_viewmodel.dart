import 'package:flutter/cupertino.dart';

import '../models/categoria.dart';
import '../repositories/categoria_repository.dart';
import 'auth_viewmodel.dart';

class CategoriaViewModel extends ChangeNotifier {
  final CategoriaRepository repository;
  AuthViewModel? _auth;
  List<Categoria> _categorias = [];
  List<Categoria> get categorias => _categorias;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoriaViewModel(this.repository);

  void updateAuth(AuthViewModel auth) {
    _auth = auth;
    notifyListeners();
  }

  Future<bool> saveCategoria(Categoria categoria) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (categoria.idCategoria == null) {
        await repository.insert(categoria);
      } else {
        await repository.update(categoria);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Categoria>> getCategorias() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final categorias = await repository.getAll();
      _categorias = categorias;  // <-- Muy importante asignar la lista aquí

      _isLoading = false;
      notifyListeners();
      return categorias;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }




  Future<bool> deleteCategoria(int idCategoria) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await repository.delete(idCategoria);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Categoria?> getCategoriaById(int idCategoria) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final categoria = await repository.getById(idCategoria);

      _isLoading = false;
      notifyListeners();
      return categoria;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
