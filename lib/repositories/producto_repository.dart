import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/entrada_producto.dart';
import '../models/movimiento_inventario.dart';
import '../models/producto.dart';

class ProductoRepository {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> getAllProductos() async {
    try {
      final response = await _supabase.rpc('get_all_productos');

      // Verifica si la respuesta contiene datos
      if (response != null && response is List) {
        return response.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('No se encontraron productos');
      }
    } catch (e) {
      throw Exception('Error al obtener todos los productos');
    }
  }




  Future<bool> eliminarProducto(String productoId) async {
    try {
      if (productoId.isEmpty) return false;

      final id = int.tryParse(productoId);
      if (id == null) return false;

      // Eliminar el producto y obtener los registros borrados
      final deletedItems = await _supabase
          .from('productos')
          .delete()
          .eq('id_producto', id)
          .select();  // Devuelve los registros eliminados

      // Si `deletedItems` no está vacío, significa que se eliminó algo
      return deletedItems.isNotEmpty;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }


  Future<Producto?> getProductoPorId(int idProducto) async {
    try {
      final response = await _supabase
          .from('productos')
          .select('''
          id_producto, 
          nombre_producto, 
          descripcion, 
          cantidad_disponible, 
          unidad_medida, 
          precio_venta, 
          id_categoria, 
          codigo_barras,
          categorias(nombre_categoria)
        ''')
          .eq('id_producto', idProducto)
          .single();

      if (response != null) {
        final producto = Producto.fromJson(response);
        // Obtener el nombre de la categoría desde la relación
        if (response['categorias'] != null) {
          producto.categoria = response['categorias']['nombre_categoria'] as String;
        }
        return producto;
      }
      return null;
    } catch (e) {
      print('Error al obtener el producto: $e');
      throw Exception('Error al obtener el producto');
    }
  }


  Future<List<Map<String, dynamic>>> getCategorias() async {
    try {
      // Consulta usando select()
      final response = await _supabase
          .from('categorias')
          .select()
          .limit(100) // Limita los resultados si lo deseas
          .order('created_at'); // Ordena si es necesario (opcional)

      // Verifica si la respuesta tiene datos
      if (response != null && response is List) {
        return response.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('No se encontraron categorías');
      }
    } catch (e) {
      print('Error en getCategorias: $e');
      throw Exception('Error al obtener categorías: $e');
    }
  }


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


  Future<void> aumentarStockProducto({
    required int idProducto,
    required int cantidad,
    required int idProveedor,
    required double precioCompra,
    required String idUsuario,
  }) async {
    try {
      final response = await _supabase.rpc('actualizar_stock_producto', params: {
        'p_id_producto': idProducto,
        'p_cantidad': cantidad,
        'p_id_proveedor': idProveedor,
        'p_precio_compra': precioCompra,
        'p_id_usuario': idUsuario,
      });

      if (response != null) {
        // Aquí puedes procesar el producto actualizado
        final updatedProducto = Producto.fromJson(response[0]);
        // Actualiza el estado o la UI con los nuevos datos del producto
      } else {
      }
    } catch (e) {
      rethrow;
    }
  }





}
