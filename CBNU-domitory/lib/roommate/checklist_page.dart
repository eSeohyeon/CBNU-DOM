import 'package:flutter/material.dart';
import 'package:untitled/bottom_navigation_tab.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_pattern_view.dart';
import 'package:untitled/roommate/checklist_personality_view.dart';
//import 'package:untitled/tab_view.dart';



class AnswerChecklistPage extends StatefulWidget {
  const AnswerChecklistPage({super.key});

  @override
  State<AnswerChecklistPage> createState() => _AnswerChecklistPageState();
}

class _AnswerChecklistPageState extends State<AnswerChecklistPage> {
  Map<String, dynamic> answers = {
    '취침시간': '',
    '기상시간': '',
    '샤워시각': '',
    '본가주기': '',
    '흡연여부': '',
    '잠버릇': '',
    '청소': '',
    '소리': '',
    'MBTI_EI': '',
    'MBTI_NS': '',
    'MBTI_TF': '',
    'MBTI_PJ': '',
    '더위': '',
    '추위': '',
    '잠귀': '',
    '실내통화': '',
    '친구초대': '',
    '벌레': '',
    '실내취식': '',
    '컴퓨터 게임': '',
    '운동': '',
    '준비중': '',
  };
  PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: white,
          title: Text('체크리스트 작성', style: boldBlack18),
          titleSpacing: 0,
        ),
        body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ChecklistPatternView(answers: answers),
                        ChecklistPersonalityView(answers: answers),
                        //ChecklistPreferenceView(answers: answers),
                        //ChecklistEtcView(answers: answers),
                      ]
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentPage > 0)
                            ElevatedButton(
                                onPressed: () {
                                  _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  setState(() {
                                    _currentPage--;
                                  });
                                },
                                child: Text('이전', style: mediumBlack14),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: grey_button,
                                  elevation: 0,

                                )
                            ),
                          ElevatedButton(
                              onPressed: () {
                                if(_currentPage < _totalPages - 1){
                                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  setState(() {
                                    _currentPage++;
                                  });
                                } else {
                                  print(answers);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigationTab(navigatedIndex: 1)));
                                }
                              },
                              child: Text('다음 ${_currentPage + 1}/$_totalPages', style: mediumWhite14),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: black,
                                  elevation: 0
                              )
                          )
                        ]
                    )
                )
              ],
            )
        )
    );
  }
}
