import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cliente.dart';

class ClientesRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'clientes';

  ClientesRepository(this._supabase);

  /// Obtiene todos los clientes ordenados por fecha de creación descendente
  Future<List<Cliente>> getClientes() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((item) => Cliente.fromMap(item)).toList();
    } on PostgrestException catch (e) {
      throw _handleSupabaseError('obtener clientes', e);
    } catch (e) {
      throw Exception('Error inesperado al obtener clientes: ${e.toString()}');
    }
  }

  /// Obtiene un cliente específico por su ID
  Future<Cliente?> getClientePorId(int idCliente) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id_cliente', idCliente)
          .single();

      return Cliente.fromMap(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { // Código para "no encontrado"
        return null;
      }
      throw _handleSupabaseError('obtener cliente por ID', e);
    } catch (e) {
      throw Exception('Error inesperado al obtener cliente: ${e.toString()}');
    }
  }

  Future<Cliente?> buscarClientePorDni(String dni) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id_cliente, nombre, apellido, correo, documento_identidad') // ahora con id_cliente
          .eq('documento_identidad', dni)
          .single();


      // Si response es null o vacío, regresa null para evitar error
      if (response == null) return null;

      return Cliente.fromMap(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { // Cliente no encontrado
        return null;
      }
      throw Exception('Error en buscarClientePorDni: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado en buscarClientePorDni: ${e.toString()}');
    }
  }






  /// Crea un nuevo cliente en la base de datos
  Future<Cliente> crearCliente(Cliente cliente) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(cliente.toMap())
          .select()
          .single();

      return Cliente.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleSupabaseError('crear cliente', e);
    } catch (e) {
      throw Exception('Error inesperado al crear cliente: ${e.toString()}');
    }
  }

  /// Actualiza un cliente existente
  Future<void> actualizarCliente(int idCliente, Cliente cliente) async {
    try {
      await _supabase
          .from(_tableName)
          .update(cliente.toMap())
          .eq('id_cliente', idCliente);
    } on PostgrestException catch (e) {
      throw _handleSupabaseError('actualizar cliente', e);
    } catch (e) {
      throw Exception('Error inesperado al actualizar cliente: ${e.toString()}');
    }
  }

  /// Elimina un cliente por su ID
  Future<void> eliminarCliente(int idCliente) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id_cliente', idCliente);
    } on PostgrestException catch (e) {
      throw _handleSupabaseError('eliminar cliente', e);
    } catch (e) {
      throw Exception('Error inesperado al eliminar cliente: ${e.toString()}');
    }
  }

  /// Maneja los errores específicos de Supabase
  Exception _handleSupabaseError(String operation, PostgrestException e) {
    // Puedes agregar lógica específica para diferentes códigos de error aquí
    return Exception('Error al $operation: ${e.message}');
  }
}