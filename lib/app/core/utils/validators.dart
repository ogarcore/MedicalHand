class AppValidators {
  /// Valida que el correo electrónico no esté vacío y que tenga un formato válido.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingresa un correo válido.';
    }
    return null;
  }

  /// Valida que la contraseña no esté vacía y que cumpla con un largo mínimo.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null;
  }

  /// Valida que la confirmación de la contraseña coincida con la contraseña original.
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
    return null;
  }

  /// Valida que un campo de texto genérico no esté vacío o contenga solo espacios en blanco.
  static String? validateGenericEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es un campo obligatorio.';
    }
    return null;
  }

  /// Valida el formato de la Cédula de Identidad de Nicaragua (ej. 001-123456-1234A).
  static String? validateCedula(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es obligatoria.';
    }
    if (value.length != 16) {
      return 'El formato de la cédula no es válido.';
    }
    final cedulaRegex = RegExp(r'^\d{3}-\d{6}-\d{4}[A-Z]$');
    if (!cedulaRegex.hasMatch(value)) {
      return 'El formato debe ser 001-123456-1234A.';
    }
    return null;
  }

  /// Valida la fecha de nacimiento para el formato DD/MM/AAAA y su validez.
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
      final date = DateTime(year, month, day);

      if (date.day != day || date.month != month || date.year != year) {
        return 'La fecha no es válida (ej. 30/02/2023).';
      }
      if (date.year < 1900) {
        return 'El año no puede ser anterior a 1900.';
      }
      if (date.isAfter(DateTime.now())) {
        return 'Fecha incorrecta, favor introducir una correcta.';
      }
    } catch (e) {
      return 'Formato de fecha inválido.';
    }

    return null;
  }

  /// Valida que el número de teléfono tenga 8 dígitos.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de teléfono es obligatorio.';
    }
    if (value.length != 9) {
      return 'El número de teléfono debe tener 8 dígitos.';
    }
    return null;
  }

  /// Valida un número de teléfono que es opcional.
  static String? validateOptionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length != 9) {
      return 'El número debe tener 8 dígitos.';
    }
    return null;
  }

  /// Valida el formato del tipo de sangre.
  static String? validateOptionalBloodType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final upperValue = value.trim().toUpperCase();
    final bloodTypeRegex = RegExp(r'^(A|B|AB|O)[+-]$');

    if (!bloodTypeRegex.hasMatch(upperValue)) {
      return 'Formato inválido. Ejemplos: A+, O-, AB+';
    }

    return null;
  }

  /// Valida la razón para reprogramar una cita, asegurando que no esté vacía y tenga un mínimo de caracteres.
  static String? validateRescheduleReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El motivo es obligatorio.';
    }
    if (value.trim().length < 10) {
      return 'El motivo debe tener al menos 10 caracteres.';
    }
    return null;
  }
}
