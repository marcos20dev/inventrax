import 'package:flutter/material.dart';
import '../repositories/drawer_repository.dart';

class PermisosProvider extends ChangeNotifier {
  Map<String, bool> _permisos = {};

  Map<String, bool> get permisos => _permisos;

  Future<void> cargarPermisos(int rolId) async {
    try {
      final repo = DrawerRepository();
      _permisos = await repo.obtenerPermisosPorRol(rolId.toString());

      print("🚀 Permisos cargados para rol $rolId: $_permisos");

      notifyListeners();
    } catch (e) {
      print("❌ Error al cargar permisos: $e");
    }
  }

  bool tienePermiso(String clave) {
    return _permisos[clave] ?? false;
  }

  void limpiarPermisos() {
    _permisos.clear();
    notifyListeners();
  }
}
