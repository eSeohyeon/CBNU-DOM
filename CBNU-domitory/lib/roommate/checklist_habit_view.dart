import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class ChecklistHabitView extends StatefulWidget {
  final Map<String, dynamic> answers;
  const ChecklistHabitView({super.key, required this.answers});

  @override
  State<ChecklistHabitView> createState() => _ChecklistHabitViewState();
}

class _ChecklistHabitViewState extends State<ChecklistHabitView> {
  static const List<String> smokingOptions = ['흡연', '비흡연'];
  static const List<String> sleepingHabitOptions = ['없음', '이갈이', '잠꼬대', '코골이'];
  static const List<String> sleepingEarOptions = ['어두움', '중간', '밝음'];
  static const List<String> cleaningOptions = ['그때그때', '중간', '한번에'];
  static const List<String> soundOptions = ['이어폰', '스피커', '유동적'];

  @override
  void initState() {
    super.initState();
    // 모든 다중 선택 항목 초기화
    widget.answers['잠버릇'] ??= <String>[];
    widget.answers['잠귀'] ??= <String>[];
    widget.answers['청소'] ??= <String>[];
    widget.answers['소리'] ??= <String>[];
  }

  bool validate() {
    final keysToValidate = [
      '흡연여부',  // 단일 선택
      '잠버릇',    // 다중 선택
      '잠귀',      // 다중 선택
      '청소',      // 다중 선택
      '소리'       // 다중 선택
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 단일 선택: 흡연여부
          Text('흡연여부', style: mediumBlack16),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            children: smokingOptions.map((option) {
              final isSelected = widget.answers['흡연여부'] == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.answers['흡연여부'] = option;
                  });
                },
                child: checklistGroupButton(isSelected, option),
              );
            }).toList(),
          ),
          SizedBox(height: 36.h),

          // 다중 선택 항목
          buildMultiSelect('잠버릇', sleepingHabitOptions, '잠버릇'),
          buildMultiSelect('잠귀', sleepingEarOptions, '잠귀'),
          buildMultiSelect('청소', cleaningOptions, '청소'),
          buildMultiSelect('소리', soundOptions, '소리'),
        ],
      ),
    );
  }
}
