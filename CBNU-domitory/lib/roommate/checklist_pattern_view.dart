import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class ChecklistPatternView extends StatefulWidget {
  final Map<String, dynamic> answers;
  ChecklistPatternView({super.key, required this.answers});

  @override
  State<ChecklistPatternView> createState() => _ChecklistPatternViewState();
}

class _ChecklistPatternViewState extends State<ChecklistPatternView> {
  late GroupButtonController _wakeUpTimeController;
  late GroupButtonController _sleepTimeController;
  late GroupButtonController _showerTimeController;
  late GroupButtonController _homeFrequencyController;
  late GroupButtonController _smokingController;
  late GroupButtonController _sleepingHabitController;
  late GroupButtonController _cleaningFrequencyController;
  late GroupButtonController _soundController;
  final List<String> wakeUpOptions = ['5시 이전', '6시', '7~8시', '9시', '10시 이후'];
  final List<String> sleepOptions = ['9시 이전', '자정 이전', '자정 이후', '2시 이후'];
  final List<String> showerOptions = ['아침샤워', '저녁샤워'];
  final List<String> homeFrequencyOptions = ['매주', '2주이상'];
  final List<String> smokingOptions = ['흡연', '비흡연'];
  final List<String> sleepingHabitOptions = ['없음', '코골이', '이갈이', '잠꼬대'];
  final List<String> cleaningFrequencyOptions = ['수시로', '한 번에'];
  final List<String> soundOptions = ['이어폰', '스피커'];


  @override
  void initState() {
    super.initState();

    _wakeUpTimeController = GroupButtonController(
      selectedIndex: _getInitialIndex('기상시간', wakeUpOptions),
    );
    _sleepTimeController = GroupButtonController(
      selectedIndex: _getInitialIndex('취침시간', sleepOptions),
    );
    _showerTimeController = GroupButtonController(
      selectedIndex: _getInitialIndex('샤워시각', showerOptions),
    );
    _homeFrequencyController = GroupButtonController(
      selectedIndex: _getInitialIndex('본가주기', homeFrequencyOptions),
    );
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기상시간', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: wakeUpOptions,
                  controller : _wakeUpTimeController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['기상시간'] = val;
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(spacing: 8)
              ),
              SizedBox(height: 36.h),
              Text('취침시간', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: sleepOptions,
                  controller : _sleepTimeController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['취침시간'] = val;
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(spacing: 8)
              ),
              SizedBox(height: 36.h),
              Text('샤워시각', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: showerOptions,
                  controller : _showerTimeController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['샤워시각'] = val;
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(spacing: 8)
              ),
              SizedBox(height: 36.h),
              Text('본가주기', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: homeFrequencyOptions,
                controller : _homeFrequencyController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['본가주기'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
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