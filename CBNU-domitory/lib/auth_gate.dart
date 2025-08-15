import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/home_page.dart';
import 'package:untitled/bottom_navigation_tab.dart';
import 'package:untitled/start/start_page.dart';
import 'package:untitled/start/verify_email_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user == null) {
            // 사용자가 없으면(로그아웃 상태) StartPage를 보여줍니다.
            return const StartPage();
          }
          else {
            // 사용자가 있으면 이메일 인증 여부를 확인합니다.
            if (user.emailVerified) {
              // 인증 완료 시, 홈 페이지로 이동
              return BottomNavigationTab(navigatedIndex: 0);
              // bottom navigation tab에서 홈 화면/룸메매칭 화면/커뮤니티 화면/쪽지 화면을 보여주는 거라서 수정
            } else {
              // 인증 미완료 시, 인증 대기 페이지로 이동
              return const VerifyEmailPage();
            }
          }
        },
      ),
    );
  }
}
