import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../repositories/producto_repository.dart';

class ProductoViewModel extends ChangeNotifier {
  final ProductoRepository repository;  // <-- Aquí está el repo

  ProductoViewModel({required this.repository});  // <-- constructor con parámetro

  bool isLoading = false;
  bool productoEncontrado = false;

  String codigoBarras = '';
  String nombre = '';
  String descripcion = '';
  String unidadMedida = 'unidad';

  // Para manejo de errores
  String? errorMessage;
  int? idProducto;

  double precioVenta = 0.0;
  String get nombreProducto => nombre;
  String getProductId() {
    return idProducto != null ? 'Producto ID: $idProducto' : 'ID no disponible';
  }

  int cantidadDisponible = 0;
  String categoria = '';
  int idCategoria = 0;
  List<Map<String, dynamic>> categorias = [];  // Mantener el tipo adecuado para categorías
  String? categoriaSeleccionada;  // Guardar el valor seleccionado de la categoría

  List<Producto> productos = [];  // Cambié el tipo a List<Producto>

  Future<void> allProductosV2() async {
    isLoading = true;
    notifyListeners();

    try {
      // Llamada a la función RPC en Supabase para obtener todos los productos
      final response = await repository.getAllProducts();
      if (response != null && response.isNotEmpty) {
        // Asignamos los productos a la lista
        productos = response;
        isLoading = false;
        notifyListeners();
      } else {
        // Si no hay productos, puedes manejarlo con un mensaje o lógica alternativa
        errorMessage = 'No se encontraron productos';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Error al obtener productos: $e';
      isLoading = false;
      notifyListeners();
    }
  }





  Future<void> fetchCategorias() async {
    try {
      final response = await repository.getCategorias();
      categorias = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      print('Error al obtener categorías: $e');
    }
  }

  // Método para obtener el producto por su ID
  Future<bool> fetchProductById(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final producto = await repository.getProductoPorId(id);

      if (producto != null) {
        idProducto = producto.idProducto; // Asegúrate de que se esté asignando correctamente
        nombre = producto.nombreProducto;
        descripcion = producto.descripcion ?? '';
        cantidadDisponible = producto.cantidadDisponible;
        precioVenta = producto.precioVenta;
        codigoBarras = producto.codigoBarras;
        idCategoria = producto.idCategoria;
        unidadMedida = producto.unidadMedida;

        // Asignar la categoría desde la base de datos
        final categorias = await repository.getCategorias();
        final categoria = categorias.firstWhere(
              (cat) => cat['id_categoria'] == producto.idCategoria,
          orElse: () => {'nombre_categoria': ''},
        );
        this.categoria = categoria['nombre_categoria'] ?? '';

        productoEncontrado = true;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        productoEncontrado = false;
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Error al obtener producto: $e';
      productoEncontrado = false;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }


  Future<bool> updateProduct(Producto producto) async {
    isLoading = true;
    notifyListeners();

    try {
      if (producto.idProducto == null) {
        errorMessage = 'El producto no tiene ID';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Actualizar el producto en el repositorio
      await repository.updateProduct(producto);

      // Almacenar el ID en el ViewModel
      idProducto = producto.idProducto;

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error al actualizar producto: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }


  Future<List<Producto>> getAllProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final productos = await repository.getAllProducts();
      isLoading = false;
      notifyListeners();
      return productos;
    } catch (e) {
      errorMessage = 'Error al obtener productos: $e';
      isLoading = false;
      notifyListeners();
      return [];
    }
  }


  Future<void> fetchProductInfoFromDB(String barcode) async {
    print('Buscando producto con código de barras: "$barcode"');  // <-- DEBUG    isLoading = true;
    notifyListeners();

    try {
      // Prueba buscar con un código fijo que sabes que existe
      final testCode = '1234567890123'; // Reemplaza por un código válido en tu DB
      final producto = await repository.getProductoPorCodigoBarras(testCode);

      print('Producto buscado en DB: $producto');

      if (producto != null) {
        codigoBarras = producto.codigoBarras ?? '';
        nombre = producto.nombreProducto;
        descripcion = producto.descripcion ?? '';
        unidadMedida = producto.unidadMedida ?? 'unidad';
        productoEncontrado = true;
        errorMessage = null;
      } else {
        productoEncontrado = false;
        errorMessage = 'Producto no encontrado';
      }
    } catch (e) {
      productoEncontrado = false;
      errorMessage = 'Error al buscar producto: $e';
      print('Error en fetchProductInfoFromDB: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }





// Agrega estas variables al ViewModel
  bool _fromApi = false;
  bool get fromApi => _fromApi;



  Future<void> fetchProductInfo(String barcode) async {
    // Resetear todos los valores antes de buscar
    nombre = '';
    descripcion = '';
    productoEncontrado = false;
    _fromApi = false;

    isLoading = true;
    notifyListeners();

    try {
      // Primero intenta buscar en la base de datos local
      final localProduct = await repository.getProductoPorCodigoBarras(barcode);

      if (localProduct != null) {
        nombre = localProduct.nombreProducto;
        descripcion = localProduct.descripcion ?? '';
        productoEncontrado = true;
      } else {
        // Si no está localmente, busca en la API
        final url = Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['code'] == 'OK' && data['total'] > 0) {
            final item = data['items'][0];
            nombre = item['title'] ?? '';
            descripcion = item['description'] ?? '';
            _fromApi = true;
            productoEncontrado = true;
          }
        }
      }
    } catch (e) {
      print('Error en fetchProductInfo: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



// Modifica el reset
  void reset() {
    codigoBarras = '';
    nombre = '';
    descripcion = '';
    unidadMedida = 'unidad';
    productoEncontrado = false;
    errorMessage = null;
    _fromApi = false;
    notifyListeners();
  }



  Future<bool> saveProduct({
    required Map<String, dynamic> producto,
    required Map<String, dynamic> entrada,
    required Map<String, dynamic> movimiento,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final int? productoId = await repository.insertProducto(producto);

      if (productoId == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      entrada['id_producto'] = productoId;
      movimiento['id_producto'] = productoId;

      await repository.insertEntradaProducto(entrada);
      await repository.insertMovimientoInventario(movimiento);

      isLoading = false;
      notifyListeners();
      return true;
    }catch (e) {
      print('Error detalle: $e');
      errorMessage = 'Error al guardar producto: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }

  }
  Future<bool> deleteProduct(int idProducto) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.deleteProduct(idProducto);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error al eliminar producto: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

}
