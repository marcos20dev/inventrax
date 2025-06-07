class MovimientoInventarioModel {
  final int? idMovimiento;
  final int idProducto;
  final int idUsuario;
  final String tipoMovimiento;
  final int cantidad;
  final DateTime fechaMovimiento;
  final String motivo;
  final String destinatario;
  final DateTime? createdAt;

  MovimientoInventarioModel({
    this.idMovimiento,
    required this.idProducto,
    required this.idUsuario,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.fechaMovimiento,
    required this.motivo,
    required this.destinatario,
    this.createdAt,
  });

  factory MovimientoInventarioModel.fromJson(Map<String, dynamic> json) {
    return MovimientoInventarioModel(
      idMovimiento: json['id_movimiento'],
      idProducto: json['id_producto'],
      idUsuario: json['id_usuario'],
      tipoMovimiento: json['tipo_movimiento'],
      cantidad: json['cantidad'],
      fechaMovimiento: DateTime.parse(json['fecha_movimiento']),
      motivo: json['motivo'],
      destinatario: json['destinatario'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'id_usuario': idUsuario,
      'tipo_movimiento': tipoMovimiento,
      'cantidad': cantidad,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      'motivo': motivo,
      'destinatario': destinatario,
    };
  }

  MovimientoInventarioModel copyWith({
    int? idMovimiento,
    int? idProducto,
    int? idUsuario,
    String? tipoMovimiento,
    int? cantidad,
    DateTime? fechaMovimiento,
    String? motivo,
    String? destinatario,
    DateTime? createdAt,
  }) {
    return MovimientoInventarioModel(
      idMovimiento: idMovimiento ?? this.idMovimiento,
      idProducto: idProducto ?? this.idProducto,
      idUsuario: idUsuario ?? this.idUsuario,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      cantidad: cantidad ?? this.cantidad,
      fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
      motivo: motivo ?? this.motivo,
      destinatario: destinatario ?? this.destinatario,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
