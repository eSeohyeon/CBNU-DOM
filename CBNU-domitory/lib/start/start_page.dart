import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/login_page.dart';
import 'package:untitled/register_page.dart';
import 'package:untitled/bottom_navigation_tab.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) { // 전사
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container( // 이미지 넣을 건데, 아직 뭐 넣을지 안 ㅏ정함.
                width: 120.w,
                height: 130.h,
                child: Image.asset('assets/start_temp.png')
              ),
              SizedBox(height: 12.h),
              Text('기숙사 생활의 필수 앱', style: boldBlack20),
              SizedBox(height: 2.h),
              Text('지금 바로 시작해보세요!', style: mediumBlack16)
            ]
          ),
        )
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  onPressed: () {
                    // 회원가입 페이지로 이동
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                  },
                  child: Text("시작하기", style: mediumWhite16),
                  style: btnBlackRound30
                )
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이미 계정이 있으신가요?', style: mediumGrey14),
                  TextButton(
                    onPressed: () {
                      // 로그인 페이지로 이동
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                    child: Text('로그인', style: boldBlack16.copyWith(fontSize: 14.sp))
                  )
                ]
              )
            ]
          )
        ),
      )
    );
  }
}
