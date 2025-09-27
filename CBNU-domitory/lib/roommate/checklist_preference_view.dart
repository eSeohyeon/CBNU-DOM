import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class ChecklistPreferenceView extends StatefulWidget {
  final Map<String, dynamic> answers;
  const ChecklistPreferenceView({super.key, required this.answers});

  @override
  State<ChecklistPreferenceView> createState() => _ChecklistPreferenceViewState();
}

class _ChecklistPreferenceViewState extends State<ChecklistPreferenceView> {
  static const List<String> hotOptions = ['안 탐', '많이 탐'];
  static const List<String> coldOptions = ['안 탐', '많이 탐'];
  static const List<String> bugOptions = ['극혐', '못 잡음', '중간', '잡음', '잘 잡음'];
  static const List<String> smellOptions = ['싫어요', '과자만', '상관 없음'];
  static const List<String> callInRoomOptions = ['싫어요','짧게만', '상관 없음'];
  static const List<String> inviteFriendOptions = ['싫어요', '사전 허락', '상관 없음'];

  late GroupButtonController _hotController;
  late GroupButtonController _coldController;
  late GroupButtonController _bugController;
  late GroupButtonController _smellController;
  late GroupButtonController _callInRoomController;
  late GroupButtonController _inviteFriendController;

  bool validate(){
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
      if(value == null || (value is String && value.isEmpty)){
        return false;
      }
    }
    return true; // 모든 항목 유효
  }

  @override
  void initState() {
    super.initState();

    _hotController = GroupButtonController(
      selectedIndex: _getInitialIndex('더위', hotOptions),
    );
    _coldController = GroupButtonController(
      selectedIndex: _getInitialIndex('추위', coldOptions),
    );
    _smellController = GroupButtonController(
      selectedIndex: _getInitialIndex('실내취식', smellOptions),
    );
    _callInRoomController = GroupButtonController(
      selectedIndex: _getInitialIndex('실내통화', callInRoomOptions),
    );
    _inviteFriendController = GroupButtonController(
      selectedIndex: _getInitialIndex('친구초대', inviteFriendOptions),
    );
    _bugController = GroupButtonController(
      selectedIndex: _getInitialIndex('벌레', bugOptions),
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
    _hotController.dispose();
    _coldController.dispose();
    _smellController.dispose();
    _callInRoomController.dispose();
    _inviteFriendController.dispose();
    _bugController.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('더위', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      GroupButton(
                        buttons: hotOptions,
                        controller : _hotController,
                        onSelected: (val, i, selected){
                          setState(() {
                            widget.answers['더위'] = val;
                          });
                        },
                        buttonBuilder: (selected, value, context) {
                          return checklistGroupButton(selected, value);
                        },
                        options: GroupButtonOptions(spacing: 8),
                      )
                    ]
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('추위', style: mediumBlack16),
                        SizedBox(height: 10.h),
                        GroupButton(
                          buttons: coldOptions,
                          controller : _coldController,
                          onSelected: (val, i, selected){
                            setState(() {
                              widget.answers['추위'] = val;
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8),
                        ),
                      ]
                  ),
                ]
              ),
              SizedBox(height: 36.h),
              Text('실내취식', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                buttons: smellOptions,
                controller : _smellController,
                onSelected: (val, i, selected){
                  setState(() {
                    widget.answers['실내취식'] = val;
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return checklistGroupButton(selected, value);
                },
                options: GroupButtonOptions(spacing: 8),
              ),
              SizedBox(height: 36.h),
              Text('실내통화', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: callInRoomOptions,
                  controller : _callInRoomController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['실내통화'] = val;
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
              Text('친구초대', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: inviteFriendOptions,
                  controller : _inviteFriendController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['친구초대'] = val;
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
              Text('벌레', style: mediumBlack16),
              SizedBox(height: 10.h),
              GroupButton(
                  buttons: bugOptions,
                  controller : _bugController,
                  onSelected: (val, i, selected){
                    setState(() {
                      widget.answers['벌레'] = val;
                    });
                  },
                  buttonBuilder: (selected, value, context) {
                    return checklistGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(
                      spacing: 8
                  )
              ),
            ]
        )
    );
  }
}
