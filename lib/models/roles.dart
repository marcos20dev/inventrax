class Role {
  final int? idRoles; // Ahora nullable
  final String? nombre;
  final DateTime createdAt;

  Role({
    this.idRoles, // No es requerido al crear
    required this.nombre,
    required this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      idRoles: json['id_roles'] as int?,
      nombre: json['nombre'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = <String, dynamic>{
      'nombre': nombre,
      'created_at': createdAt.toIso8601String(),
    };
    if (includeId && idRoles != null) {
      data['id_roles'] = idRoles;
    }
    return data;
  }
}
