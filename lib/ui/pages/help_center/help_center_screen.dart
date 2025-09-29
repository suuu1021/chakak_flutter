import 'package:chakak_flutter/data/dtos/help_dto.dart';
import 'package:chakak_flutter/ui/pages/help_center/widgets/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../_core/constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('전화 앱을 실행할 수 없습니다.');
    }
  }

  Future<void> _openKakaoChannel(BuildContext context) async {
    const String kakaoAppUrl = 'kakaoplus://plusfriend/_igsxmn';
    const String kakaoWebUrl = 'http://pf.kakao.com/_igsxmn';

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
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        title: const Text("고객센터"),
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 대표번호 + 운영시간 + 이미지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "대표번호",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "1588-8282",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "상담시간 10:00 ~ 18:00",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Image.asset(
                  "assets/images/helpcall.png",
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            // 공지 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE500),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Text("📢", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "* 사칭 사이트 주의 안내 *",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // 안내 문구
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "도움이 필요하신가요?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "FAQ, 1:1 문의\n카카오톡 CHAKAK 채널을 통해 \n 앱의 FAQ, 1:1 문의를 확인할 수 있습니다.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "빠른 확인이 필요할 땐\n고객 센터로 연락주시면 빠르게 해결을 \n 도와드리겠습니다.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // 전화 & 카카오 카드
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _makePhoneCall("15888282"),
                    child: ContactCard(
                      dto: helpInfo,
                      icon: Icons.phone,
                      title: "전화 상담",
                      subtitle: "1588-8282",
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _openKakaoChannel(context),
                    child: ContactCard(
                      dto: helpInfo,
                      imagePath: "assets/images/kakaotalk-seeklogo.png",
                      title: "CHAKAK 카카오 채널",
                      color: const Color(0xFFFEE500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
