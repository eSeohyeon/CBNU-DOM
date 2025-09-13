import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/home_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/bottom_navigation_tab.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 현재 사용자의 이메일 인증 상태를 먼저 확인합니다.
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // 인증되지 않았다면, 인증 메일을 보내고 3초마다 상태를 확인합니다.
    if (!_isEmailVerified) {
      _sendVerificationEmail();

      // 3초마다 Firebase에 인증 상태를 물어보는 타이머를 설정합니다.
      _timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // 화면이 꺼질 때 타이머도 함께 종료하여 메모리 누수를 방지합니다.
    _timer?.cancel();
    super.dispose();
  }

  // Firebase에 최신 사용자 정보를 요청하여 인증 상태를 확인하는 함수
  Future<void> _checkEmailVerified() async {
    // 1. Firebase로부터 최신 사용자 정보를 강제로 다시 불러옵니다.
    await FirebaseAuth.instance.currentUser!.reload();

    // 2. 업데이트된 인증 상태를 확인합니다.
    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    // 3. 인증이 완료되었다면, 타이머를 멈추고 HomePage로 이동합니다.
    if (_isEmailVerified) {
      _timer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 인증이 완료되었습니다!')),
      );

      // AuthGate가 처리해주지만, 만약을 위해 명시적으로 이동합니다.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => BottomNavigationTab(navigatedIndex: 0)),
            (route) => false,
      );
    }
  }

  // 인증 메일을 보내는 함수
  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      // 스팸 방지를 위해 30초간 재전송 버튼 비활성화
      setState(() => _canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) {
        setState(() => _canResendEmail = true);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 메일 발송에 실패했습니다: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이미 인증된 상태라면 바로 HomePage를 보여줍니다.
    return _isEmailVerified
        ? BottomNavigationTab(navigatedIndex: 0)
        : Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('이메일 인증', style: mediumBlack18),
        backgroundColor: white,
        surfaceTintColor: white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '인증 메일을 발송했습니다.\n${FirebaseAuth.instance.currentUser?.email}\n\n이메일을 확인하여 계정을 활성화해주세요.',
                style: mediumBlack16,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(), // 인증 대기 중임을 표시
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: black,
                  foregroundColor: white,
                ),
                icon: const Icon(Icons.email_outlined),
                // 재전송 가능할 때만 버튼 활성화
                onPressed: _canResendEmail ? _sendVerificationEmail : null,
                label: const Text('인증 메일 다시 보내기'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _timer?.cancel();
                  FirebaseAuth.instance.signOut();
                },
                child: Text('취소', style: mediumGrey14),
              )
            ],
          ),
        ),
      ),
    );
  }
}
