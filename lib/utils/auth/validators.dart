bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String? password) {
  if (password == null || password.isEmpty) return false;
  return password.length >= 6;
}

//para el form de registro
bool isValidNameOrSurname(String? value) {
  if (value == null) return false;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.length < 2 || trimmed.length > 20) return false;
  // Solo letras (mayúsculas, minúsculas), espacios y acentos (áéíóúüñÁÉÍÓÚÜÑ)
  final regex = RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$");
  return regex.hasMatch(trimmed);
}

bool isValidDNI(String? dni) {
  if (dni == null) return false;
  final trimmed = dni.trim();
  if (trimmed.length != 8) return false;
  if (!RegExp(r'^\d{8}$').hasMatch(trimmed)) return false;
  // No permitir secuencias repetidas como 99999999, 88888888, etc.
  if (RegExp(r'^(\d)\1{7}$').hasMatch(trimmed)) return false;
  return true;
}

bool isValidMobilePhone(String? phone) {
  if (phone == null) return false;
  final trimmed = phone.trim();
  if (trimmed.length != 9) return false;
  if (!RegExp(r'^\d{9}$').hasMatch(trimmed)) return false;
  if (!trimmed.startsWith('9')) return false;
  // No permitir secuencias repetidas como 999999999, 888888888, etc.
  if (RegExp(r'^(\d)\1{8}$').hasMatch(trimmed)) return false;
  return true;
}
