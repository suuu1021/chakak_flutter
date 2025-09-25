import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final String itemName;
  final int totalAmount;

  const PaymentSummaryCard({
    super.key,
    required this.itemName,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "₩$totalAmount",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(height: 24),
            const Text("포함 서비스",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            // TODO: [4] 현재는 하드코딩. 백엔드에서 옵션 리스트 받아서 출력해야 함
            const Text("✔ 스튜디오 촬영"),
            const Text("✔ 기본 의상 제공"),
            const Text("✔ 촬영본 전달"),
          ],
        ),
      ),
    );
  }
}
