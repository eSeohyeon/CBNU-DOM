import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/common/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _enrollYearController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> signUp() async {
    if (_nicknameController.text.isEmpty ||
        _birthYearController.text.isEmpty ||
        _enrollYearController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() { _errorMessage = '모든 정보를 입력해주세요.'; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() { _errorMessage = '비밀번호가 일치하지 않습니다.'; _isLoading = false; });
      return;
    }

    try {
      // 1. Firebase Auth에 사용자 생성
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Firestore에 사용자 정보 저장
        await _saveUserDataToFirestore(user);

        // 3. 이메일 인증 메일 발송
        await user.sendEmailVerification();
      }

      // 4. 현재 화면 닫기 (AuthGate가 인증 페이지로 안내)
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password': message = '비밀번호는 6자 이상이어야 합니다.'; break;
        case 'email-already-in-use': message = '이미 사용 중인 이메일입니다.'; break;
        case 'invalid-email': message = '유효하지 않은 이메일 형식입니다.'; break;
        default: message = '회원가입 중 오류가 발생했습니다: ${e.message}';
      }
      setState(() { _errorMessage = message; });
    } catch (e) {
      setState(() { _errorMessage = '알 수 없는 오류가 발생했습니다: ${e.toString()}'; });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  // 사용자 정보를 Firestore에 저장하는 함수
  Future<void> _saveUserDataToFirestore(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'nickname': _nicknameController.text.trim(),
      'birthYear': _birthYearController.text.trim(),
      'enrollYear': _enrollYearController.text.trim(),
      'department': _departmentController.text.trim(),
      'createdAt': Timestamp.now(),
      'emailVerified': user.emailVerified, // 인증 상태 저장 (초기값 false)
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _birthYearController.dispose();
    _enrollYearController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(title: Text('회원가입', style: mediumBlack18), titleSpacing: 0, backgroundColor: white, surfaceTintColor: white),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('닉네임', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _nicknameController, name: '닉네임을 입력하세요', inputType: TextInputType.text),
              SizedBox(height: 20.h),
              Text('생년', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _birthYearController, name: '생년을 입력하세요 예) 2002', inputType: TextInputType.number),
              SizedBox(height: 20.h),
              Text('학번', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _enrollYearController, name: '학번을 입력하세요 예) 21', inputType: TextInputType.number),
              SizedBox(height: 20.h),
              Text('학과', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _departmentController, name: '학과를 입력하세요', inputType: TextInputType.text),
              SizedBox(height: 20.h),
              Text('이메일', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _emailController, name: '이메일을 입력하세요', inputType: TextInputType.emailAddress),
              SizedBox(height: 20.h),
              Text('비밀번호', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _passwordController, name: '비밀번호를 입력하세요', inputType: TextInputType.visiblePassword, obscureText: true),
              SizedBox(height: 20.h),
              Text('비밀번호 확인', style: mediumBlack16),
              SizedBox(height: 6.h),
              CustomTextField(controller: _confirmPasswordController, name: '비밀번호를 다시 입력하세요', inputType: TextInputType.visiblePassword, obscureText: true),
              SizedBox(height: 20.h),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(_errorMessage!, style: mediumBlack14.copyWith(color: Colors.red), textAlign: TextAlign.center),
                ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading) CircularProgressIndicator(),
                if (!_isLoading)
                  SizedBox(
                    width: double.infinity,
                    height: 45.h,
                    child: ElevatedButton(onPressed: signUp, style: btnBlackRound30, child: Text('회원가입하고 시작하기', style: mediumWhite16)),
                  )
              ]
          )
      ),
    );
  }
}
