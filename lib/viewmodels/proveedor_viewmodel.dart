import 'package:flutter/material.dart';
import '../models/proveedor.dart';
import '../repositories/proveedor_repository.dart';

class ProveedorViewModel with ChangeNotifier {
  final ProveedorRepository _repository;
  String? _errorMessage;
  bool _isLoading = false;
  List<Proveedor> _proveedores = [];
  List<Proveedor> get proveedores => _proveedores;

  ProveedorViewModel({required ProveedorRepository repository})
      : _repository = repository;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadProveedores() async {
    _setLoading(true);
    try {
      final proveedoresData = await _repository.getAllProveedores();
      _proveedores = proveedoresData.map((p) => Proveedor.fromMap(p)).toList();
      _setError(null);
    } catch (e) {
      _setError('Error al obtener proveedores: ${e.toString()}');
      _proveedores = [];
    } finally {
      _setLoading(false);
    }
  }
  Future<List<Proveedor>> getAllProveedores() async {
    _setLoading(true);
    try {
      final proveedores = await _repository.getAllProveedores();
      return proveedores.map((p) => Proveedor.fromMap(p)).toList();
    } catch (e) {
      _setError('Error al obtener proveedores: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Proveedor?> getProveedorById(int id) async {
    _setLoading(true);
    try {
      final proveedor = await _repository.getProveedorById(id);
      return proveedor != null ? Proveedor.fromMap(proveedor) : null;
    } catch (e) {
      _setError('Error al obtener el proveedor: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProveedor(Proveedor proveedor) async {
    _setLoading(true);
    try {
      final proveedorMap = proveedor.toMap();

      if (proveedor.idProveedor == null) {
        // Crear nuevo proveedor
        await _repository.createProveedor(proveedorMap);
      } else {
        // Actualizar proveedor existente
        await _repository.updateProveedor(proveedor.idProveedor!, proveedorMap);
      }
      return true;
    } catch (e) {
      _setError('Error al guardar el proveedor: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }



  Future<bool> deleteProveedor(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteProveedor(id);
      return true;
    } catch (e) {
      _setError('Error al eliminar el proveedor: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Proveedor>> searchProveedores(String query) async {
    _setLoading(true);
    try {
      final proveedores = await _repository.searchProveedores(query);
      return proveedores.map((p) => Proveedor.fromMap(p)).toList();
    } catch (e) {
      _setError('Error al buscar proveedores: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}