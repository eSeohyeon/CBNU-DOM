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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnswerChecklistPage extends StatefulWidget {
  const AnswerChecklistPage({super.key});

  @override
  State<AnswerChecklistPage> createState() => _AnswerChecklistPageState();
}

class _AnswerChecklistPageState extends State<AnswerChecklistPage> {
  Map<String, dynamic> answers = {
    '취침시간': <String>[],
    '기상시간': <String>[],
    '샤워시각': <String>[],
    '본가주기': '',
    '흡연여부': '',
    '잠버릇': <String>[],
    '청소': <String>[],
    '소리': <String>[],
    'MBTI_EI': '',
    'MBTI_NS': '',
    'MBTI_TF': '',
    'MBTI_PJ': '',
    '더위': <String>[],
    '추위': <String>[],
    '잠귀' : <String>[],
    '실내취식': <String>[],
    '실내통화': <String>[],
    '친구초대': <String>[],
    '벌레': <String>[],
    '컴퓨터게임': '',
    '운동': '',
    '생활관' : ''
  };

  PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // 체크리스트 항목 유효성 판단
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

  // 카테고리별 구조 생성
  Map<String, Map<String, dynamic>> _categorizeChecklist(Map<String, dynamic> flatAnswers) {
    return {
      "생활패턴": {
        "기상시간": flatAnswers['기상시간'],
        "취침시간": flatAnswers['취침시간'],
        "샤워시각": flatAnswers['샤워시각'],
        "본가주기": flatAnswers['본가주기'],
      },
      "생활습관": {
        "흡연여부": flatAnswers['흡연여부'],
        "잠버릇": flatAnswers['잠버릇'],
        "청소": flatAnswers['청소'],
        "소리": flatAnswers['소리'],
      },
      "성격": {
        "MBTI_EI": flatAnswers['MBTI_EI'],
        "MBTI_NS": flatAnswers['MBTI_NS'],
        "MBTI_TF": flatAnswers['MBTI_TF'],
        "MBTI_PJ": flatAnswers['MBTI_PJ'],
      },
      "성향": {
        "더위": flatAnswers['더위'],
        "추위": flatAnswers['추위'],
        "잠귀": flatAnswers['잠귀'],
        "실내통화": flatAnswers['실내통화'],
        "친구초대": flatAnswers['친구초대'],
        "벌레": flatAnswers['벌레'],
        "실내취식": flatAnswers['실내취식'],
      },
      "취미/기타": {
        "컴퓨터게임": flatAnswers['컴퓨터게임'],
        "운동": flatAnswers['운동'],
        "생활관": flatAnswers['생활관'],
      }
    };
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
                ],
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
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      final currentKey = _getCurrentKey();
                      bool isValid = false;

                      if (currentKey.currentState != null) {
                        try {
                          isValid = (currentKey.currentState as dynamic).validate();
                        } catch (e) {
                          isValid = false;
                        }
                      }

                      if (isValid) {
                        if (_currentPage < _totalPages - 1) {
                          _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                          setState(() {
                            _currentPage++;
                          });
                        } else {
                          // 현재 로그인한 사용자 UID 가져오기
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Map<String, Map<String, dynamic>> categorizedChecklist = _categorizeChecklist(answers);

                            await FirebaseFirestore.instance
                                .collection('checklists')
                                .doc(user.uid)
                                .set({'checklist': categorizedChecklist});
                          }

                          Navigator.pop(context, true);
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: '선택하지 않은 항목이 있습니다',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: grey,
                          textColor: white,
                          fontSize: 13.sp,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: black,
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage < _totalPages - 1
                          ? '다음 ${_currentPage + 1}/$_totalPages'
                          : '완료',
                      style: mediumWhite14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
