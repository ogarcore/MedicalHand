import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_hn25/data/network/encryption_service.dart';

class Message {
  String text;
  final String role;
  final Timestamp timestamp;

  Message({required this.text, required this.role, required this.timestamp});

  // --- MODIFICADO: Desencripta el texto al leerlo de Firestore ---
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    final encryptionService = EncryptionService();
    
    // Desencripta el texto antes de crear el objeto
    final decryptedText = encryptionService.decrypt(data['text'] ?? '');

    return Message(
      text: decryptedText, // Usa el texto ya desencriptado
      role: data['role'] ?? 'user',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // --- MODIFICADO: Encripta el texto al guardarlo en Firestore ---
  Map<String, dynamic> toFirestore() {
    final encryptionService = EncryptionService();
    
    // Encripta el texto antes de enviarlo a la base de datos
    final encryptedText = encryptionService.encrypt(text);

    return {
      'text': encryptedText, // Guarda el texto ya encriptado
      'role': role,
      'timestamp': timestamp,
    };
  }
}