import 'package:flutter/material.dart';
import '../../payment/payment_form_screen.dart';

class PaymentRequestBubble extends StatelessWidget {
  final String title;       // 상품명
  final int price;          // 가격
  final String description; // 설명
  final bool isMe;          // 내가 보낸 메시지인지 여부

  const PaymentRequestBubble({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        width: 240, // 카드 고정 너비
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품명
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // 가격
            Text(
              "${price.toString()}원",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // 결제 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: [Backend 연결] PaymentFormScreen → 실제 결제 진행 화면으로 연결
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentFormScreen(
                        itemName: title,
                        totalAmount: price,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
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
