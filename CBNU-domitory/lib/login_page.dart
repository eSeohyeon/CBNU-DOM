import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/auth_gate.dart'; // AuthGate를 import 합니다.
import 'package:untitled/start/forgot_password_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/common/custom_text_field.dart';

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
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
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
          message = '로그인 중 오류가 발생했습니다.';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '알 수 없는 오류가 발생했습니다.';
      });
    } finally {
      if (mounted) {
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
        child: SingleChildScrollView(
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: mediumBlack14.copyWith(color: Colors.red),
                    ),
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
              if (_isLoading)
                const CircularProgressIndicator()
              else
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
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
