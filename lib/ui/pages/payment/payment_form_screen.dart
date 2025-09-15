import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/widgets/custom_text_form_field.dart';
import 'package:chakak_flutter/ui/widgets/custom_text_area.dart';

class PaymentFormScreen extends StatefulWidget {
  final int amount; // 포토그래퍼가 전달한 결제 금액

  const PaymentFormScreen({super.key, required this.amount});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentController = TextEditingController();

  final Color primaryColor = const Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("결제하기"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 아이콘 + 제목
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.payment, size: 48, color: primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        "결제 정보 입력",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 이름
                CustomTextFormField(
                  hint: "이름",
                  controller: _nameController,
                ),
                const SizedBox(height: 16),

                // 이메일
                CustomTextFormField(
                  hint: "이메일",
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                // 연락처
                CustomTextFormField(
                  hint: "전화번호",
                  controller: _phoneController,
                ),
                const SizedBox(height: 24),

                // 결제 금액 (읽기 전용)
                Text(
                  "결제 금액",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${widget.amount.toString()} 원",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),

                // 요청사항
                CustomTextArea(
                  hint: "추가 요청사항 (선택)",
                  controller: _commentController,
                ),
                const SizedBox(height: 32),

                // 결제 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      debugPrint("이름: ${_nameController.text}");
                      debugPrint("이메일: ${_emailController.text}");
                      debugPrint("전화번호: ${_phoneController.text}");
                      debugPrint("금액: ${widget.amount}");
                      debugPrint("요청사항: ${_commentController.text}");
                      // TODO: Toss API 결제 요청 로직 연결
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text(
                      "결제하기",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
