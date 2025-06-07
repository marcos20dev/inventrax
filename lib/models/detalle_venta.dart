class DetalleVenta {
  final int? idDetalle; // lo genera Supabase
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleVenta({
    this.idDetalle,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  // Crear instancia desde un mapa (respuesta de Supabase)
  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      idDetalle: map['id_detalle'] as int?,
      idVenta: map['id_venta'] as int,
      idProducto: map['id_producto'] as int,
      cantidad: map['cantidad'] as int,
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  // Convertir a mapa para enviar a Supabase
  Map<String, dynamic> toMap() {
    return {
      'id_venta': idVenta,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
