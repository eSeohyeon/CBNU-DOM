import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class ChecklistHabitView extends StatefulWidget {
  final Map<String, dynamic> answers;
  const ChecklistHabitView({super.key, required this.answers});

  @override
  State<ChecklistHabitView> createState() => _ChecklistHabitViewState();
}

class _ChecklistHabitViewState extends State<ChecklistHabitView> {
  late GroupButtonController _smokingController;
  late GroupButtonController _sleepingHabitController;
  late GroupButtonController _cleaningFrequencyController;
  late GroupButtonController _soundController;

  final List<String> habitTitleOptions = ['흡연여부', '잠버릇', '청소', '소리'];
  final List<String> smokingOptions = ['흡연', '비흡연'];
  final List<String> sleepingHabitOptions = ['없음', '코골이', '이갈이', '잠꼬대'];
  final List<String> cleaningFrequencyOptions = ['수시로', '한 번에'];
  final List<String> soundOptions = ['이어폰', '스피커'];

  @override
  void initState() {
    super.initState();
    _smokingController = GroupButtonController(
      selectedIndex: _getInitialIndex('흡연여부', smokingOptions),
    );
    _sleepingHabitController = GroupButtonController(
      selectedIndex: _getInitialIndex('잠버릇', sleepingHabitOptions),
    );
    _cleaningFrequencyController = GroupButtonController(
      selectedIndex: _getInitialIndex('청소', cleaningFrequencyOptions),
    );
    _soundController = GroupButtonController(
      selectedIndex: _getInitialIndex('소리', soundOptions),
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
    _smokingController.dispose();
    _sleepingHabitController.dispose();
    _cleaningFrequencyController.dispose();
    _soundController.dispose();
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
              Text('흡연여부', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: smokingOptions,
                controller : _smokingController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['흡연여부'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
              Text('잠버릇', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: sleepingHabitOptions,
                controller : _sleepingHabitController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['잠버릇'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
              Text('청소', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: cleaningFrequencyOptions,
                controller : _cleaningFrequencyController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['청소'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
              Text('소리', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: soundOptions,
                  controller : _soundController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['소리'] = val;
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(
                      spacing: 8
                  )
              ),
              SizedBox(height: 36.h),
            ]
        )
    );
  }
}

