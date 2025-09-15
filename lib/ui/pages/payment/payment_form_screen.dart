import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/widgets/custom_text_form_field.dart';
import 'package:chakak_flutter/ui/widgets/custom_text_area.dart';

class PaymentFormScreen extends StatefulWidget {
  final String itemName;
  final int totalAmount;

  const PaymentFormScreen({
    super.key,
    required this.itemName,
    required this.totalAmount,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentController = TextEditingController();

  // TODO [5]: 폼 전체 유효성 검증을 위해 GlobalKey<FormState> 추가 고려
  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "결제 요청",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 정보 카드
            Card(
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
                        Text(
                          widget.itemName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "₩${widget.totalAmount}",
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
                    // TODO [4]: 현재는 임의 데이터. 백엔드에서 상품 옵션 배열을 받아서 동적으로 출력해야 함.
                    const Text("✔ 스튜디오 촬영"),
                    const Text("✔ 기본 의상 제공"),
                    const Text("✔ 촬영본 전달"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 결제자 정보 섹션
            const Text(
              "결제자 정보",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              hint: "이름",
              controller: _nameController,
              // TODO [5]: validator 추가 (빈 값 체크)
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              hint: "이메일",
              controller: _emailController,
              // TODO [5]: validator 추가 (이메일 형식 체크)
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              hint: "전화번호",
              controller: _phoneController,
              // TODO [5]: validator 추가 (숫자 형식 체크)
            ),
            const SizedBox(height: 20),

            // 요청사항
            const Text(
              "추가 요청사항",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomTextArea(
              hint: "선택 입력",
              controller: _commentController,
              // TODO [5]: validator 필요하면 추가
            ),
            const SizedBox(height: 40),

            //  결제 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // TODO [1]: 백엔드 API 호출 (결제 준비 요청)
                  //  - itemName, totalAmount, buyerName, buyerEmail, buyerPhone 등 서버로 전송
                  //  - 서버는 PG사(KakaoPay/Toss)와 통신 후 redirectUrl 반환

                  // TODO [2]: WebView 또는 url_launcher로 redirectUrl 열기
                  //  - 사용자가 결제 완료 → redirectUrl의 success/fail 파라미터 확인

                  // TODO [3]: 결제 성공/실패 분기 처리
                  //  - 성공: Navigator.pushNamed(context, '/payment-success');
                  //  - 실패: Navigator.pushNamed(context, '/payment-fail', arguments: "실패 사유");

                  //  현재는 더미 동작, 성공 테스트용
                  // Navigator.pushNamed(context, '/payment-success');

                  //  실패 테스트용
                   Navigator.pushNamed(context, '/payment-fail', arguments: "잔액 부족");
                },
                icon: const Icon(Icons.credit_card),
                label: const Text(
                  "결제하기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
