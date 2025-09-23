import 'package:flutter/material.dart';

class PaymentSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const PaymentSubmitButton({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onSubmit,
        icon: const Icon(Icons.credit_card),
        label: const Text(
          "결제하기",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
