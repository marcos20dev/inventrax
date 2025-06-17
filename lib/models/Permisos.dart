class PermisoModel {
  final int id;
  final String nombre;
  final String modulo;
  final DateTime createdAt;

  PermisoModel({
    required this.id,
    required this.nombre,
    required this.modulo,
    required this.createdAt,
  });

  factory PermisoModel.fromMap(Map<String, dynamic> map) {
    return PermisoModel(
      id: map['id_permisos'],
      nombre: map['nombre'] ?? '',
      modulo: map['modulo'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'modulo': modulo,
    };
  }
}
