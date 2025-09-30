import 'package:flutter/material.dart';
import 'package:untitled/themes/styles.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:untitled/themes/colors.dart';

class ChecklistPersonalityView extends StatefulWidget {
  final Map<String, dynamic> answers;
  const ChecklistPersonalityView({super.key, required this.answers});

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
  late GroupButtonController _dormTypeController;

  static const List<String> mbtiEIOptions = ['E', 'I'];
  static const List<String> mbtiNSOptions = ['N', 'S'];
  static const List<String> mbtiTFOptions = ['T', 'F'];
  static const List<String> mbtiPJOptions = ['P', 'J'];
  static const List<String> computerGameOptions = ['안함', '중간', '좋아함'];
  static const List<String> exerciseOptions = ['안함', '중간', '좋아함'];
  static const List<String> dormTypeOptions = ['정의관', '진리관', '개척관', '계영원', '명덕관', '신민관', '지선관', '인의관', '예지관', '양현재(남)', '양현재(여)'];

  bool validate(){
    final keysToValidate = [
      'MBTI_EI',
      'MBTI_NS',
      'MBTI_TF',
      'MBTI_PJ',
      '컴퓨터게임',
      '운동',
      '생활관'
    ];

    for (var key in keysToValidate) {
      final value = widget.answers[key];
      if(value == null || (value is String && value.isEmpty)){
        return false;
      }
    }
    return true; // 모든 항목 유효
  }

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
    _dormTypeController = GroupButtonController(
      selectedIndex: _getInitialIndex('생활관', dormTypeOptions),
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
    _exerciseController.dispose();
    _dormTypeController.dispose();
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
              Text('생활관', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: dormTypeOptions,
                controller : _dormTypeController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['생활관'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8, mainGroupAlignment: MainGroupAlignment.start),
              ),
              SizedBox(height: 36.h),
            ]
        )
    );
  }
}