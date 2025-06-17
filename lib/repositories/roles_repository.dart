import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/roles.dart';

class RoleRepository {
  final _client = Supabase.instance.client;

  Future<List<Role>> getAllRoles() async {
    final response = await _client.from('roles').select();
    return (response as List)
        .map((e) => Role.fromJson(e as Map<String, dynamic>))
        .toList();
  }


  Future<List<Role>> fetchRoles() async {
    final response = await _client
        .from('roles')
        .select()
        .order('id_roles', ascending: true);

    final data = response as List;
    return data.map((role) => Role.fromJson(role)).toList();
  }

  Future<void> insertRole(Role role) async {
    await _client.from('roles').insert(role.toJson());
  }

  Future<void> deleteRole(int id) async {
    await _client.from('roles').delete().eq('id_roles', id);
  }

  Future<void> updateRole(Role role) async {
    if (role.idRoles == null) {
      throw ArgumentError('El ID del rol no puede ser null para actualizar');
    }

    await _client
        .from('roles')
        .update(role.toJson())
        .eq('id_roles', role.idRoles!);
  }

}
