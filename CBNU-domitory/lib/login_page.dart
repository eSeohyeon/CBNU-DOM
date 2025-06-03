import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:untitled/bottom_navigation_tab.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // 로그인 시도 함수
  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // 이전 에러 메시지 초기화
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigationTab(navigatedIndex: 0)));
      // 로그인 성공 시 AuthGate가 자동으로 HomePage로 이동시킴
    } on FirebaseAuthException catch (e) {
      // 흔한 오류 코드에 대한 사용자 친화적 메시지
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = '등록되지 않은 이메일입니다.';
          break;
        case 'wrong-password':
          message = '비밀번호가 틀렸습니다.';
          break;
        case 'invalid-email':
          message = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'user-disabled':
          message = '비활성화된 계정입니다.';
          break;
        default:
          message = '로그인 중 오류가 발생했습니다: ${e.message}';
      }
      setState(() {
        _errorMessage = message;
      });
      print('Login failed: ${e.code} - ${e.message}'); // 디버깅용 로그
    } catch (e) {
      // 기타 예상치 못한 오류
      setState(() {
        _errorMessage = '알 수 없는 오류가 발생했습니다.';
      });
      print('An unexpected error occurred: $e'); // 디버깅용 로그
    } finally {
      if (mounted) { // 위젯이 여전히 트리에 있는지 확인
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(title: Text('로그인', style: mediumBlack18), titleSpacing: 0, backgroundColor: white, surfaceTintColor: white),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: SingleChildScrollView( // 키보드가 올라올 때 화면 깨짐 방지
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이메일', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _emailController,
                name: '이메일을 입력하세요',
                inputType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              Text('비밀번호', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _passwordController,
                name: '비밀번호를 입력하세요',
                obscureText: true,
                inputType: TextInputType.visiblePassword,
              ),

              // 에러 메시지 표시
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: mediumBlack14.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(_isLoading)
              CircularProgressIndicator(),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                onPressed: signIn,
                style: btnBlackRound30,
                child: Text('로그인', style: mediumWhite16),
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: () {
                // 아이디 비번 찾기 페이지로 이동
              },
              style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
              child: Text('아이디/비밀번호 찾기', style: mediumGrey14)
            )
          ],
        )
      ),
    );
  }
}