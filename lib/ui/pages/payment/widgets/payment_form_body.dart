import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/widgets/custom_text_form_field.dart';
import 'package:chakak_flutter/ui/widgets/custom_text_area.dart';
import 'payment_summary_card.dart';
import 'payment_submit_button.dart';

class PaymentFormBody extends StatefulWidget {
  final String itemName;
  final int totalAmount;

  const PaymentFormBody({
    super.key,
    required this.itemName,
    required this.totalAmount,
  });

  @override
  State<PaymentFormBody> createState() => _PaymentFormBodyState();
}

class _PaymentFormBodyState extends State<PaymentFormBody> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 요약 카드
          PaymentSummaryCard(
            itemName: widget.itemName,
            totalAmount: widget.totalAmount,
          ),
          const SizedBox(height: 30),

          // 결제자 정보
          const Text("결제자 정보",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextFormField(hint: "이름", controller: _nameController),
          const SizedBox(height: 12),
          CustomTextFormField(hint: "이메일", controller: _emailController),
          const SizedBox(height: 12),
          CustomTextFormField(hint: "전화번호", controller: _phoneController),
          const SizedBox(height: 20),

          // 요청사항
          const Text("추가 요청사항",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          CustomTextArea(hint: "선택 입력", controller: _commentController),
          const SizedBox(height: 40),

          // 결제 버튼
          PaymentSubmitButton(
            onSubmit: () {
              // TODO: [1] 서버 API 호출 → 결제창 띄우기
              // TODO: [2] 성공/실패 분기
              //Navigator.pushNamed(context, '/payment-success');
              Navigator.pushNamed(context, '/payment-fail', arguments: "각종 사유");
            },
          ),
        ],
      ),
    );
  }
}
