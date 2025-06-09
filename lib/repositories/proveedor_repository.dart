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

  Future<Object> createProveedor(Map<String, dynamic> proveedor) async {
    try {
      print("createProveedor ejecutado");

      // Verificamos si el proveedor ya existe (si no tiene id_proveedor)
      final existingProveedor = await _supabase
          .from('proveedores')
          .select()
          .eq('nombre_proveedor', proveedor['nombre_proveedor'])
          .maybeSingle(); // Devuelve null si no existe

      if (existingProveedor != null) {
        print("Proveedor ya existe.");
        return false;  // No creamos el proveedor porque ya existe
      }

      // Insertamos el nuevo proveedor
      final response = await _supabase
          .from('proveedores')
          .insert(proveedor)
          .select('id_proveedor')
          .single();

      print("Proveedor creado con ID: ${response['id_proveedor']}");
      return response['id_proveedor'] as int;
    } catch (e) {
      print("Error al crear proveedor: $e");
      return false;  // Error al crear
    }
  }

  Future<bool> updateProveedor(int id, Map<String, dynamic> proveedor) async {
    try {
      print("Actualizando proveedor con ID: $id");

      // Actualizamos el proveedor si ya existe
      final response = await _supabase
          .from('proveedores')
          .update(proveedor)
          .eq('id_proveedor', id)
          .select();

      if (response != null && response.isNotEmpty) {
        print("Proveedor actualizado con éxito.");
        return true;
      } else {
        print("No se pudo actualizar el proveedor.");
        return false;
      }
    } catch (e) {
      print("Error al actualizar proveedor: $e");
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