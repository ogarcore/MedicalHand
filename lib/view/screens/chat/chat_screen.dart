import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/chat_bubble.dart';
import 'widgets/chat_disclaimer_banner.dart';
import 'widgets/chat_info_dialog.dart';
import 'widgets/chat_text_input_bar.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<ChatViewModel>(context, listen: false).initializeChat(userId);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final viewModel = Provider.of<ChatViewModel>(context, listen: false);
    if (_textController.text.trim().isNotEmpty && !viewModel.isLoading) {
      _focusNode.unfocus();
      viewModel.sendMessage(_textController.text.trim());
      _textController.clear();
      // CAMBIO CLAVE 4: Animamos al principio de la lista (que ahora es el final visible).
      _scrollToLatestMessage();
    }
  }

  // La función ahora se desplaza a la posición 0.0, que es el final en una lista invertida.
  void _scrollToLatestMessage() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const ChatInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text(
          'Asistente Virtual',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.3),
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                Color.lerp(primaryColor, Colors.blue.shade600, 0.4)!,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(HugeIcons.strokeRoundedCovidInfo, color: Colors.white, size: 22),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(HugeIcons.strokeRoundedInformationCircle, color: primaryColor, size: 18),
            ),
            onPressed: _showInfoDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const ChatDisclaimerBanner(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(colors: [Colors.grey.shade900, Colors.grey.shade800.withAlpha(204)])
                    : const LinearGradient(colors: [Color(0xFFF8FAFD), Color(0xFFF0F4F8)]),
              ),
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  // CAMBIO CLAVE 5: Se elimina la llamada a `_scrollToBottom` de aquí.

                  // Mostramos el estado inicial mientras se carga el historial.
                  if (viewModel.isLoading && viewModel.messages.isEmpty) {
                    return _buildInitialState();
                  }

                  // Mostramos un mensaje si no hay historial.
                  if (!viewModel.isLoading && viewModel.messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    // CAMBIO CLAVE 6: La propiedad 'reverse' invierte la lista visualmente.
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: viewModel.messages.length + (viewModel.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // El indicador de "escribiendo" ahora va al principio de la lista.
                      if (viewModel.isLoading && index == 0) {
                        return const TypingIndicator();
                      }
                      
                      // Ajustamos el índice para acceder a los mensajes.
                      final messageIndex = viewModel.isLoading ? index - 1 : index;
                      final message = viewModel.messages[messageIndex];
                      return ChatBubble(message: message);
                    },
                  );
                },
              ),
            ),
          ),
          ChatTextInputBar(
            controller: _textController,
            focusNode: _focusNode,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  // Un widget para el estado inicial de carga.
  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator());
  }
  
  // Un widget para cuando no hay mensajes.
  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor(context),
                  Color.lerp(AppColors.primaryColor(context), Colors.blue.shade600, 0.4)!,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              HugeIcons.strokeRoundedRobot01,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu asistente de salud',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haz tu primera consulta de bienestar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLightColor(context),
            ),
          ),
        ],
      ),
    );
  }
}