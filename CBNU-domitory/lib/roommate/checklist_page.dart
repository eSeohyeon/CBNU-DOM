import 'package:flutter/material.dart';
import 'package:untitled/bottom_navigation_tab.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_pattern_view.dart';
import 'package:untitled/roommate/checklist_personality_view.dart';
import 'package:untitled/roommate/checklist_habit_view.dart';
import 'package:untitled/roommate/checklist_preference_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:untitled/tab_view.dart';



class AnswerChecklistPage extends StatefulWidget {
  const AnswerChecklistPage({super.key});

  @override
  State<AnswerChecklistPage> createState() => _AnswerChecklistPageState();
}

class _AnswerChecklistPageState extends State<AnswerChecklistPage> {
  Map<String, dynamic> answers = {
    '취침시간': <String>[],
    '기상시간': <String>[],
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
    '잠귀' : '',
    '실내취식': '',
    '실내통화': '',
    '친구초대': '',
    '벌레': '',
    '컴퓨터 게임': '',
    '운동': '',
    '생활관' : ''
  };
  PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // 체크리스트 항목 유효성 판단할 때 쓰는 글로벌키랑 함수
  final GlobalKey<State<ChecklistPatternView>> _keyPattern = GlobalKey<State<ChecklistPatternView>>();
  final GlobalKey<State<ChecklistHabitView>> _keyHabit = GlobalKey<State<ChecklistHabitView>>();
  final GlobalKey<State<ChecklistPreferenceView>> _keyPreference = GlobalKey<State<ChecklistPreferenceView>>();
  final GlobalKey<State<ChecklistPersonalityView>> _keyPersonality = GlobalKey<State<ChecklistPersonalityView>>();

  GlobalKey _getCurrentKey() {
    switch (_currentPage) {
      case 0: return _keyPattern;
      case 1: return _keyHabit;
      case 2: return _keyPreference;
      case 3: return _keyPersonality;
      default: return _keyPattern;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


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
                        ChecklistPatternView(key: _keyPattern, answers: answers),
                        ChecklistHabitView(key: _keyHabit, answers: answers),
                        ChecklistPreferenceView(key: _keyPreference, answers: answers),
                        ChecklistPersonalityView(key: _keyPersonality, answers: answers),
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
                                final currentKey = _getCurrentKey();
                                bool isValid = false;

                                if(currentKey.currentState != null) {
                                  try {
                                    isValid = (currentKey.currentState as dynamic).validate();
                                  } catch (e) {
                                    isValid = false;
                                  }
                                }

                                if (isValid) {
                                  if(_currentPage < _totalPages - 1){
                                    _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    setState(() {
                                      _currentPage++;
                                    });
                                  } else {
                                    print(answers); // 답한거 저장
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigationTab(navigatedIndex: 1)));
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: '선택하지 않은 항목이 있습니다',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: grey,
                                      textColor: white, fontSize: 13.sp
                                  );
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
