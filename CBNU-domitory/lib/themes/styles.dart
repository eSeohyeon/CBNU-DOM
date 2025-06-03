import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

// 텍스트 스타일 지정 [두께/색/사이즈]

final boldWhite15 = TextStyle(
    fontSize: 15.sp,
    color: white,
    fontFamily: 'pretendard-semibold',
    fontWeight: FontWeight.w700
);

final boldBlack20 = TextStyle(
    fontSize: 20.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w700
);

final boldBlack28 = TextStyle(
    fontSize: 28.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w700
);

final boldBlack18 = TextStyle(
    fontSize: 18.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w700
);

final boldBlack16 = TextStyle(
    fontSize: 16.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w700
);

final mediumBlack13 = TextStyle(
    fontSize: 13.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumBlack12 = TextStyle(
    fontSize: 12.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumBlack14 = TextStyle(
    fontSize: 14.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumBlack16 = TextStyle(
    fontSize: 16.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumBlack18 = TextStyle(
    fontSize: 18.sp,
    color: black,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumGrey12 = TextStyle(
    fontSize: 12.sp,
    color: grey,
//height: 1.5,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumGrey13 = TextStyle(
    fontSize: 13.sp,
    color: grey,
//height: 1.5,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumGrey14 = TextStyle(
    fontSize: 14.sp,
    color: grey,
//height: 1.5,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumWhite14 = TextStyle(
    fontSize: 14.sp,
    color: white,
//height: 1.5,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final mediumWhite16 = TextStyle(
    fontSize: 16.sp,
    color: white,
//height: 1.5,
    fontFamily: 'pretendard-medium',
    fontWeight: FontWeight.w500
);

final btnBlackRound30 = TextButton.styleFrom( // black, round30
    backgroundColor: black,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
    )
);