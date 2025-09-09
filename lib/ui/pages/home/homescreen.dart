import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 탭별 화면
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // 홈 화면 콘텐츠를 첫 페이지로 설정
    _pages.add(const HomeContent());
    _pages.add(const Center(child: Text("검색 화면", style: TextStyle(fontSize: 24))));
    _pages.add(const Center(child: Text("예약 화면", style: TextStyle(fontSize: 24))));
    _pages.add(const Center(child: Text("프로필 화면", style: TextStyle(fontSize: 24))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Chakak",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.search), onPressed: () => print("검색 클릭")),
                IconButton(icon: const Icon(Icons.notifications), onPressed: () => print("알림 클릭")),
                IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => print("일정 클릭")),
              ],
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "예약"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "프로필"),
        ],
      ),
    );
  }
}

// ---------------- 홈 화면 콘텐츠 ----------------
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  final List<String> categories = const ["개인", "커플/우정", "웨딩", "이벤트", "스튜디오"];
  final List<Map<String, String>> photographers = const [
    {"name": "홍길동", "desc": "스냅 전문", "price": "₩100,000"},
    {"name": "김철수", "desc": "웨딩 전문", "price": "₩150,000"},
    {"name": "이영희", "desc": "인물 전문", "price": "₩120,000"},
    {"name": "박민수", "desc": "패밀리 전문", "price": "₩90,000"},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 배너 영역
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Image.asset(
              "assets/images/onbording.jpg",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // 카테고리 영역
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50), // 높이보다 큰 값으로 완전히 둥글게
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "서비스",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // 포토그래퍼 카드 영역 (가로 스크롤)
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photographers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final photographer = photographers[index];
                return Container(
                  width: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 영역 (임시 색상)
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: const Icon(Icons.camera_alt, size: 50, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          photographer["name"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          photographer["desc"]!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          photographer["price"]!,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


