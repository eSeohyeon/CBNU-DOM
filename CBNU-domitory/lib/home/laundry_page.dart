import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:untitled/home/laundry_card_modal.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:untitled/laundry/notification_service.dart';


/*
추가할 기능
2. 백그라운드
3. 끝 푸쉬알림
*/


class LaundryPage extends StatefulWidget {
  const LaundryPage({super.key});

  @override
  State<LaundryPage> createState() => _LaundryPageState();
}

class _LaundryPageState extends State<LaundryPage> {
  bool _isRunning = false;
  int timer_duration = 0; // 기본 45분
  late DateTime end_time;
  late GroupButtonController _timerController;
  late CountDownController _countDownController;
  //final NotificationService _notificationService = NotificationService();

  @override
  void initState(){
    _timerController = GroupButtonController();
    _countDownController = CountDownController();
    //_notificationService.init();
    super.initState();
  }

  @override
  void dispose(){
    _timerController.dispose();
    super.dispose();
  }

  String durationFormatter(int sec){ // 초 -> 시:분:초 형식으로 바꿔줌
    final duration = Duration(seconds: sec);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$secs";
  }

  Widget timerGroupButton(bool selected, int value){
    final duration = durationFormatter(value);
    final String task;
    if(value == 10){
      task = '세탁';
    } else if(value == 3000){
      task = '건조 1회';
    } else if(value == 6000){
      task = '건조 2회';
    } else {
      task = 'null';
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: selected ? black : white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: selected ? black : group_button_outline, width: 1.0)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(task, style: selected? mediumWhite14 : mediumBlack14),
            Text(duration, style: mediumGrey13)
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('세탁 타이머', style: mediumBlack16),
        titleSpacing: 0,
        backgroundColor: white,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(_isRunning)...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularCountDownTimer(
                        width: 220.w,
                        height: 220.h,
                        duration: timer_duration,
                        controller: _countDownController,
                        fillColor: black,
                        ringColor: grey_outline_inputtext,
                        strokeWidth: 12.0,
                        strokeCap: StrokeCap.round,
                        textStyle: boldBlack24,
                        textFormat: CountdownTextFormat.HH_MM_SS,
                        isReverse: true,
                        isReverseAnimation: true,
                        onStart: () {
                          print('Countdown started');
                        },
                        onComplete: () {
                          print('Countdown ended');
                          setState(() {
                            _isRunning = false;
                          });
                        },
                      ),
                      Positioned(
                        bottom: 72.h,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_rounded, size: 18, color: grey),
                              SizedBox(width: 6.w),
                              Text(DateFormat('HH:mm').format(end_time), style: mediumGrey13)
                            ]
                        ),
                      ),
                    ]
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if(_countDownController.isPaused.value){
                                _countDownController.resume();
                                print('countdown resumed');
                              } else {
                                _countDownController.pause();
                                print(_countDownController.isPaused);
                                print('countdown paused');
                              }
                            });
                          },
                          child: Text(_countDownController.isPaused.value ? '재개' : '일시정지' , style: mediumWhite14.copyWith(color: black_semi)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: grey_button_greyBG,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                          )
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _countDownController.reset();
                            });
                          },
                          child: Text('정지', style: mediumWhite14),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                          )
                      )
                    ],
                  )
                ],
                if(!_isRunning)...[
                  Text('시간을 선택해주세요', style: mediumBlack18),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GroupButton(
                        buttons: [10, 3000, 6000],
                        controller : _timerController,
                        onSelected: (val, i, selected){
                          setState(() {
                            timer_duration = val;
                          });
                        },
                        buttonBuilder: (selected, value, context) {
                          return timerGroupButton(selected, value);
                        },
                        options: GroupButtonOptions(spacing: 8),
                      ),
                    ]
                  ),
                  SizedBox(height: 28.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if(_timerController.selectedIndex != null){
                          end_time = DateTime.now().add(Duration(seconds: timer_duration));
                          //_notificationService.showTimerEndNotification(timer_duration);
                          print('완료 함수 실행');
                          _isRunning = true;
                        } else {
                          Fluttertoast.showToast(
                              msg: '시간을 선택해주세요',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: grey,
                              textColor: white, fontSize: 13.sp
                          );
                        }
                      });
                    },
                    child: Text('시작', style: mediumWhite14),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    )
                  )
                ],
              ]
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
                onPressed: () { showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => LaundryCardModal(),
                  isDismissible: true,
                  enableDrag: false
                );},
                style: ElevatedButton.styleFrom(
                  backgroundColor: white,
                  side: BorderSide(color: grey_outline_inputtext),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                  elevation: 0
                ),
                child: Text('세탁카드 잔액확인', style: mediumBlack16.copyWith(color: black_semi))),
          )
      ),
    );
  }
}
