class Proveedor {
  final int? idProveedor;
  final String nombreProveedor;
  final String telefono;
  final String correo;
  final String direccion;
  final DateTime? createdAt;

  Proveedor({
    this.idProveedor,
    required this.nombreProveedor,
    required this.telefono,
    required this.correo,
    required this.direccion,
    this.createdAt,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map) => Proveedor(
    idProveedor: map['id_proveedor'] as int?,
    nombreProveedor: map['nombre_proveedor'] as String,
    telefono: map['telefono'] as String,
    correo: map['correo'] as String,
    direccion: map['direccion'] as String,
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
  );

  Map<String, dynamic> toMap() {
    return {
      // id_proveedor no se envía, ya que es autoincremental en la base de datos
      'nombre_proveedor': nombreProveedor,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
      // created_at lo genera automáticamente la base de datos
    };
  }
}
