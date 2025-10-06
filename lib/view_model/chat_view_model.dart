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

    // Indicamos que estamos cargando el historial inicial.
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('chats')
        .doc(_userId)
        .collection('messages')
        // CAMBIO CLAVE 1: Ordenar por 'descending' para tener los más nuevos primero.
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();

    _messages = snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();

    // La carga inicial ha terminado.
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _userId == null || _isLoading) return;

    final userMessage = Message(
      text: text,
      role: 'user',
      timestamp: Timestamp.now(),
    );

    // CAMBIO CLAVE 2: Insertar el nuevo mensaje al principio de la lista (índice 0).
    _messages.insert(0, userMessage);
    await _saveMessageToFirestore(userMessage);

    // Renombramos la variable para mayor claridad.
    _isLoading = true;
    notifyListeners();

    final history = _messages.length > 1
        ? _messages.sublist(1).reversed.toList() // Excluimos el mensaje actual y revertimos para el contexto correcto
        : <Message>[];

    final responseText = await _geminiService.generateContent(history, text);

    final modelMessage = Message(
      text: responseText,
      role: 'model',
      timestamp: Timestamp.now(),
    );

    // CAMBIO CLAVE 3: Insertar la respuesta de la IA también al principio.
    _messages.insert(0, modelMessage);

    _isLoading = false;
    notifyListeners();

    await _saveMessageToFirestore(modelMessage);
  }

  Future<void> _saveMessageToFirestore(Message message) async {
    if (_userId == null || message.text.trim().isEmpty) return;
    await _firestore
        .collection('chats')
        .doc(_userId)
        .collection('messages')
        .add(message.toFirestore());
  }
}