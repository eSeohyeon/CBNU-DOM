import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget selectedFilterItem(String title, String value, VoidCallback onRemove) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: black , width: 1.0)
      ),
      child: Row(
        children: [
          Text('$title : $value', style: mediumWhite14),
          IconButton(
            icon: Icon(Icons.close_rounded, color: grey, size: 18),
            onPressed: () {
              onRemove();
            },
          )
        ]
      )
  );
}