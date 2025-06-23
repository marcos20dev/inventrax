class Producto {
  final int? idProducto;
  final String nombreProducto;
  String? descripcion; // Hacer descripcion nullable
  final int cantidadDisponible; // Esta es la que representa el stock actual
  final String unidadMedida;
  final double precioVenta;
  final int idCategoria;
  final String codigoBarras;
  final DateTime? createdAt;
  String? categoria; // Nueva propiedad para el nombre de la categoría

  Producto({
    this.idProducto,
    required this.nombreProducto,
    this.descripcion, // Cambiar para que pueda ser null
    required this.cantidadDisponible,
    required this.unidadMedida,
    required this.precioVenta,
    required this.idCategoria,
    required this.codigoBarras,
    this.createdAt,
    this.categoria, // Agregar al constructor
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'] as int?,
      nombreProducto: json['nombre_producto'] as String,
      descripcion: json['descripcion'] as String?, // Descripción nullable
      cantidadDisponible: json['cantidad_disponible'] as int,
      unidadMedida: json['unidad_medida'] as String,
      precioVenta: (json['precio_venta'] as num).toDouble(),
      idCategoria: json['id_categoria'] as int,
      codigoBarras: json['codigo_barras'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      categoria: json['categorias'] != null
          ? json['categorias']['nombre_categoria'] as String?
          : null, // Asigna el nombre de la categoría
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_producto': nombreProducto,
      'descripcion': descripcion, // Permitir que sea null
      'cantidad_disponible': cantidadDisponible,
      'unidad_medida': unidadMedida,
      'precio_venta': precioVenta,
      'id_categoria': idCategoria,
      'codigo_barras': codigoBarras,
    };
  }
}
