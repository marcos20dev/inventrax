class EntradaProductoModel {
  final int? idEntrada;
  final int idProducto;
  final int idProveedor;
  final int cantidad;
  final DateTime fechaEntrada;
  final double precioCompra;
  final DateTime? createdAt;

  EntradaProductoModel({
    this.idEntrada,
    required this.idProducto,
    required this.idProveedor,
    required this.cantidad,
    required this.fechaEntrada,
    required this.precioCompra,
    this.createdAt,
  });

  factory EntradaProductoModel.fromJson(Map<String, dynamic> json) {
    return EntradaProductoModel(
      idEntrada: json['id_entrada'],
      idProducto: json['id_producto'],
      idProveedor: json['id_proveedor'],
      cantidad: json['cantidad'],
      fechaEntrada: DateTime.parse(json['fecha_entrada']),
      precioCompra: (json['precio_compra'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'id_proveedor': idProveedor,
      'cantidad': cantidad,
      'fecha_entrada': fechaEntrada.toIso8601String(),
      'precio_compra': precioCompra,
    };
  }

  EntradaProductoModel copyWith({
    int? idEntrada,
    int? idProducto,
    int? idProveedor,
    int? cantidad,
    DateTime? fechaEntrada,
    double? precioCompra,
    DateTime? createdAt,
  }) {
    return EntradaProductoModel(
      idEntrada: idEntrada ?? this.idEntrada,
      idProducto: idProducto ?? this.idProducto,
      idProveedor: idProveedor ?? this.idProveedor,
      cantidad: cantidad ?? this.cantidad,
      fechaEntrada: fechaEntrada ?? this.fechaEntrada,
      precioCompra: precioCompra ?? this.precioCompra,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
