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

  double precioVenta = 0.0;
  String get nombreProducto => nombre;


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




  Future<bool> updateProduct(Producto producto) async {
    isLoading = true;
    notifyListeners();

    try {
      if (producto.idProducto == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      await repository.updateProduct(producto);

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
