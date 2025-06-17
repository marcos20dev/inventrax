import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/RolPermisos.dart';

class RolPermisoRepository {
  final _client = Supabase.instance.client;

  Future<List<RolPermisoModel>> getByRol(int rolId) async {
    final response = await _client
        .from('rol_permisos')
        .select()
        .eq('rol_id', rolId);

    return (response as List)
        .map((perm) => RolPermisoModel.fromMap(perm))
        .toList();
  }

  Future<void> asignarPermiso({
    required int rolId,
    required int permisoId,
    required bool estado,
  }) async {
    await _client.from('rol_permisos').upsert({
      'rol_id': rolId,
      'id_permisos': permisoId,
      'estado': estado,
    });
  }
}
