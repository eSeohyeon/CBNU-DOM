import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      content: Container(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 20.h, bottom: 8.h),
        decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('추천 룸메이트와의\n생활은 만족스러우셨나요?', style: boldBlack16, textAlign: TextAlign.center),
            SizedBox(height: 2.h),
            Text('추천 AI 모델의 성능 향상에 사용돼요', style: mediumGrey13, textAlign: TextAlign.center),
            SizedBox(height: 10.h),
            RatingBar.builder(
              initialRating: 3,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 2.w),
              itemBuilder: (context, _) => const Icon(
                Icons.mood_rounded,
                color: Colors.amber,
                size: 22
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating.toInt();
                  print(_rating);
                });
              }
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('매우 불만족', style: mediumGrey12),
                Text('매우 만족', style: mediumGrey12)
              ]
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _rating);
                  },
                  child: Text('완료', style: mediumBlack14),
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
    );
  }
}
