import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';

class PopupDialog extends StatelessWidget {
  const PopupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      content: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('재학생 인증 필요', style: boldBlack18),
                SizedBox(height: 4.h),
                Text('본 기능은 재학생 인증 완료 후에 이용하실 수 있어요', style: mediumGrey14, textAlign: TextAlign.center),
                SizedBox(height: 20.h),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 인증 창 이동
                        },
                        child: Text('인증하기', style: mediumWhite14),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: black,
                          overlayColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                        )
                      ),
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('닫기', style: mediumBlack14),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: grey_button,
                          overlayColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                        )
                      ),
                    )
                  ]
                )
              ]
          )
      ),
    );
  }
}
