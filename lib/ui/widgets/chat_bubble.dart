import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../_core/constants/app_colors.dart'; // AppColors import 추가

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : AppColors
                  .gray200, // Theme.of(context).primaryColor → AppColors.primary, Colors.grey[300] → AppColors.gray200
          borderRadius: isMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe
                    ? AppColors.textOnPrimary
                    : AppColors
                        .textPrimary, // Colors.white → AppColors.textOnPrimary, Colors.black → AppColors.textPrimary
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: TextStyle(
                color: isMe
                    ? AppColors.textOnPrimary.withOpacity(0.7)
                    : AppColors
                        .textSecondary, // Colors.white70 → AppColors.textOnPrimary.withOpacity(0.7), Colors.black54 → AppColors.textSecondary
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
