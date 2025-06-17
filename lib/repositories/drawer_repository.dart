import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerRepository {
  final supabase = Supabase.instance.client;

  Future<Map<String, bool>> obtenerPermisosPorRol(String rolId) async {
    try {
      final res = await supabase
          .from('rol_permisos')
          .select('id_permisos, permisos (id_permisos, nombre, modulo)')
          .eq('rol_id', int.parse(rolId))
          .eq('estado', true);

      print('🚀 Permisos cargados para rol $rolId: $res');

      final data = res as List;

      final permisos = <String, bool>{};
      for (var item in data) {
        final nombre = item['permisos']?['nombre'];
        if (nombre != null) {
          permisos[nombre] = true;
        }
      }

      print("✅ Mapa de permisos finales: $permisos");
      return permisos;
    } catch (e) {
      print("❌ Error al cargar permisos: $e");
      return {};
    }
  }
}
