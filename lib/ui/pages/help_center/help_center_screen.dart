import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'package:chakak_flutter/data/dtos/help_dto.dart';
import 'widgets/contact_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // 📌 전화 앱 실행
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('전화 앱을 실행할 수 없습니다.');
    }
  }

  // 📌 카카오톡 채널 열기
  Future<void> _openKakaoChannel(BuildContext context) async {
    const String kakaoAppUrl = 'kakaoplus://plusfriend/_igsxmn'; // 앱 링크 (실제 ID로 변경)
    const String kakaoWebUrl = 'http://pf.kakao.com/_igsxmn';   // 웹 링크 (실제 URL로 변경)

    try {
      final Uri kakaoAppUri = Uri.parse(kakaoAppUrl);
      if (await canLaunchUrl(kakaoAppUri)) {
        await launchUrl(kakaoAppUri);
        return;
      }

      final Uri kakaoWebUri = Uri.parse(kakaoWebUrl);
      if (await canLaunchUrl(kakaoWebUri)) {
        await launchUrl(kakaoWebUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(context, '카카오톡 채널을 열 수 없습니다.');
      }
    } catch (e) {
      _showErrorDialog(context, '카카오톡 채널 연결 중 오류가 발생했습니다.');
      debugPrint('카카오톡 채널 열기 오류: $e');
    }
  }

  // 📌 에러 다이얼로그
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final helpInfo = HelpDto(
      id: "1",
      userId: "user123",
      category: "FAQ, 1:1 문의",
      content: "빠른 확인이 필요하실 땐 고객 센터로 연락주세요.",
      createdAt: DateTime.now(),
      status: "ANSWERED",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("고객센터"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("도움이 필요하신가요?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(helpInfo.content,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 20),
            const Text("원하시는 방식을 선택해주세요.",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Row(
              children: [
                // 📌 전화 카드
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _makePhoneCall("15888282"),
                    child: ContactCard(
                      dto: helpInfo,
                      icon: Icons.phone,
                      title: "1588-8282",
                      subtitle: "상담시간 : 10:00 ~ 18:00",
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 📌 카카오 카드
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openKakaoChannel(context),
                    child: ContactCard(
                      dto: helpInfo,
                      imagePath: "assets/images/kakaotalk-seeklogo.png",
                      title: "CHAKAK 카카오 채널",
                      color: const Color(0xFFFEE500), // 카카오톡 공식 노란색
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
