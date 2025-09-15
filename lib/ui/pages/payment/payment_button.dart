import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/payment/payment_provider.dart';

class PaymentButton extends ConsumerWidget {
  final int bookingInfoId;
  final String itemName;
  final int price;

  const PaymentButton({
    Key? key,
    required this.bookingInfoId,
    required this.itemName,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentProvider);

    return ElevatedButton(
      onPressed:
          paymentState.isLoading ? null : () => _onPaymentPressed(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4A460),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: paymentState.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              '${_formatPrice(price)} 결제하기',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  void _onPaymentPressed(BuildContext context, WidgetRef ref) async {
    // 결제 시작
    await ref.read(paymentProvider.notifier).startPayment(bookingInfoId);

    // 에러 처리
    final paymentState = ref.read(paymentProvider);
    if (paymentState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentState.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatPrice(int price) {
    return '₩${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
