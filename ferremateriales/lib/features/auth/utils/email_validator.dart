class EmailValidator {
  /// Valida el formato de un email
  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return 'El correo electrónico es requerido';
    }

    // Remover espacios en blanco
    email = email.trim();

    // Verificar longitud mínima
    if (email.length < 5) {
      return 'El correo electrónico es demasiado corto';
    }

    // Verificar formato básico
    if (!email.contains('@')) {
      return 'El correo debe contener el símbolo @';
    }

    // Regex completo para validar formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'El formato del correo electrónico no es válido';
    }

    // Verificar que tenga un punto después del @
    final parts = email.split('@');
    if (parts.length != 2) {
      return 'El correo electrónico no es válido';
    }

    final domain = parts[1];
    if (!domain.contains('.')) {
      return 'El dominio del correo debe contener un punto';
    }

    // Verificar que el dominio no sea muy corto
    final domainParts = domain.split('.');
    if (domainParts.last.length < 2) {
      return 'El dominio del correo no es válido';
    }

    return null; // Email válido
  }

  /// Normaliza el email (trim y lowercase)
  static String normalize(String email) {
    return email.trim().toLowerCase();
  }
}
