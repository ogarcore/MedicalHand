import 'package:flutter/services.dart';

// Formateador para la Cédula de Nicaragua (XXX-XXXXXX-XXXXL)
class CedulaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String rawText = newValue.text.replaceAll('-', '');
    String filteredText = '';

    for (int i = 0; i < rawText.length; i++) {
      if (i < 13) {
        if (RegExp(r'^[0-9]$').hasMatch(rawText[i])) {
          filteredText += rawText[i];
        }
      } else if (i == 13) {
        if (RegExp(r'^[a-zA-Z]$').hasMatch(rawText[i])) {
          filteredText += rawText[i];
        }
      } else {
        break;
      }
    }

    final buffer = StringBuffer();
    for (int i = 0; i < filteredText.length; i++) {
      buffer.write(filteredText[i]);
      // Añadimos guion después del 3er y 9no caracter
      if ((i == 2 || i == 8) && i < filteredText.length - 1) {
        buffer.write('-');
      }
    }

    String formattedText = buffer.toString().toUpperCase();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Formateador para Fechas (DD/MM/AAAA)
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';

    if (text.length > 2) {
      newText += '${text.substring(0, 2)}/';
      if (text.length > 4) {
        newText += '${text.substring(2, 4)}/';
        if (text.length > 8) {
          newText += text.substring(4, 8);
        } else {
          newText += text.substring(4);
        }
      } else {
        newText += text.substring(2);
      }
    } else {
      newText += text;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Formateador para Número de Celular (0000-0000)
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';

    if (digitsOnly.length > 4) {
      newText =
          '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, digitsOnly.length > 8 ? 8 : digitsOnly.length)}';
    } else {
      newText = digitsOnly;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
