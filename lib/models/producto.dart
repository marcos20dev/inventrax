class Producto {
  final int? idProducto; // Se genera automáticamente en la BD
  final String nombreProducto;
  final String descripcion;
  final int cantidadDisponible;
  final String unidadMedida;
  final double precioVenta;
  final int idCategoria;
  final String codigoBarras;
  final DateTime? createdAt; // Se genera automáticamente en la BD

  Producto({
    this.idProducto,
    required this.nombreProducto,
    required this.descripcion,
    required this.cantidadDisponible,
    required this.unidadMedida,
    required this.precioVenta,
    required this.idCategoria,
    required this.codigoBarras,
    this.createdAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'] as int?,
      nombreProducto: json['nombre_producto'] as String,
      descripcion: json['descripcion'] as String,
      cantidadDisponible: json['cantidad_disponible'] as int,
      unidadMedida: json['unidad_medida'] as String,
      precioVenta: (json['precio_venta'] as num).toDouble(),
      idCategoria: json['id_categoria'] as int,
      codigoBarras: json['codigo_barras'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id_producto y created_at no se envían al crear registro porque son automáticos
      'nombre_producto': nombreProducto,
      'descripcion': descripcion,
      'cantidad_disponible': cantidadDisponible,
      'unidad_medida': unidadMedida,
      'precio_venta': precioVenta,
      'id_categoria': idCategoria,
      'codigo_barras': codigoBarras,
    };
  }
}
