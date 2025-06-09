import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/categoria.dart';

class CategoriaRepository {
  final SupabaseClient supabase;

  CategoriaRepository(this.supabase);




  Future<List<Categoria>> getAll() async {
    try {
      final response = await supabase
          .from('categorias')
          .select()
          .order('id_categoria', ascending: true);

      return (response as List<dynamic>).map((e) => Categoria.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  Future<Categoria> insert(Categoria categoria) async {
    try {
      final nombreNormalizado = categoria.nombreCategoria.trim().toLowerCase();

      final categoriasExistentes = await supabase
          .from('categorias')
          .select()
          .ilike('nombre_categoria', nombreNormalizado);

      if (categoriasExistentes.isNotEmpty) {
        throw 'Ya existe una categoría con nombre: ${categoriasExistentes[0]['nombre_categoria']}';
      }

      final response = await supabase
          .from('categorias')
          .insert(categoria.toMap())
          .select()
          .single()
          .timeout(const Duration(seconds: 10));

      return Categoria.fromMap(response);
    } on TimeoutException {
      throw 'Tiempo de espera agotado. Intente nuevamente';
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw 'Esta categoría ya existe en el sistema';
      }
      throw 'Error de base de datos: ${e.message}';
    } catch (e) {
      throw e is String ? e : 'Error al crear la categoría';
    }
  }

  Future<Categoria> update(Categoria categoria) async {
    try {
      if (categoria.idCategoria == null) {
        throw ArgumentError('El ID de la categoría es requerido para actualizar');
      }

      final nombreNormalizado = categoria.nombreCategoria.trim().toLowerCase();

      // Busca categorías con el mismo nombre (case insensitive) excluyendo la actual
      final existing = await supabase
          .from('categorias')
          .select()
          .ilike('nombre_categoria', nombreNormalizado)
          .neq('id_categoria', categoria.idCategoria!)
          .limit(1);

      if (existing.isNotEmpty) {
        throw Exception('Ya existe una categoría con el nombre "${categoria.nombreCategoria}".');
      }

      final response = await supabase
          .from('categorias')
          .update(categoria.toMap())
          .eq('id_categoria', categoria.idCategoria!)
          .select()
          .single();

      return Categoria.fromMap(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> delete(int idCategoria) async {
    try {
      await supabase
          .from('categorias')
          .delete()
          .eq('id_categoria', idCategoria);
    } catch (e) {
      throw Exception('Error al eliminar la categoría: $e');
    }
  }

  Future<Categoria?> getById(int idCategoria) async {
    try {
      final response = await supabase
          .from('categorias')
          .select()
          .eq('id_categoria', idCategoria)
          .single();

      return Categoria.fromMap(response);
    } catch (e) {
      return null;
    }
  }
}