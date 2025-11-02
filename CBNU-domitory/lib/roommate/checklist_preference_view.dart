import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class ChecklistPreferenceView extends StatefulWidget {
  final Map<String, dynamic> answers;
  const ChecklistPreferenceView({super.key, required this.answers});

  @override
  State<ChecklistPreferenceView> createState() => _ChecklistPreferenceViewState();
}

class _ChecklistPreferenceViewState extends State<ChecklistPreferenceView> {
  static const List<String> hotOptions = ['적게탐', '중간', '많이탐'];
  static const List<String> coldOptions = ['적게탐', '중간', '많이탐'];
  static const List<String> bugOptions = ['극혐', '못잡음', '중간', '잡음', '잘잡음'];
  static const List<String> smellOptions = ['싫어요', '냄새만안나면', '과자류는O', '상관X'];
  static const List<String> callInRoomOptions = ['상관X','싫어요', '짧은것만'];
  static const List<String> inviteFriendOptions = ['상관X', '싫어요', '사전허락'];

  @override
  void initState() {
    super.initState();
    // 다중 선택 초기화
    widget.answers['더위'] ??= <String>[];
    widget.answers['추위'] ??= <String>[];
    widget.answers['벌레'] ??= <String>[];
    widget.answers['실내취식'] ??= <String>[];
    widget.answers['실내통화'] ??= <String>[];
    widget.answers['친구초대'] ??= <String>[];
  }

  bool validate() {
    final keysToValidate = [
      '더위',
      '추위',
      '벌레',
      '실내취식',
      '실내통화',
      '친구초대'
    ];

    for (var key in keysToValidate) {
      final value = widget.answers[key];
      if (value == null || (value is List && value.isEmpty)) return false;
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
          buildMultiSelect('더위', hotOptions, '더위'),
          buildMultiSelect('추위', coldOptions, '추위'),
          buildMultiSelect('실내취식', smellOptions, '실내취식'),
          buildMultiSelect('실내통화', callInRoomOptions, '실내통화'),
          buildMultiSelect('친구초대', inviteFriendOptions, '친구초대'),
          buildMultiSelect('벌레', bugOptions, '벌레'),
        ],
      ),
    );
  }
}
