import 'package:chakak_flutter/ui/pages/home/HomeScreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            const Icon(
              Icons.camera,
              size: 150,
              color: Colors.black,
            ),
            const SizedBox(height: 16),

            // 앱 이름
            const Text(
              "chakak",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),

            // 이메일 입력
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "이메일",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "비밀번호",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print("로그인 버튼 클릭됨");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white, // 글자 흰색
              ),
              child: const Text(
                "로그인",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

            const SizedBox(height: 12),

            // 회원가입 이동 텍스트 버튼
            TextButton(
              onPressed: () {
                print("회원가입 화면으로 이동");
                // Navigator.pushNamed(context, '/signup'); <- 나중에 연결
              },
              child: const Text("회원가입 하기"),
            ),
          ],
        ),
      ),
    );
  }
}
