import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

class RoommateHelpDialog extends StatelessWidget {
  const RoommateHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      content: Container(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 12.h),
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. 추천 점수', style: boldBlack16),
                SizedBox(height: 6.h),
                Text(' : 추천 점수는 당신과 후보자의 생활 습관이 얼마나 잘 맞는지를 종합적으로 평가한 점수예요.\n\n- 점수가 높을수록 생활이 편하고, 스트레스가 적어요\n- 점수가 낮을수록 몇 가지 생활습관이 달라 조정이 필요할 수 있어요', style: mediumBlack14),
                SizedBox(height: 20.h),
                Text('2. 특성별 유사도', style: boldBlack16),
                SizedBox(height: 6.h),
                Text(' : 각 항목별로 당신과 후보자가 얼마나 비슷한지 점수로 표시했어요', style: mediumBlack14),
                SizedBox(height: 20.h),
                Text('3. 점수 감점 항목', style: boldBlack16),
                SizedBox(height: 6.h),
                Text(' : 겹치면 불편한 항목에 대해서 감점하여 최종적으로 추천 점수를 산출했어요.\n해당하는 항목은 다음과 같아요\n\n- 샤워시간 : 같은 시간대에 샤워 시, -0.5점\n- 잠귀/잠버릇 : 한 쪽이 잠귀가 밝고 다른 한 쪽이 잠버릇이 있는 경우, -0.7점\n- 벌레 : 둘 다 민감한 경우, -0.7점', style: mediumBlack14),
                SizedBox(height: 20.h),
                Text('4. 추가조건 설정', style: boldBlack16),
                SizedBox(height: 6.h),
                Text(' : 최대 2가지의 추가 조건을 선택하여 추천된 후보들을 조건에 맞춰 필터링할 수 있어요', style: mediumBlack14),
                SizedBox(height: 28.h),
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
          )
      ),
    );
  }
}
