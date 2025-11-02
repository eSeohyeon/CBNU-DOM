import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class ChecklistPatternView extends StatefulWidget {
  final Map<String, dynamic> answers;
  const ChecklistPatternView({super.key, required this.answers});

  @override
  State<ChecklistPatternView> createState() => _ChecklistPatternViewState();
}

class _ChecklistPatternViewState extends State<ChecklistPatternView> {
  static const List<String> wakeUpOptions = ['4시', '5시', '6시', '7시', '8시', '9시', '10시'];
  static const List<String> sleepOptions = ['9시', '10시', '11시', '12시', '1시', '2시', '3시'];
  static const List<String> showerOptions = ['아침', '저녁', '유동적'];
  static const List<String> homeFrequencyOptions = ['매주', '2주', '매달', '방학'];

  @override
  void initState() {
    super.initState();
    // 다중 선택 초기화
    widget.answers['기상시간'] ??= <String>[];
    widget.answers['취침시간'] ??= <String>[];
    widget.answers['샤워시각'] ??= <String>[];
    // 단일 선택 초기화
    widget.answers['본가주기'] ??= '';
  }

  bool validate() {
    final keysToValidate = [
      '기상시간',
      '취침시간',
      '샤워시각',
      '본가주기'
    ];

    for (var key in keysToValidate) {
      final value = widget.answers[key];
      if (value == null) return false;
      if (value is String && value.isEmpty) return false;
      if (value is List && value.isEmpty) return false;
    }
    return true;
  }

  Widget buildMultiSelect(String title, List<String> options, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: mediumBlack16),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          children: options.map((option) {
            final isSelected = widget.answers[key].contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    widget.answers[key].remove(option);
                  } else {
                    widget.answers[key].add(option);
                  }
                });
              },
              child: checklistGroupButton(isSelected, option),
            );
          }).toList(),
        ),
        SizedBox(height: 36.h),
      ],
    );
  }

  Widget buildSingleSelect(String title, List<String> options, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: mediumBlack16),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          children: options.map((option) {
            final isSelected = widget.answers[key] == option;
            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.answers[key] = option;
                });
              },
              child: checklistGroupButton(isSelected, option),
            );
          }).toList(),
        ),
        SizedBox(height: 36.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMultiSelect('기상시간', wakeUpOptions, '기상시간'),
          buildMultiSelect('취침시간', sleepOptions, '취침시간'),
          buildMultiSelect('샤워시각', showerOptions, '샤워시각'),
          buildSingleSelect('본가주기', homeFrequencyOptions, '본가주기'),
        ],
      ),
    );
  }
}
