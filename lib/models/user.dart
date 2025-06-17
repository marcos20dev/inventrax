class User {
  final dynamic idUsuario; // nullable para registro donde no se envía
  final String name;
  final String lastName;
  final String email;
  final String password; // Usado solo para auth, NO se guarda en tabla usuarios_roles
  final String identityDocument;
  final String phone;

  User({
    this.idUsuario,  // opcional en constructor
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.identityDocument,
    required this.phone,
  });

  // Para enviar datos a la tabla usuarios_roles (registro)
  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'apellido': lastName,
      'correo_electronico': email,
      // No enviamos 'id_usuario' ni 'contraseña' aquí
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
    );
  }
  String get idUsuarioAsString => idUsuario?.toString() ?? '';

}
