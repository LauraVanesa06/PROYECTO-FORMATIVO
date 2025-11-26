class PasswordValidator {
  // Lista de contraseñas comunes y comprometidas
  static const List<String> commonPasswords = [
    '123456', 'password', '12345678', 'qwerty', '123456789',
    '12345', '1234', '111111', '1234567', 'dragon',
    '123123', 'baseball', 'iloveyou', 'trustno1', '1234567890',
    'sunshine', 'master', 'welcome', 'shadow', 'ashley',
    'football', 'jesus', 'michael', 'ninja', 'mustang',
    'password1', 'admin', 'letmein', 'monkey', 'abc123',
    '654321', 'superman', 'qazwsx', 'princess', 'azerty',
    'hello', 'charlie', 'donald', 'password123', 'qwerty123',
    'admin123', 'root', 'pass', 'test', 'guest',
  ];

  /// Valida si la contraseña es segura
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }

    // Verificar longitud mínima
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Verificar si está en la lista de contraseñas comunes
    if (commonPasswords.contains(password.toLowerCase())) {
      return 'Esta contraseña es muy común. Por favor elige una más segura';
    }

    // Verificar que tenga al menos una letra mayúscula
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    // Verificar que tenga al menos una letra minúscula
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }

    // Verificar que tenga al menos un número
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }

    // Verificar que tenga al menos un carácter especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'La contraseña debe contener al menos un carácter especial (!@#\$%^&*(),.?":{}|<>)';
    }

    return null; // Contraseña válida
  }

  /// Obtiene la fortaleza de la contraseña (0-100)
  static int getStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength += 20;
    if (password.length >= 12) strength += 10;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 15;
    if (password.contains(RegExp(r'[a-z]'))) strength += 15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 15;
    if (!commonPasswords.contains(password.toLowerCase())) strength += 10;

    return strength.clamp(0, 100);
  }

  /// Obtiene el nivel de fortaleza como texto
  static String getStrengthText(int strength) {
    if (strength < 30) return 'Muy débil';
    if (strength < 50) return 'Débil';
    if (strength < 70) return 'Media';
    if (strength < 90) return 'Fuerte';
    return 'Muy fuerte';
  }

  /// Obtiene el color según la fortaleza
  static int getStrengthColor(int strength) {
    if (strength < 30) return 0xFFD32F2F; // Rojo
    if (strength < 50) return 0xFFFF6F00; // Naranja
    if (strength < 70) return 0xFFFBC02D; // Amarillo
    if (strength < 90) return 0xFF7CB342; // Verde claro
    return 0xFF388E3C; // Verde oscuro
  }
}
