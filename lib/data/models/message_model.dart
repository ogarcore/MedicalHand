import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String text;
  final String role;
  final Timestamp timestamp;

  Message({required this.text, required this.role, required this.timestamp});

  // Factory para crear un Message desde un documento de Firestore
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      text: data['text'] ?? '',
      role: data['role'] ?? 'user',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Método para convertir un Message a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {'text': text, 'role': role, 'timestamp': timestamp};
  }
}
