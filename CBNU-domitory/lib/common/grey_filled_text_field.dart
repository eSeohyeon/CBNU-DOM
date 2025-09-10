import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';

class GreyFilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final bool obscureText;
  final TextInputType inputType;
  final int maxLength;
  final FocusNode? focusNode;

  const GreyFilledTextField({
    super.key,
    required this.controller,
    required this.name,
    this.obscureText = false,
    required this.inputType,
    this.maxLength = 32,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: true,
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.none,
      maxLength: maxLength,
      maxLines: 1,
      obscureText: obscureText,
      keyboardType: inputType,
      textAlign: TextAlign.start,
      style: mediumBlack14,
      decoration: InputDecoration(
        filled: true,
        fillColor: background,
        labelText: name,
        counterText: '',
        labelStyle: mediumGrey14,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(36.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }
}