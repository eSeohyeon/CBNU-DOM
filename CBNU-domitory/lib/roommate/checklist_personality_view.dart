import 'package:flutter/material.dart';
import 'package:untitled/themes/styles.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

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
  final List<String> mbtiEIOptions = ['E', 'I'];
  final List<String> mbtiNSOptions = ['N', 'S'];
  final List<String> mbtiTFOptions = ['T', 'F'];
  final List<String> mbtiPJOptions = ['P', 'J'];

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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              )
            ]
        )
    );
  }
}