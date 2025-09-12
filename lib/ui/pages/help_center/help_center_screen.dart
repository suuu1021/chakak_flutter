import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'package:chakak_flutter/data/dtos/help_dto.dart';
import 'widgets/contact_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Mock DTO 데이터 (나중에 백엔드 연결되면 fromJson으로 교체)
    final helpInfo = HelpDto(
      id: "1",
      userId: "user123",
      category: "FAQ, 1:1 문의",
      content:
      "카카오톡 CHAKAK 채널을 통해 앱의 FAQ, 1:1 문의를 확인할 수 있습니다.\n\n"
          "빠른 확인이 필요할 땐 고객 센터로 연락주시면 빠르게 해결을 도와드리겠습니다.",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
            Text(
              helpInfo.category,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              helpInfo.content,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Text("원하시는 방식을 선택해주세요.",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ContactCard(
                    dto: helpInfo,
                    icon: Icons.phone,
                    title: "1588-8282",
                    subtitle: "상담시간 : 10:00 ~ 18:00",
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ContactCard(
                    dto: helpInfo,
                    imagePath: "assets/images/kakaotalk-seeklogo.png",
                    title: "CHAKAK 카카오 채널",
                    color: Colors.yellow,
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
