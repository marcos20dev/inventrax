import 'package:flutter/cupertino.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';

class ClienteViewModel extends ChangeNotifier {
  final ClientesRepository repository;

  ClienteViewModel({required this.repository});

  List<Cliente> clientes = [];
  bool isLoading = false;
  String? errorMessage;  // <-- aquí guardamos el error

  Future<void> loadClientes() async {
    isLoading = true;
    notifyListeners();
    try {
      clientes = await repository.getClientes();
      errorMessage = null;
    } catch (e) {
      clientes = [];
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addCliente(Cliente cliente) async {
    try {
      await repository.crearCliente(cliente);
      await loadClientes();
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();  // <-- capturamos error aquí
      return false;
    }
  }

  Future<bool> updateCliente(int id, Cliente cliente) async {
    try {
      await repository.actualizarCliente(id, cliente);
      await loadClientes();
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();  // <-- capturamos error aquí
      return false;
    }
  }

  Future<bool> deleteCliente(int id) async {
    try {
      await repository.eliminarCliente(id);
      await loadClientes();
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }
}
