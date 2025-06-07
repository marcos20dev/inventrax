import 'package:supabase_flutter/supabase_flutter.dart';

class ProveedorRepository {
  final SupabaseClient _supabase;

  ProveedorRepository({required SupabaseClient supabase}) : _supabase = supabase;

  Future<List<Map<String, dynamic>>> getAllProveedores() async {
    final response = await _supabase
        .from('proveedores')
        .select()
        .order('nombre_proveedor', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getProveedorById(int id) async {
    final response = await _supabase
        .from('proveedores')
        .select()
        .eq('id_proveedor', id)
        .single();

    return response;
  }

  Future<Map<String, dynamic>?> getProveedorByNombre(String nombre) async {
    final response = await _supabase
        .from('proveedores')
        .select()
        .eq('nombre_proveedor', nombre)
        .maybeSingle();  // Devuelve null si no existe

    return response;
  }

  Future<int> createProveedor(Map<String, dynamic> proveedor) async {
    final response = await _supabase
        .from('proveedores')
        .insert(proveedor)
        .select('id_proveedor')
        .single();

    return response['id_proveedor'] as int;
  }

  Future<bool> updateProveedor(int id, Map<String, dynamic> proveedor) async {
    try {
      final response = await _supabase
          .from('proveedores')
          .update(proveedor)
          .eq('id_proveedor', id);

      // Puedes verificar que 'response' no esté vacío para confirmar que actualizó algo:
      return response != null && (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }


  Future<bool> deleteProveedor(int id) async {
    try {
      await _supabase
          .from('proveedores')
          .delete()
          .eq('id_proveedor', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchProveedores(String query) async {
    final response = await _supabase
        .from('proveedores')
        .select()
        .ilike('nombre_proveedor', '%$query%')
        .order('nombre_proveedor', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}