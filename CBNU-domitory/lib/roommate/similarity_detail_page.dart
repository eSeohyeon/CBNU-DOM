import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SimilarityDetailPage extends StatefulWidget {
  const SimilarityDetailPage({super.key});

  @override
  State<SimilarityDetailPage> createState() => _SimilarityDetailPageState();
}

class _SimilarityDetailPageState extends State<SimilarityDetailPage> {
  final List<Map<String, dynamic>> _similarities = const [
    {"name": "흡연여부", "similarity": 0.95},
    {"name": "잠버릇", "similarity": 0.90},
    {"name": "청소", "similarity": 0.88},
    {"name": "소리", "similarity": 0.85},
    {"name": "기상시간", "similarity": 0.83},
    {"name": "취침시간", "similarity": 0.80},
    {"name": "샤워시각", "similarity": 0.78}, // 테스트용
    {"name": "본가주기", "similarity": 0.76},
    {"name": "더위", "similarity": 0.74},
    {"name": "추위", "similarity": 0.72},
    {"name": "향 민감도", "similarity": 0.70},
    {"name": "실내통화", "similarity": 0.68},
    {"name": "친구초대", "similarity": 0.65},
    {"name": "벌레", "similarity": 0.62},
    {"name": "컴퓨터 게임", "similarity": 0.60},
    {"name": "운동", "similarity": 0.58},
  ]; // 유사도 데이터
  List<Color> colors = []; // 바 색상 리스트

  // 바 색상 자동 생성
  List<Color> generatedGradientColors(Color start, Color end, int steps){
    return List.generate(
      steps,
        (index) {
          final t = index / (steps -1);
          return Color.lerp(start, end, t)!;
        }
    );
  }

  @override
  void initState() {
    super.initState();
    colors = generatedGradientColors(Colors.blue.shade500, Colors.green.shade200, _similarities.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text('항목별 유사도', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: grey, size: 20),
                    SizedBox(width: 4.w),
                    Expanded(child: Text('체크리스트의 모든 항목에 대한 유사도를 표시하고 있어요.', style: mediumGrey13))
                  ]
                ),
              ),
              SizedBox(height: 4.h),
              ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _similarities.length,
                  itemBuilder: (context, index) {
                    final factor = _similarities[index]['name'];
                    final similarity = _similarities[index]['similarity'] as double;
                    final color = colors[index];
          
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(factor, style: mediumBlack16),
                                    Text('${(similarity * 100).toStringAsFixed(1)}%', style: mediumGrey14)
                                  ]
                              ),
                              SizedBox(height: 4.h),
                              LinearPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 24,
                                percent: similarity,
                                backgroundColor: Colors.grey.shade300,
                                progressColor: color,
                                barRadius: const Radius.circular(20),
                              )
                            ]
                        )
                    );
                  }
              )
            ]
          ),
        )
      )
    );
  }
}
