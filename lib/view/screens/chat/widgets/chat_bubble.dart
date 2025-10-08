import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:p_hn25/app/core/constants/app_colors.dart';
import 'package:p_hn25/data/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isUserMessage = message.role == 'user';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade600,
                    Colors.grey.shade800,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedRobot02,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: isUserMessage
                    ? LinearGradient(
                        colors: [
                          primaryColor,
                          Color.lerp(primaryColor, Colors.blue.shade600, 0.4)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          isDark ? Colors.grey.shade700 : Colors.white,
                          isDark ? Colors.grey.shade600 : Colors.grey.shade50,
                        ],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft:  isUserMessage
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  topRight:isUserMessage
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: [
                  if (!isUserMessage)
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  if (isUserMessage)
                    BoxShadow(
                      color: primaryColor.withAlpha(51),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color:
                      isUserMessage ? Colors.white : AppColors.textColor(context),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight:
                      isUserMessage ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withAlpha(204),
                    primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedUser,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}