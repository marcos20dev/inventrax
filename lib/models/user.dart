class User {
  final dynamic idUsuario; // nullable para registro donde no se envía
  final String name;
  final String lastName;
  final String email;
  final String password; // Usado solo para auth, NO se guarda en tabla usuarios_roles
  final String identityDocument;
  final String phone;
  final int rolId; // <-- Nuevo campo agregado

  User({
    this.idUsuario,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.identityDocument,
    required this.phone,
    required this.rolId, // <-- Asegúrate de requerirlo
  });

  // Para enviar datos a la tabla usuarios_roles (registro)
  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'apellido': lastName,
      'correo_electronico': email,
      'documento_identidad': identityDocument,
      'telefono': phone,
    };
  }

  // Para crear instancia desde JSON (p. ej. login o consulta)
  factory User.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id_usuario'];
    return User(
      idUsuario: idRaw,
      name: json['nombre']?.toString() ?? '',
      lastName: json['apellido']?.toString() ?? '',
      email: json['correo_electronico']?.toString() ?? '',
      password: '',
      identityDocument: json['documento_identidad']?.toString() ?? '',
      phone: json['telefono']?.toString() ?? '',
      rolId: json['id_roles'] ?? 0, // <-- Agregado desde el JSON
    );
  }

  String get idUsuarioAsString => idUsuario?.toString() ?? '';
}
