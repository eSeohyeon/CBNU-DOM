import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  // 비밀번호 재설정 이메일 발송 함수
  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = '이메일을 입력해주세요.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = '비밀번호 재설정 이메일이 발송되었습니다. 이메일을 확인해주세요.';
        _isSuccess = true;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _message = '등록되지 않은 이메일입니다.';
          _isSuccess = false;
        });
      } else {
        setState(() {
          _message = '오류가 발생했습니다: ${e.message}';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = '알 수 없는 오류가 발생했습니다.';
        _isSuccess = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('비밀번호 찾기', style: mediumBlack18),
        titleSpacing: 0,
        backgroundColor: white,
        surfaceTintColor: white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('가입 시 사용한 이메일을 입력해주세요.', style: mediumBlack16),
            SizedBox(height: 6.h),
            CustomTextField(
              controller: _emailController,
              name: '이메일을 입력하세요',
              inputType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.h),
            if (_message != null)
              Text(
                _message!,
                style: mediumBlack14.copyWith(
                  color: _isSuccess ? Colors.blue : Colors.red,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 16.w),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: _sendResetEmail,
              style: btnBlackRound30,
              child: Text('재설정 이메일 받기', style: mediumWhite16),
            ),
          ),
        ),
      ),
    );
  }
}
