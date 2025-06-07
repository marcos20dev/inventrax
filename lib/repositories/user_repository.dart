import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/user.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

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

      // 2. Insertar en tabla usuarios
      final userData = user.toJson();
      userData.remove('password'); // Asegúrate de no incluir el password
      userData['id_usuario'] = res.user!.id;

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

    // Opcional: obtener info extra de la tabla 'usuarios' si necesitas más datos
    final userData = await _client
        .from('usuarios')
        .select()
        .eq('id_usuario', response.user!.id)
        .single();

    if (userData == null) {
      throw Exception('No se encontró información adicional del usuario');
    }

    return User.fromJson(userData);
  }


}


