import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class AddFilterModal extends StatefulWidget {
  List<Map<String, String>> addedFilters;
  AddFilterModal({super.key, required this.addedFilters});

  @override
  State<AddFilterModal> createState() => _AddFilterModalState();
}

class _AddFilterModalState extends State<AddFilterModal> {
  final List<Map<String, String>> _addedFilters = [];

  static const List<String> _smokingOptions = ['비흡연', '흡연'];
  static const List<String> _cleaningFrequencyOptions = ['수시로', '한 번에'];
  static const List<String> _sleepingHabitOptions = ['없음', '있음'];
  static const List<String> _soundOptions = ['이어폰', '스피커'];
  static const List<String> _sleepingEarOptions = ['밝음', '어두움'];
  static const List<String> _callInRoomOptions = ['싫어요', '짧게만', '상관 없음'];
  static const List<String> _smellOptions = ['싫어요', '과자류만', '상관 없음'];
  static const List<String> _inviteFriendOptions = ['싫어요', '사전 허락', '상관 없음'];
  static const List<String> _bugOptions = ['싫어요', '세스코'];
  late GroupButtonController _smokingController;
  late GroupButtonController _cleaningFrequencyController;
  late GroupButtonController _sleepingHabitController;
  late GroupButtonController _soundController;
  late GroupButtonController _sleepingEarController;
  late GroupButtonController _callInRoomController;
  late GroupButtonController _smellController;
  late GroupButtonController _inviteFriendController;
  late GroupButtonController _bugController;

  @override
  void initState() {
    super.initState();

    _addedFilters.addAll(widget.addedFilters);

    _smokingController = GroupButtonController();
    _cleaningFrequencyController = GroupButtonController();
    _sleepingEarController = GroupButtonController();
    _soundController = GroupButtonController();
    _sleepingHabitController = GroupButtonController();
    _callInRoomController = GroupButtonController();
    _smellController = GroupButtonController();
    _inviteFriendController = GroupButtonController();
    _bugController = GroupButtonController();

    _updateGroupButtonSelection();
  }

  void _updateGroupButtonSelection() {
    for(var filter in _addedFilters) {
      final key = filter.keys.first;
      final value = filter.values.first;

      switch(key) {
        case '흡연여부':
          int index = _smokingOptions.indexOf(value);
          if(index != -1) _smokingController.selectIndex(index);
          break;
        case '청소':
          int index = _cleaningFrequencyOptions.indexOf(value);
          if(index != -1) _cleaningFrequencyController.selectIndex(index);
          break;
        case '잠버릇':
          int index = _sleepingHabitOptions.indexOf(value);
          if(index != -1) _sleepingHabitController.selectIndex(index);
          break;
        case '소리':
          int index = _soundOptions.indexOf(value);
          if(index != -1) _soundController.selectIndex(index);
          break;
        case '잠귀':
          int index = _sleepingEarOptions.indexOf(value);
          if(index != -1) _sleepingEarController.selectIndex(index);
          break;
        case '실내통화':
          int index = _callInRoomOptions.indexOf(value);
          if(index != -1) _callInRoomController.selectIndex(index);
          break;
        case '실내취식':
          int index = _smellOptions.indexOf(value);
          if(index != -1) _smellController.selectIndex(index);
          break;
        case '친구초대':
          int index = _inviteFriendOptions.indexOf(value);
          if(index != -1) _inviteFriendController.selectIndex(index);
          break;
        case '벌레':
          int index = _bugOptions.indexOf(value);
          if(index != -1) _bugController.selectIndex(index);
          break;
      }
    }
  }

  List<Widget> _buildSelectedFilters() {
    List<Widget> buttons = [];
    for (var filter in _addedFilters) {
      buttons.add(
          Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '${filter.keys.first} : ${filter.values.first}',
                            style: mediumWhite14
                        ),
                        SizedBox(width: 4.w),
                        InkWell(
                            child: Icon(Icons.close_rounded, color: white, size: 16),
                            onTap: () {
                              setState(() {
                                _addedFilters.remove(filter);
                              });
                              _clearGroupButtonSelection(filter);
                            }
                        )
                      ]
                  )
              )
          )
      );
    } // 최고의 하루

    return buttons;
  }

  void _clearGroupButtonSelection(Map<String, String> filter) {
    String key = filter.keys.first;

    switch(key) {
      case '흡연여부':
        _smokingController.unselectAll();
        break;
      case '청소':
        _cleaningFrequencyController.unselectAll();
        break;
      case '잠버릇':
        _sleepingHabitController.unselectAll();
        break;
      case '소리':
        _soundController.unselectAll();
        break;
      case '잠귀':
        _sleepingEarController.unselectAll();
        break;
      case '실내통화':
        _callInRoomController.unselectAll();
        break;
      case '실내취식':
        _smellController.unselectAll();
        break;
      case '친구초대':
        _inviteFriendController.unselectAll();
        break;
      case '벌레':
        _bugController.unselectAll();
        break;
    }
  }

  void _resetAllFilters() {
    setState(() {
      _addedFilters.clear();
    });

    _smokingController.unselectAll();
    _cleaningFrequencyController.unselectAll();
    _sleepingHabitController.unselectAll();
    _soundController.unselectAll();
    _sleepingEarController.unselectAll();
    _callInRoomController.unselectAll();
    _smellController.unselectAll();
    _inviteFriendController.unselectAll();
    _bugController.unselectAll();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 0.7.sh,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('추가조건 선택', style: boldBlack18),
                    ]
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                      children: [
                        InkWell(
                            child: Container(
                                padding: EdgeInsets.all(6.0),
                                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: group_button_outline, width: 1.0)),
                                child: Icon(Icons.refresh_rounded, color: black, size: 20)
                            ),
                            onTap: () {
                              _resetAllFilters();
                              }
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _buildSelectedFilters()
                                )
                            )
                        )
                      ]
                  )
              ),
              SizedBox(height: 10.h),
              Container(height: 1, color: grey_seperating_line),
              SizedBox(height: 16.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text('흡연여부', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _smokingController,
                          buttons: _smokingOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '흡연여부');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                    msg: '최대 2개까지만 설정 가능합니다',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: grey,
                                    textColor: white, fontSize: 13.sp
                                  );
                                  _smokingController.unselectAll();
                                } else {
                                  _addedFilters.add({'흡연여부':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('청소', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _cleaningFrequencyController,
                          buttons: _cleaningFrequencyOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '청소');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _cleaningFrequencyController.unselectAll();
                                } else {
                                  _addedFilters.add({'청소':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('잠버릇', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _sleepingHabitController,
                          buttons: _sleepingHabitOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '잠버릇');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _sleepingHabitController.unselectAll();
                                } else {
                                  _addedFilters.add({'잠버릇':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('소리', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _soundController,
                          buttons: _soundOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '소리');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _soundController.unselectAll();
                                } else {
                                  _addedFilters.add({'소리':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('잠귀', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _sleepingEarController,
                          buttons: _sleepingEarOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '잠귀');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _sleepingEarController.unselectAll();
                                } else {
                                  _addedFilters.add({'잠귀':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('실내통화', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _callInRoomController,
                          buttons: _callInRoomOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '실내통화');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _callInRoomController.unselectAll();
                                } else {
                                  _addedFilters.add({'실내통화':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('실내취식', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _smellController,
                          buttons: _smellOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '실내취식');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _smellController.unselectAll();
                                } else {
                                  _addedFilters.add({'실내취식':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('친구초대', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _inviteFriendController,
                          buttons: _inviteFriendOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '친구초대');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _inviteFriendController.unselectAll();
                                } else {
                                  _addedFilters.add({'친구초대':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text('벌레', style: mediumBlack16),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GroupButton(
                          controller: _bugController,
                          buttons: _bugOptions,
                          onSelected: (val, i, selected){
                            setState(() {
                              _addedFilters.removeWhere((filter) => filter.keys.first == '벌레');
                              if(selected){
                                if(_addedFilters.length >= 2){
                                  Fluttertoast.showToast(
                                      msg: '최대 2개까지만 설정 가능합니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
                                  _bugController.unselectAll();
                                } else {
                                  _addedFilters.add({'벌레':val});
                                }
                              }
                            });
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 8, alignment: Alignment.centerLeft),
                        ),
                      ),
                      SizedBox(height: 22.h),
                    ]
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _addedFilters);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: black,
                          overlayColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                          elevation: 0
                      ),
                      child: Text('조건 적용하고 닫기', style: boldWhite15)
                  ),
                ),
              )
            ]
          )
        )
      )
    );
  }
}
