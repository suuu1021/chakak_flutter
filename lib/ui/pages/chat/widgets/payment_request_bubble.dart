import 'package:flutter/material.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../payment/payment_form_screen.dart';

class PaymentRequestBubble extends StatelessWidget {
  final String title; // 상품명
  final int price; // 가격
  final String description; // 설명
  final bool isMe; // 내가 보낸 메시지인지
  final int bookingInfoId; // ✅ required

  const PaymentRequestBubble({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.isMe,
    required this.bookingInfoId, // ✅ required
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryLight : AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$price 원",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentFormScreen(
                        itemName: title,
                        totalAmount: price,
                        bookingInfoId: bookingInfoId, // ✅ 전달
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("결제"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
