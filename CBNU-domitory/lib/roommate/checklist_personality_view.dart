import 'package:flutter/material.dart';
import 'package:untitled/themes/styles.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:untitled/themes/colors.dart';

class ChecklistPersonalityView extends StatefulWidget {
  final Map<String, dynamic> answers;
  ChecklistPersonalityView({super.key, required this.answers});

  @override
  State<ChecklistPersonalityView> createState() => _ChecklistPersonalityViewState();
}

class _ChecklistPersonalityViewState extends State<ChecklistPersonalityView> {
  late GroupButtonController _mbtiEIController;
  late GroupButtonController _mbtiNSController;
  late GroupButtonController _mbtiTFController;
  late GroupButtonController _mbtiPJController;
  late GroupButtonController _computerGameController;
  late GroupButtonController _exerciseController;
  late GroupButtonController _neverYieldController;

  final List<String> mbtiTitleOptions = ['EI', 'NS', 'TF', 'Pj'];
  final List<String> mbtiEIOptions = ['E', 'I'];
  final List<String> mbtiNSOptions = ['N', 'S'];
  final List<String> mbtiTFOptions = ['T', 'F'];
  final List<String> mbtiPJOptions = ['P', 'J'];
  final List<String> computerGameOptions = ['안 함', '중간', '좋아함'];
  final List<String> exerciseOptions = ['안 함', '중간', '좋아함'];
  final List<String> neverYieldOptions = ['기상시간', '취침시간', '샤워시각', '흡연여부', '잠버릇', '청소', '더위', '추위', '실내취식', '실내통화', '친구초대'];

  @override
  void initState() {
    super.initState();

    _mbtiEIController = GroupButtonController(
      selectedIndex: _getInitialIndex('MBTI_EI', mbtiEIOptions),
    );
    _mbtiNSController = GroupButtonController(
      selectedIndex: _getInitialIndex('MBTI_NS', mbtiNSOptions),
    );
    _mbtiTFController = GroupButtonController(
      selectedIndex: _getInitialIndex('MBTI_TF', mbtiTFOptions),
    );
    _mbtiPJController = GroupButtonController(
      selectedIndex: _getInitialIndex('MBTI_PJ', mbtiPJOptions),
    );
    _computerGameController = GroupButtonController(
      selectedIndex: _getInitialIndex('컴퓨터게임', computerGameOptions),
    );
    _exerciseController = GroupButtonController(
      selectedIndex: _getInitialIndex('운동', exerciseOptions),
    );
    _neverYieldController = GroupButtonController(
      selectedIndex: _getInitialIndex('이것만은 양보 못 해', neverYieldOptions)
    );
  }

  int? _getInitialIndex(String key, List<String> options) {
    final value = widget.answers[key];
    if (value != null && value != '') {
      final index = options.indexOf(value);
      return index >= 0 ? index : null;
    }
    return null;
  }

  @override
  void dispose() {
    _mbtiEIController.dispose();
    _mbtiNSController.dispose();
    _mbtiTFController.dispose();
    _mbtiPJController.dispose();
    _computerGameController.dispose();
    _neverYieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Text('MBTI', style: mediumBlack16),
              SizedBox(height: 10.h),
              Row(
                  children: [
                    GroupButton(
                        buttons: mbtiEIOptions,
                        controller: _mbtiEIController,
                        onSelected: (val, i, selected) {
                          setState(() {
                            widget.answers['MBTI_EI'] = val;
                          });
                        },
                        buttonBuilder: (selected, value, context) => checklistGroupButton(selected, value),
                        options: GroupButtonOptions(groupingType: GroupingType.column, spacing: 10)
                    ),
                    SizedBox(width: 12.w),
                    GroupButton(
                        buttons: mbtiNSOptions,
                        controller: _mbtiNSController,
                        onSelected: (val, i, selected) {
                          setState(() {
                            widget.answers['MBTI_NS'] = val;
                          });
                        },
                        buttonBuilder: (selected, value, context) => checklistGroupButton(selected, value),
                        options: GroupButtonOptions(groupingType: GroupingType.column)
                    ),
                    SizedBox(width: 12.w),
                    GroupButton(
                        buttons: mbtiTFOptions,
                        controller: _mbtiTFController,
                        onSelected: (val, i, selected) {
                          setState(() {
                            widget.answers['MBTI_TF'] = val;
                          });
                        },
                        buttonBuilder: (selected, value, context) => checklistGroupButton(selected, value),
                        options: GroupButtonOptions(groupingType: GroupingType.column)
                    ),
                    SizedBox(width: 12.w),
                    GroupButton(
                        buttons: mbtiPJOptions,
                        controller: _mbtiPJController,
                        onSelected: (val, i, selected) {
                          setState(() {
                            widget.answers['MBTI_PJ'] = val;
                          });
                        },
                        buttonBuilder: (selected, value, context) => checklistGroupButton(selected, value),
                        options: GroupButtonOptions(groupingType: GroupingType.column)
                    ),
                  ]
              ),
              SizedBox(height: 36.h),
              Text('컴퓨터게임', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: computerGameOptions,
                controller : _computerGameController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['컴퓨터게임'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
              Text('운동', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: exerciseOptions,
                controller : _exerciseController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['운동'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
              Text('이것만은 양보 못해', style: mediumBlack16),
              Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: grey, size: 20),
                    SizedBox(width: 4.w),
                    Expanded(child: Text('룸메이트 추천 시, 반드시 고려되었으면 하는 항목 택1', style: mediumGrey13))
                  ]
              ),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: neverYieldOptions,
                controller : _neverYieldController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['이것만은 양보 못해'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8, groupRunAlignment: GroupRunAlignment.start, mainGroupAlignment: MainGroupAlignment.start),
              ),
            ]
        )
    );
  }
}