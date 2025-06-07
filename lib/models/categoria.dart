class Categoria {
  final int? idCategoria;
  final String nombreCategoria;
  final DateTime? createdAt;

  Categoria({
    this.idCategoria,
    required this.nombreCategoria,
    this.createdAt,
  });

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
    idCategoria: map['id_categoria'] as int?,
    nombreCategoria: map['nombre_categoria'] as String,
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
  );

  Map<String, dynamic> toMap() {
    return {
      // id_categoria no se envía, ya que es autoincremental en DB
      'nombre_categoria': nombreCategoria,
      // created_at lo genera automáticamente la base de datos
    };
  }
}
