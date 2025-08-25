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
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Por favor, confirma tu contraseña.';
    }
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null; // El valor es válido
  }
}