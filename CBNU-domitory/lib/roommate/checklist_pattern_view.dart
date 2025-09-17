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

  final List<String> patternTitleOptions = ['기상시간', '취침시간', '샤워시각', '본가주기'];
  final List<String> wakeUpOptions = ['4시', '5시', '6시', '7시', '8시', '9시', '10시'];
  final List<String> sleepOptions = ['9시', '10시', '11시', '자정', '1시', '2시', '3시'];
  final List<String> showerOptions = ['아침샤워', '저녁샤워'];
  final List<String> homeFrequencyOptions = ['매주', '2주이상'];


  @override
  void initState() {
    super.initState();

    _wakeUpTimeController = GroupButtonController(
      selectedIndexes: _getInitialIndex('기상시간', wakeUpOptions),
    );
    _sleepTimeController = GroupButtonController(
      selectedIndexes: _getInitialIndex('취침시간', sleepOptions),
    );
    _showerTimeController = GroupButtonController(
      selectedIndexes: _getInitialIndex('샤워시각', showerOptions),
    );
    _homeFrequencyController = GroupButtonController(
      selectedIndexes: _getInitialIndex('본가주기', homeFrequencyOptions),
    );
  }

  List<int> _getInitialIndex(String key, List<String> options) {
    final value = widget.answers[key];

    if(value is String && value.isNotEmpty) {
      final index = options.indexOf(value);
      return index >= 0 ? [index] : [];
    }

    if(value is List<String>) {
      return value.map((v) => options.indexOf(v)).where((index) => index >= 0).toList();
    }

    return [];
  }

  @override
  void dispose(){
    _wakeUpTimeController.dispose();
    _sleepTimeController.dispose();
    _showerTimeController.dispose();
    _homeFrequencyController.dispose();
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
              Text('기상시간', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: wakeUpOptions,
                  controller : _wakeUpTimeController,
                  isRadio : false,
                  onSelected: (val, i, selected){
                    setState(() {
                      final selectedList = widget.answers['기상시간'];

                      if(selected) {
                        if(!selectedList.contains(val)){
                          selectedList.add(val);
                        }
                      } else {
                        selectedList.remove(val);
                      }
                      print(widget.answers['기상시간']);
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(spacing: 8, mainGroupAlignment: MainGroupAlignment.start)
              ),
              SizedBox(height: 36.h),
              Text('취침시간', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: sleepOptions,
                  controller : _sleepTimeController,
                  isRadio : false,
                  onSelected: (val, i, selected){
                    setState(() {
                      final selectedList = widget.answers['취침시간'];
                      if(selected) {
                        if(!selectedList.contains(val)){
                          selectedList.add(val);
                        }
                      } else {
                        selectedList.remove(val);
                      }
                      print(widget.answers['취침시간']);
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(spacing: 8, mainGroupAlignment: MainGroupAlignment.start)
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
            ]
        )
    );
  }
}