import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/common/custom_text_field.dart';
import 'package:untitled/home/dorm_score_ranking.dart';

class DormScoreCalculate extends StatefulWidget {
  const DormScoreCalculate({super.key});

  @override
  State<DormScoreCalculate> createState() => _DormScoreCalculateState();
}

class _DormScoreCalculateState extends State<DormScoreCalculate> {
  final _lastGpaController = TextEditingController();
  final _completedSemesterController = TextEditingController();
  final _residenceController = TextEditingController();
  final _penaltyController = TextEditingController();

  late double _calculatedDormScore = 0;
  late double _gpaScore =0;
  late double _semesterScore = 0;
  late double _residenceScore = 0;
  late double _penaltyScore = 0;

  @override
  void initState(){
    super.initState();
    _lastGpaController.addListener(() {
      setState(() {
        _calculateDormScore();
      });
    });
    _completedSemesterController.addListener(() {
      setState(() {
        _calculateDormScore();
      });
    });
    _residenceController.addListener(() {
      setState(() {
        _calculateDormScore();
      });
    });
    _penaltyController.addListener(() {
      setState(() {
        _calculateDormScore();
      });
    });
  }

  @override
  void dispose() {
    _lastGpaController.dispose();
    _completedSemesterController.dispose();
    _residenceController.dispose();
    _penaltyController.dispose();
    super.dispose();
  }

  void _calculateDormScore(){
    int input_semester = int.parse(_completedSemesterController.text);
    int input_residence = int.parse(_residenceController.text);

    if(_lastGpaController.text.isEmpty){
      _gpaScore = 0;
    } else {
      _gpaScore = double.parse(_lastGpaController.text)*17 +3.5;
    }

    if(_penaltyController.text.isEmpty){
      _penaltyScore = 0;
    } else {
      _penaltyScore = double.parse(_penaltyController.text);
    }

    if(input_semester == 1) {
      _semesterScore = 10;
    } else if(input_semester==2 || input_semester==3){
      _semesterScore = 8;
    } else if(input_semester==4 || input_semester==5){
      _semesterScore = 6;
    } else if(input_semester>=6){
      _semesterScore = 4;
    }

    if(input_residence == 0 || input_residence<4){
      _residenceScore = 10;
    } else if(input_residence>=4 && input_residence<=8){
      _residenceScore = 8;
    } else if(input_residence>8 && input_residence<=16){
      _residenceScore = 6;
    } else if(input_residence>16 && input_residence<=24){
      _residenceScore = 4;
    } else if(input_residence>24 && input_residence<=36){
      _residenceScore = 2;
    } else if(input_residence>36){
      _residenceScore = 0;
    }

    _calculatedDormScore = _gpaScore + _semesterScore + _residenceScore + _penaltyScore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        title: Text('환산점수 계산기', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${_calculatedDormScore.toStringAsFixed(1)}", style: boldBlack28.copyWith(fontSize: 48.sp)),
                        SizedBox(width: 4.w),
                        Text('점', style: boldBlack20.copyWith(fontSize: 32.sp))
                      ]
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                            children: [
                              Text('학점', style: mediumGrey14),
                              Text("${_gpaScore.toStringAsFixed(1)}", style: mediumBlack16)
                            ]
                        ),
                        SizedBox(width: 28.w),
                        Column(
                            children: [
                              Text('이수학기', style: mediumGrey14),
                              Text("${_semesterScore}", style: mediumBlack16)
                            ]
                        ),
                        SizedBox(width: 28.w),
                        Column(
                            children: [
                              Text('입주경력', style: mediumGrey14),
                              Text("${_residenceScore}", style: mediumBlack16)
                            ]
                        ),
                        SizedBox(width: 28.w),
                        Column(
                            children: [
                              Text('상벌점', style: mediumGrey14),
                              Text("${_penaltyScore}", style: mediumBlack16)
                            ]
                        ),
                        SizedBox(width: 28.w),
                      ]
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('직전학기 학점', style: mediumBlack16),
                    SizedBox(height: 10.h),
                    SizedBox(width: 100.w, child: CustomTextField(controller: _lastGpaController, name: '예)3.5', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength:4)),
                    SizedBox(height: 20.h),
                    Text('이수학기', style: mediumBlack16),
                    SizedBox(height: 10.h),
                    SizedBox(width: 120.w, child: CustomTextField(controller: _completedSemesterController, name: '예)3', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength:1, suffix: '학기')),
                    SizedBox(height: 20.h),
                    Text('입주경력', style: mediumBlack16),
                    SizedBox(height: 10.h),
                    SizedBox(width: 130.w, child: CustomTextField(controller: _residenceController, name: '예)4', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength:2, suffix: '개월')),
                    SizedBox(height: 20.h),
                    Text('상벌점', style: mediumBlack16),
                    SizedBox(height: 10.h),
                    SizedBox(width: 200.w, child: CustomTextField(controller: _penaltyController, name: '누적 상벌점의 총합을 입력하세요.', inputType: TextInputType.visiblePassword, maxLines: 1, maxLength:2)),
                  ]
                )
              ),
            )
          ]
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  onPressed: () {
                    // 저장 로직
                    Navigator.pop(context, _calculatedDormScore);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: black, padding: EdgeInsets.only(top: 6.h, bottom: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 2,),
                  child: Text('저장하기', style: mediumWhite16),
                ),
              )
          )
      ),
    );
  }
}
