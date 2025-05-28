import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


Widget checklistGroupButton(bool selected, String value) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
          color: selected ? black : white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: black, width: 1.0)
      ),
      child: Text(value, style: selected ? mediumWhite14 : mediumBlack14)
  );
}