import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:lottie/lottie.dart';

class LaundryCardModal extends StatefulWidget {
  const LaundryCardModal({super.key});

  @override
  State<LaundryCardModal> createState() => _LaundryCardModalState();
}

class _LaundryCardModalState extends State<LaundryCardModal> {
  int _balance = 2000;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 0.48.sh,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  '세탁카드 잔액확인',
                  style: boldBlack18,
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie_nfc.json', width: 200.w, height: 200.h),
                    Text('NFC 기능을 켜고, 세탁카드를 인식시켜 주세요.', style: mediumGrey13),
                    SizedBox(height: 10.h),
                    Text('잔액 : ${_balance}원', style: boldBlack20)
                  ]
                )
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: black,
                        overlayColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                        elevation: 0
                    ),
                    child: Text('닫기', style: boldWhite15)
                ),
              ),
            ]
          )
        )
      )
    );
  }
}
