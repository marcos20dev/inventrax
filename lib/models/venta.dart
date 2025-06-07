class Venta {
  final int? idVenta; // generado por Supabase
  final int idCliente;
  final int idUsuario;
  final DateTime fechaVenta;
  final double total;
  final String estado;
  final DateTime? createdAt; // generado automáticamente

  Venta({
    this.idVenta,
    required this.idCliente,
    required this.idUsuario,
    required this.fechaVenta,
    required this.total,
    required this.estado,
    this.createdAt,
  });

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      idVenta: map['id_venta'] as int?, // Permite que id_venta sea null
      idCliente: map['id_cliente'] != null ? map['id_cliente'] as int : 0, // Manejo de null para id_cliente
      idUsuario: map['id_usuario'] != null ? map['id_usuario'] as int : 0, // Manejo de null para id_usuario
      fechaVenta: DateTime.parse(map['fecha_venta'] ?? DateTime.now().toIso8601String()), // Aseguramos que no sea null
      total: (map['total'] as num?)?.toDouble() ?? 0.0, // Si total es null, asignamos 0.0
      estado: map['estado'] ?? 'completado', // Valor por defecto si estado es null
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cliente': idCliente,
      'id_usuario': idUsuario,
      'fecha_venta': fechaVenta.toIso8601String(),
      'total': total,
      'estado': estado,
    };
  }
}
