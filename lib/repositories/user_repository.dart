import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/roles.dart';
import '../models/user.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);
  final SupabaseClient _supabase = Supabase.instance.client;
  final client = Supabase.instance.client;
  final supabase = Supabase.instance.client;

  Future<List<Role>> getAllRoles() async {
    final response = await _client.from('roles').select();
    return (response as List)
        .map((e) => Role.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PostgrestMap> registerUser(User user) async {
    try {
      // 1. Registro en Supabase Auth
      final res = await _client.auth.signUp(
        email: user.email,
        password: user.password,
      );

      if (res.user == null) {
        throw Exception('User registration failed');
      }

      // 2. Insertar en tabla usuarios_roles
      final userData = user.toJson();
      userData.remove('password'); // No enviar contraseña
      userData['id_usuario'] = res.user!.id;

      // 👇 Aseguramos que esté en el campo correcto
      userData['id_roles'] = user.rolId;

      final response = await _client
          .from('usuarios')
          .insert(userData)
          .select()
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }


  Future<User?> loginUser(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Credenciales incorrectas');
    }

    // Opcional: obtener info extra de la tabla 'usuarios_roles' si necesitas más datos
    final userData = await _client
        .from('usuarios')
        .select()
        .eq('id_usuario', response.user!.id)
        .single(); // ← ya estás filtrando por usuario

    if (userData == null) {
      throw Exception('No se encontró información adicional del usuario');
    }

    return User.fromJson(userData); // ← este userData debe tener `id_usuario` e `id_rol`

  }


  Future<void> actualizarUsuario({
    required String id, // UUID del usuario
    required int? rolId,
  }) async {
    await supabase.from('usuarios').update({
      'id_roles': rolId,
    }).eq('id_usuario', id);
  }



  Future<void> eliminarUsuario(String idUsuario) async {
    try {
      await _supabase.from('usuarios').delete().eq('id_usuario', idUsuario);
    } catch (e) {
      throw Exception('No se pudo eliminar el usuario: $e');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select('id_usuario, nombre, apellido, documento_identidad, correo_electronico, id_roles, roles(nombre, id_roles)')
          .order('nombre', ascending: true);

      return List<Map<String, dynamic>>.from(response.map((usuario) {
        return {
          'id_usuario': usuario['id_usuario'], // Asegúrate de incluir este campo
          'nombre': '${usuario['nombre']} ${usuario['apellido']}',
          'correo': usuario['correo_electronico'],
          'dni': usuario['documento_identidad'],
          'rol': usuario['roles']?['nombre'] ?? 'Usuario',
          'id_roles': usuario['id_roles'], // Incluye el ID del rol también
        };
      }));
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

}


