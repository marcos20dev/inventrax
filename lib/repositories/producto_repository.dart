import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/entrada_producto.dart';
import '../models/movimiento_inventario.dart';
import '../models/producto.dart';

class ProductoRepository {
  final SupabaseClient _supabase = Supabase.instance.client;



  // Obtener producto por código de barras
  Future<Producto?> getProductoPorCodigoBarras(String codigoBarras) async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .eq('codigo_barras', codigoBarras)
          .maybeSingle();

      print('Respuesta Supabase para código $codigoBarras: $response');  // <-- Agrega esto

      if (response != null) {
        return Producto.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error en getProductoPorCodigoBarras: $e');
      throw Exception('Error al buscar producto por código de barras: $e');
    }
  }




  // Método para insertar producto (usado en ViewModel)
  Future<int?> insertProducto(Map<String, dynamic> producto) async {
    final response = await _supabase
        .from('productos')
        .insert(producto)
        .select('id_producto')
        .single();
    return response != null ? response['id_producto'] as int : null;
  }

  // Método para insertar entrada de producto
  Future<void> insertEntradaProducto(Map<String, dynamic> entrada) async {
    await _supabase.from('entradas_producto').insert(entrada);
  }

  // Método para insertar movimiento de inventario
  Future<void> insertMovimientoInventario(Map<String, dynamic> movimiento) async {
    await _supabase.from('movimientos_inventario').insert(movimiento);
  }

  // Crear producto con entrada y movimiento (existente)
  Future<int> createProduct(
      Producto producto, {
        required EntradaProductoModel entrada,
        required MovimientoInventarioModel movimiento,
      }) async {
    try {
      final response = await _supabase
          .from('productos')
          .insert(producto.toJson())
          .select('id_producto')
          .single();

      final int idProducto = response['id_producto'] as int;

      final entradaData = entrada.copyWith(idProducto: idProducto);
      await _supabase.from('entradas_producto').insert(entradaData.toJson());

      final movimientoData = movimiento.copyWith(idProducto: idProducto);
      await _supabase.from('movimientos_inventario').insert(movimientoData.toJson());

      return idProducto;
    } catch (e) {
      throw Exception('Error al crear producto con inventario: $e');
    }
  }

  Future<List<Producto>> getAllProducts() async {
    try {
      final response = await _supabase.from('productos').select();
      return (response as List).map((e) => Producto.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<void> updateProduct(Producto producto) async {
    try {
      await _supabase
          .from('productos')
          .update(producto.toJson())
          .eq('id_producto', producto.idProducto!);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProduct(int idProducto) async {
    try {
      await _supabase
          .from('productos')
          .delete()
          .eq('id_producto', idProducto);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }
}
