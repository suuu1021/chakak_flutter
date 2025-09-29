import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'payment_summary_card.dart';
import 'payment_submit_button.dart';
import 'package:chakak_flutter/provider/auth/session_provider.dart';

class PaymentFormBody extends ConsumerStatefulWidget {
  final String itemName;
  final int totalAmount;
  final int bookingInfoId;

  const PaymentFormBody({
    super.key,
    required this.itemName,
    required this.totalAmount,
    required this.bookingInfoId,
  });

  @override
  ConsumerState<PaymentFormBody> createState() => _PaymentFormBodyState();
}

class _PaymentFormBodyState extends ConsumerState<PaymentFormBody> {
  Future<void> _startPayment() async {
    try {
      final token = ref.read(sessionProvider).jwtToken;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인이 필요합니다.")),
        );
        return;
      }

      final dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));
      final response = await dio.post(
        "/api/payment/ready",
        data: {"bookingInfoId": widget.bookingInfoId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final data = response.data['body'];
      final redirectUrl = data['nextRedirectMobileUrl'];
      if (redirectUrl == null || redirectUrl.toString().isEmpty) {
        throw "카카오페이 리다이렉트 URL이 없습니다.";
      }

      final uri = Uri.parse(redirectUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw "카카오페이 결제창을 열 수 없습니다.";
      }
    } catch (e) {
      debugPrint("결제 준비 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("결제 요청 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummaryCard(
            itemName: widget.itemName,
            totalAmount: widget.totalAmount,
          ),
          const SizedBox(height: 30),
          PaymentSubmitButton(onSubmit: _startPayment),
        ],
      ),
    );
  }
}
