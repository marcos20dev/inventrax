class Cliente {
  final int? idCliente; // opcional, lo genera Supabase
  final String tipoCliente;
  final String? nombre;
  final String? apellido;
  final String? razonSocial;
  final String documentoIdentidad;
  final String telefono;
  final String correo;
  final String direccion;
  final DateTime? createdAt; // opcional, lo genera Supabase

  Cliente({
    this.idCliente,
    required this.tipoCliente,
    this.nombre,
    this.apellido,
    this.razonSocial,
    required this.documentoIdentidad,
    required this.telefono,
    required this.correo,
    required this.direccion,
    this.createdAt,
  });

  // Factory constructor para crear desde un mapa (JSON de Supabase)
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      idCliente: map['id_cliente'] as int?,
      tipoCliente: map['tipo_cliente'] ?? '',
      nombre: map['nombre'],
      apellido: map['apellido'],
      razonSocial: map['razon_social'],
      documentoIdentidad: map['documento_identidad'] ?? '',
      telefono: map['telefono'] ?? '',
      correo: map['correo'] ?? '',
      direccion: map['direccion'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  // Convertir a mapa para enviar a Supabase (sin id_cliente ni created_at)
  Map<String, dynamic> toMap() {
    return {
      'tipo_cliente': tipoCliente,
      'nombre': nombre,
      'apellido': apellido,
      'razon_social': razonSocial,
      'documento_identidad': documentoIdentidad,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
    };
  }
}
