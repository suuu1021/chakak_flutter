import 'package:flutter/material.dart';
import 'widgets/payment_form_body.dart';

class PaymentFormScreen extends StatelessWidget {
  final String itemName;
  final int totalAmount;
  final int bookingInfoId;

  const PaymentFormScreen({
    super.key,
    required this.itemName,
    required this.totalAmount,
    required this.bookingInfoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("결제 요청"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PaymentFormBody(
        itemName: itemName,
        totalAmount: totalAmount,
        bookingInfoId: bookingInfoId,
      ),
    );
  }
}
