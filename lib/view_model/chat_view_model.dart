import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_hn25/data/models/message_model.dart';
import 'package:p_hn25/data/network/gemini_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isInitializing = false; 
  String? _userId;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing; 

  void initializeChat(String userId) {
    _userId = userId;
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    if (_userId == null) return;

    _isInitializing = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(_userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      _messages = snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    } catch (e) {
//
    } finally {
      _isInitializing = false; // ✅ Finaliza el estado de inicialización
      notifyListeners();
    }
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
    _messages.insert(0, userMessage);
    notifyListeners();
    _saveMessageToFirestore(userMessage);

    // PASO B (INSTANTÁNEO): Mostrar el indicador de "escribiendo...".
    _isLoading = true;
    notifyListeners();

    final history = _messages.sublist(1).reversed.toList();

    // PASO C (EN ESPERA): Esperamos la respuesta de la IA.
    final responseText = await _geminiService.generateContent(history, text);

    // PASO D (FINAL): Mostrar la respuesta de la IA.
    final modelMessage = Message(
      text: responseText,
      role: 'model',
      timestamp: Timestamp.now(),
    );
    _messages.insert(0, modelMessage);

    _isLoading = false;
    notifyListeners();

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
    _isInitializing = false; 
    notifyListeners();
  }
}
