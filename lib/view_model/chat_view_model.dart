import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_hn25/data/models/message_model.dart';
import 'package:p_hn25/data/network/gemini_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _userId;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void initializeChat(String userId) {
    _userId = userId;
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('chats')
        .doc(_userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();
    _messages = snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();

    _isLoading = false;
    notifyListeners();
  }

  // --- MÉTODO sendMessage COMPLETAMENTE REESTRUCTURADO ---
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _userId == null || _isLoading) return;

    // PASO A (INSTANTÁNEO): Mostrar el mensaje del usuario.
    final userMessage = Message(
      text: text,
      role: 'user',
      timestamp: Timestamp.now(),
    );
    // Se inserta al principio de la lista (porque la UI está invertida).
    _messages.insert(0, userMessage);
    // Notificamos a la UI INMEDIATAMENTE para que la burbuja del usuario aparezca.
    notifyListeners();
    // Guardamos en la base de datos en segundo plano, sin esperar (await).
    _saveMessageToFirestore(userMessage);

    // PASO B (INSTANTÁNEO): Mostrar el indicador de "escribiendo...".
    _isLoading = true;
    // Notificamos de nuevo para que el 'ListView' muestre el TypingIndicator.
    notifyListeners();

    // Preparamos el historial para la IA. Excluimos el mensaje que acabamos de enviar
    // y lo revertimos para que la conversación tenga el orden cronológico correcto.
    final history = _messages.sublist(1).reversed.toList();

    // PASO C (EN ESPERA): Esperamos la respuesta de la IA.
    final responseText = await _geminiService.generateContent(history, text);

    // PASO D (FINAL): Mostrar la respuesta de la IA.
    final modelMessage = Message(
      text: responseText,
      role: 'model',
      timestamp: Timestamp.now(),
    );
    // Añadimos la respuesta de la IA al principio de la lista.
    _messages.insert(0, modelMessage);

    // Indicamos que la carga ha terminado.
    _isLoading = false;
    // La notificación final reconstruirá la UI, quitando el TypingIndicator
    // y mostrando la burbuja de la IA en su lugar.
    notifyListeners();

    // Guardamos la respuesta de la IA en segundo plano.
    _saveMessageToFirestore(modelMessage);
  }

  Future<void> _saveMessageToFirestore(Message message) async {
    if (_userId == null || message.text.trim().isEmpty) return;
    await _firestore
        .collection('chats')
        .doc(_userId)
        .collection('messages')
        .add(message.toFirestore());
  }

  void clearChatOnSignOut() {
    _messages = [];
    _userId = null;
    _isLoading = false;
    notifyListeners();
  }
}
