import 'dart:convert';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:untitled/home/laundry_card_modal.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:group_button/group_button.dart';

class LaundryPage extends StatefulWidget {
  const LaundryPage({super.key});

  @override
  State<LaundryPage> createState() => _LaundryPageState();
}

class _LaundryPageState extends State<LaundryPage> {
  bool _isRunning = false;
  int timer_duration = 0; // 기본 45분

  late GroupButtonController _timerController;

  @override
  void initState(){
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
    if(value == 2700){
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
            Text(task, style: mediumBlack14),
            Text(duration, style: mediumGrey13)
          ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('세탁 타이머', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          if(_isRunning)...[

          ],
          if(!_isRunning)...[
            Text('시간을 선택해주세요', style: mediumBlack16),
            SizedBox(height: 12.h),
            Row(
              children: [
                GroupButton(
                  buttons: [2700, 3000, 6000],
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
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {},
              child: Text('시작', style: mediumWhite14),
              style: ElevatedButton.styleFrom(
                backgroundColor: black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
              )
            )
          ],
        ]
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
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
                ),
                child: Text('세탁카드 잔액확인', style: mediumBlack16.copyWith(color: black_semi))),
          )
      ),
    );
  }
}
