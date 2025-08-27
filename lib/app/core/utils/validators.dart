class AppValidators {
  // Validador para el correo electrónico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    // Expresión regular para validar el formato del correo
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingresa un correo válido.';
    }
    return null; // El valor es válido
  }

  // Validador para la contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null; // El valor es válido
  }

  // Validador para la confirmación de la contraseña
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Por favor, confirma tu contraseña.';
    }
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null; // El valor es válido
  }

  static String? validateGenericEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es un campo obligatorio.';
    }
    return null; // El valor es válido
  }

  // NUEVO: Validador para la Cédula de Identidad de Nicaragua
  static String? validateCedula(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es obligatoria.';
    }
    // El formato completo es XXX-XXXXXX-XXXXL, que tiene 16 caracteres.
    if (value.length != 16) {
      return 'El formato de la cédula no es válido.';
    }
    // Opcional: Una expresión regular más estricta por si acaso.
    final cedulaRegex = RegExp(r'^\d{3}-\d{6}-\d{4}[A-Z]$');
    if (!cedulaRegex.hasMatch(value)) {
      return 'El formato debe ser 001-123456-1234A.';
    }
    return null; // El valor es válido
  }

  // NUEVO: Validador para la Fecha de Nacimiento
  static String? validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha de nacimiento es obligatoria.';
    }
    if (value.length != 10) {
      return 'El formato debe ser DD/MM/AAAA.';
    }

    try {
      final parts = value.split('/');
      if (parts.length != 3) return 'Formato inválido.';

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Re-construimos la fecha para que Dart la valide (ej. no acepta día 32)
      final date = DateTime(year, month, day);

      // Verificamos que la fecha reconstruida coincida con la entrada
      if (date.day != day || date.month != month || date.year != year) {
        return 'La fecha no es válida (ej. 30/02/2023).';
      }

      // Verificamos el rango de años
      if (date.year < 1900) {
        return 'El año no puede ser anterior a 1900.';
      }
      if (date.isAfter(DateTime.now())) {
        return 'Fecha incorrecta, por favor introducir una correcta.';
      }
    } catch (e) {
      return 'Formato de fecha inválido.';
    }

    return null; // La fecha es válida
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de teléfono es obligatorio.';
    }
    // El formato es 0000-0000, que tiene 9 caracteres
    if (value.length != 9) {
      return 'El número de teléfono debe tener 8 dígitos.';
    }
    return null; // El valor es válido
  }

  // NUEVO: Validador para un teléfono opcional
  // Solo da error si el campo no está vacío pero está incompleto.
  static String? validateOptionalPhone(String? value) {
    // Si el campo está vacío o es nulo, es válido porque es opcional.
    if (value == null || value.isEmpty) {
      return null;
    }
    // Si el campo NO está vacío, entonces debe tener el formato correcto.
    if (value.length != 9) {
      return 'El número debe tener 8 dígitos.';
    }
    return null; // El valor es válido
  }

  static String? validateOptionalBloodType(String? value) {
    // 1. Si está vacío o nulo, es válido porque es opcional.
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // 2. Si tiene texto, validamos el formato.
    // Convertimos a mayúsculas para aceptar 'a+', 'ab-', etc.
    final upperValue = value.trim().toUpperCase();

    // Usamos una expresión regular que solo acepta A, B, AB, O seguido de + o -
    final bloodTypeRegex = RegExp(r'^(A|B|AB|O)[+-]$');

    if (!bloodTypeRegex.hasMatch(upperValue)) {
      return 'Formato inválido. Ejemplos: A+, O-, AB+';
    }

    return null; // El formato es válido
  }
}
