// lib/data/network/encryption_service.dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // ⚠️ IMPORTANTE: ¡NO USES ESTA CLAVE EN PRODUCCIÓN! ⚠️
  // Esta clave está hardcodeada solo para el ejemplo. En una aplicación real,
  // deberías obtener esta clave de un lugar seguro, como un Key Management Service (KMS),
  // o generarla y guardarla de forma segura en el dispositivo del usuario
  // usando flutter_secure_storage.
  // La clave DEBE ser de 16, 24 o 32 bytes para AES. Esta es de 32.
  static final _key = Key.fromUtf8('9xLqT!2zB#rN7pG@vS8yE5mH4dC1kW0Z');

  // Usamos AES en modo CBC. Es un estándar seguro.
  final Encrypter _encrypter = Encrypter(AES(_key));

  /// Encripta un texto plano.
  /// Devuelve una cadena combinada: "IV_en_base64:ciphertext_en_base64"
  String encrypt(String plainText) {
    // Genera un Initialization Vector (IV) aleatorio para cada encriptación.
    // Esto es crucial para la seguridad, asegura que encriptar el mismo texto
    // dos veces produzca resultados diferentes.
    final iv = IV.fromLength(16);

    final encrypted = _encrypter.encrypt(plainText, iv: iv);

    // Combinamos el IV y el texto encriptado para poder desencriptarlo después.
    // El IV no es secreto, es seguro guardarlo junto al mensaje.
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Desencripta una cadena combinada.
  String decrypt(String combined) {
    try {
      // Si el texto no contiene ':', asumimos que es un mensaje antiguo sin encriptar.
      if (!combined.contains(':')) {
        return combined;
      }

      final parts = combined.split(':');
      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return "Error: no se pudo leer el mensaje.";
    }
  }
}
