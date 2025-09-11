import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  /// 전화번호로 전화 걸기
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('전화 앱을 실행할 수 없습니다.');
    }
  }

  /// 카카오톡 채널 열기
  Future<void> _openKakaoChannel(BuildContext context) async {
    // 카카오톡 앱으로 직접 연결 시도
    const String kakaoAppUrl =
        'kakaoplus://plusfriend/_igsxmn'; // CHAKAK 채널 ID (실제 ID로 변경 필요)
    // 웹 브라우저로 연결 (카카오톡 앱이 없는 경우)
    const String kakaoWebUrl =
        'http://pf.kakao.com/_igsxmn'; // CHAKAK 채널 웹 URL (실제 URL로 변경 필요)

    try {
      // 먼저 카카오톡 앱 실행 시도
      final Uri kakaoAppUri = Uri.parse(kakaoAppUrl);
      if (await canLaunchUrl(kakaoAppUri)) {
        await launchUrl(kakaoAppUri);
        return;
      }

      // 카카오톡 앱이 없으면 웹 브라우저로 실행
      final Uri kakaoWebUri = Uri.parse(kakaoWebUrl);
      if (await canLaunchUrl(kakaoWebUri)) {
        await launchUrl(
          kakaoWebUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorDialog(context, '카카오톡 채널을 열 수 없습니다.');
      }
    } catch (e) {
      _showErrorDialog(context, '카카오톡 채널 연결 중 오류가 발생했습니다.');
      debugPrint('카카오톡 채널 열기 오류: $e');
    }
  }

  /// 에러 다이얼로그 표시
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

  /// 탭 가능한 컨테이너 위젯
  Widget _buildContactCard({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("고객센터"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "도움이 필요하신가요?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "FAQ, 1:1 문의\n"
                  "카카오톡 CHAKAK 채널을 통해 앱의 FAQ, 1:1 문의를 하실 수 있습니다.\n\n"
                  "배송 확인이 필요하실 땐 \n"
                  "고객 센터로 연락주시면 빠르게 해결을 도와드리겠습니다.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                const Text(
                  "원하시는 방식을 선택해주세요.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // 전화 연결 카드
                    _buildContactCard(
                      onTap: () => _makePhoneCall('1588-8282'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 36, color: Colors.black87),
                            SizedBox(height: 8),
                            Text(
                              "1588-8282",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "상담시간 10:00 - 18:00",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 카카오톡 채널 연결 카드
                    _buildContactCard(
                      onTap: () => _openKakaoChannel(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/kakaotalk-seeklogo.png",
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "CHAKAK\n카카오 채널",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
