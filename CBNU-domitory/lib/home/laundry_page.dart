import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:untitled/home/laundry_card_modal.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import 'package:untitled/laundry/notification_service.dart';


class LaundryPage extends StatefulWidget {
  const LaundryPage({super.key});

  @override
  State<LaundryPage> createState() => _LaundryPageState();
}

class _LaundryPageState extends State<LaundryPage> {
  bool _isRunning = false;
  int timer_duration = 0;
  late DateTime end_time;
  late StopWatchTimer timer;
  late GroupButtonController _timerController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState(){
    super.initState();
    _timerController = GroupButtonController();
    _notificationService.init();
    timer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: 0,
    );
    _restoreTimer();
  }

  @override
  void dispose(){
    _timerController.dispose();
    timer.dispose();
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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

  Future<void> _startTimer(DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('laundry_end_time', end.toIso8601String());
    await prefs.setInt('laundry_duration', timer_duration);

    timer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(timer_duration)
    );
    _notificationService.showTimerEndNotification(end_time);
    timer.onStartTimer();
    timer.rawTime.listen((value) async {
      if(value <= 0){
        _handleTimerEnd();
      }
    });

    setState(() {
      _isRunning = true;
    });
  }

  Future<void> _handleTimerEnd() async { // 타이머 끝났을 때
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('laundry_end_time');
    await prefs.remove('laundry_duration');

    timer.onStopTimer();
    timer.onResetTimer();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _stopTimer() async { // 중지버튼 눌렀을 때
    final prefs = await SharedPreferences.getInstance();
    _notificationService.cancelNotification();
    await prefs.remove('laundry_end_time');
    await prefs.remove('laundry_duration');

    timer.onResetTimer();

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _restoreTimer() async { // 화면 닫았다 다시 들어와도 타이머 유지되게 함
    final prefs = await SharedPreferences.getInstance();
    final endTimeStr = prefs.getString('laundry_end_time');
    final totalDur = prefs.getInt('laundry_duration') ?? 0;

    if(endTimeStr != null && totalDur > 0){
      final storedEndTime = DateTime.parse(endTimeStr);
      final remaining = storedEndTime.difference(DateTime.now()).inSeconds;

      if(remaining > 0) {
        timer = StopWatchTimer(
          mode: StopWatchMode.countDown,
          presetMillisecond: StopWatchTimer.getMilliSecFromSecond(remaining)
        );
        timer.onStartTimer();
        timer.rawTime.listen((value) async {
          if(value <= 0){
            _handleTimerEnd();
          }
        });

        setState(() {
          end_time = storedEndTime;
          timer_duration = totalDur;
          _isRunning = true;
        });

      } else {
        prefs.remove('laundry_end_time');
        prefs.remove('laundry_duration');
      }
    } else {
      timer = StopWatchTimer(
        mode: StopWatchMode.countDown,
        presetMillisecond: 0
      );
    }
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(_isRunning)...[
                        Transform.scale(scale: 1.3, child: Lottie.asset('assets/lottie_washing.json', width: 200.w, height: 200.h, fit: BoxFit.cover)),
                        StreamBuilder<int>(
                          stream: timer.rawTime,
                          initialData: timer.rawTime.value,
                          builder: (context, snapshot) {
                            final value = snapshot.data!;
                            final displayTime = StopWatchTimer.getDisplayTime(
                              value,
                              hours: true,
                              minute: true,
                              second: true,
                              milliSecond: false
                            );
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  displayTime,
                                  style: boldBlack28.copyWith(fontSize: 32.sp)
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.notifications_rounded, size: 18, color: grey),
                                      SizedBox(width: 4.w),
                                      Text(DateFormat('HH:mm').format(end_time), style: mediumGrey14.copyWith(fontSize: 16.sp))
                                    ]
                                ),
                                SizedBox(height: 28.h),
                                SizedBox(
                                  width: 80.w,
                                  height: 36.h,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _notificationService.cancelNotification();
                                          _stopTimer();
                                          _isRunning = false;
                                        });
                                      },
                                      child: Text('정지', style: mediumWhite16),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                                      )
                                  ),
                                )
                              ]
                            );
                          }
                        ),
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
                        SizedBox(
                          width: 80.w,
                          child: ElevatedButton(
                            onPressed: () {
                              if(_timerController.selectedIndex != null){
                                end_time = DateTime.now().add(Duration(seconds: timer_duration));
                                _startTimer(end_time);
                                print(end_time);
                              } else {
                                Fluttertoast.showToast(
                                    msg: '시간을 선택해주세요',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: grey,
                                    textColor: white, fontSize: 13.sp
                                );
                              }
                            },
                            child: Text('시작', style: mediumWhite16),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                              padding: EdgeInsets.symmetric(vertical: 10.h)
                            )
                          ),
                        )
                      ],
                    ]
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h, top: 10.h),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
