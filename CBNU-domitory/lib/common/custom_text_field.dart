import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType inputType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.name,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: true,
      controller: controller,
      textCapitalization: textCapitalization,
      maxLength: 32,
      maxLines: 1,
      obscureText: obscureText,
      keyboardType: inputType,
      textAlign: TextAlign.start,
      style: mediumBlack14,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        labelText: name,
        counterText: "",
        labelStyle: mediumGrey13,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: grey_outline_inputtext),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: black),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: grey_outline_inputtext),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
    );
  }
}