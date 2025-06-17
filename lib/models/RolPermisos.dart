class RolPermisoModel {
  final int? id;
  final int rolId;
  final int permisoId;
  final bool estado;
  final DateTime? createdAt;

  RolPermisoModel({
    this.id,
    required this.rolId,
    required this.permisoId,
    required this.estado,
    this.createdAt,
  });

  factory RolPermisoModel.fromMap(Map<String, dynamic> map) {
    return RolPermisoModel(
      id: map['id_rol_permisos'],
      rolId: map['rol_id'],
      permisoId: map['id_permisos'],
      estado: map['estado'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rol_id': rolId,
      'id_permisos': permisoId,
      'estado': estado,
    };
  }
}
