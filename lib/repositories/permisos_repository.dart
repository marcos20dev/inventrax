import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Permisos.dart';
import '../models/RolPermisos.dart';

class PermisoRepository {
  final _client = Supabase.instance.client;

  Future<List<PermisoModel>> getAll() async {
    final response = await _client.from('permisos').select();
    return (response as List)
        .map((permiso) => PermisoModel.fromMap(permiso))
        .toList();
  }

  Future<void> guardarPermisosDeRol(int rolId, List<RolPermisoModel> permisos) async {
    final permisoIds = permisos.map((p) => p.toMap()['id_permisos']).toList();

    await _client.rpc('actualizar_permisos_rol', params: {
      'p_rol_id': rolId,
      'p_permisos': permisoIds,
    });
  }


  Future<List<int>> obtenerPermisosDeRol(int rolId) async {
    final response = await _client
        .from('rol_permisos')
        .select('id_permisos')
        .eq('rol_id', rolId)
        .eq('estado', true);

    return (response as List).map<int>((e) => e['id_permisos'] as int).toList();
  }


}
