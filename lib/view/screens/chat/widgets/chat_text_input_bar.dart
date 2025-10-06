import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';

class ChatTextInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;

  const ChatTextInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        final bool isLoading = viewModel.isLoading;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: isLoading
                          ? 'El asistente está respondiendo...'
                          : 'Escribe tu consulta sobre salud...',
                      border: InputBorder.none,
                      filled: false,
                      hintStyle: TextStyle(
                        color: isLoading
                            ? Colors.grey.shade400
                            : AppColors.textLightColor(context),
                        fontSize: 15,
                      ),
                    ),
                    onSubmitted: (_) => onSendMessage(),
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: AppColors.textColor(context),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isLoading
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade500,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              primaryColor,
                              Color.lerp(primaryColor, Colors.blue.shade600, 0.4)!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: primaryColor.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            HugeIcons.strokeRoundedSent,
                            color: Colors.white,
                            size: 20,
                          ),
                    onPressed: isLoading ? null : onSendMessage,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}