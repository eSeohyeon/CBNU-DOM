import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SimilarityDetailPage extends StatefulWidget {
  final Map<String, dynamic> recommendationData; // ✅ 실제 데이터 받기

  const SimilarityDetailPage({super.key, required this.recommendationData});


  @override
  State<SimilarityDetailPage> createState() => _SimilarityDetailPageState();
}

class _SimilarityDetailPageState extends State<SimilarityDetailPage> {
  List <Map<String, dynamic>> _similarities =[];
   // 유사도 데이터
  List<Color> colors = []; // 바 색상 리스트

  // 바 색상 자동 생성
  List<Color> _generatedGradientColors(Color start, Color end, int steps){
    return List.generate(
      steps,
        (index) {
          final t = index / (steps -1);
          return Color.lerp(start, end, t)!;
        }
    );
  }


  void _parseSimilarityData() {
    final data = widget.recommendationData;

    // 예시 데이터 구조:
    // {
    //   "top_features": ["취침시간", "기상시간", "더위", "벌레", "샤워시간"],
    //   "similarity_scores": {"취침시간": 0.87, "기상시간": 0.91, "더위": 0.83, "벌레": 0.72, "샤워시간": 0.89}
    // }

    final scores = Map<String, dynamic>.from(data['similarity_scores'] ?? {});

    _similarities = scores.entries.map((e) {
      return {
        "name": e.key,
        "similarity": (e.value ?? 0.0).toDouble(),
      };
    }).toList()
        ..sort((a, b) => (b['similarity'] as double).compareTo(a['similarity'] as double));


    colors = _generatedGradientColors(
      Colors.blue.shade500,
      Colors.green.shade200,
      _similarities.length,
    );
  }


  @override
  void initState() {
    super.initState();
    _parseSimilarityData();
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
                    Expanded(child: Text('추천점수에 영향을 주는 모든 항목의 유사도를 표시해요.', style: mediumGrey13))
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
