import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_page.dart';
import 'package:untitled/roommate/filter_select_modal.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/roommate/roommate_detail_modal.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:group_button/group_button.dart';
import 'package:untitled/models/group_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

const Map<String, List<String>> collegeToDepartments = {
  '인문대': ['국어국문학과', '중어중문학과', '영어영문학과', '독일언어문화학과', '프랑스언어문화학과', '철학과', '사학과', '고고미술사학과', '글로벌K컬처학과', '인문학자율전공학부'],
  '사과대': ['사회학과', '심리학과', '행정학과', '정치외교학과', '경제학과'],
  '자과대': ['수학과', '정보통계학과', '물리학과', '화학과', '생물학과', '미생물학과', '생화학과', '천문우주학과', '지구환경과학과'],
  '경영대': ['경영학부', '국제경영학과', '경영정보학과', '경영학자율전공학부'],
  '공과대': ['기계공학부', '토목공학부', '건축공학과', '전기공학부'],
  '전정대': ['전기공학부', '전자공학과', '정보통신공학부', '컴퓨터공학과', '소프트웨어학부', '지능로봇공학과', '반도체공학부'],
  '농생대': ['산림학과', '지역건설공학과', '바이오시스템공학과', '목재종이과학과', '농업경제학과', '식물자원학과', '환경생명화학과', '축산학과', '식품생명공학과', '특용식물학과', '원예과학과', '식물의학과'],
  '사범대': ['교육학과', '국어교육과', '영어교육과', '역사교육과', '지리교육과', '사회교육과', '윤리교육과', '물리교육과', '화학교육과', '생물교육과', '지구과학교육과', '수학교육과', '체육교육과'],
  '생과대': ['식품영양학과', '아동복지학과', '의류학과', '주거환경학과', '소비자학과'],
  '수의대': ['수의예과', '수의학과'],
  '약학대': ['약학과', '제약학과'],
  '의과대': ['의예과', '의학과'],
  '간호대': ['간호'],
  '창의융합':['자율전공학부', '바이오헬스학부'],
};
const Map<String, String> collegeProfileImages = {
  '인문대': 'assets/profile_france.png',
  '사과대': 'assets/profile_economy.png',
  '자과대': 'assets/profile_chemistry.png',
  '경영대': 'assets/profile_business.png',
  '공과대': 'assets/profile_engineer.png',
  '전정대': 'assets/profile_computer.png',
  '농생대': 'assets/profile_agriculture.png',
  '사범대': 'assets/profile_teacher.png',
  '생과대': 'assets/profile_nutrition.png',
  '수의대': 'assets/profile_vet.png',
  '약학대': 'assets/profile_pharmacy.png',
  '의과대': 'assets/profile_doctor.png',
  '간호대': 'assets/profile_nurse.png',
  '창의융합': 'assets/profile_agriculture.png',
};

class FilterSearchPage extends StatefulWidget {
  const FilterSearchPage({super.key});
  

  @override
  State<FilterSearchPage> createState() => _FilterSearchPageState();
}

class _FilterSearchPageState extends State<FilterSearchPage> {
  final List<String> filterOptions = ['기본정보', '생활패턴', '생활습관', '성격', '성향', '취미/기타'];
  late GroupButtonController _filterButtonController;
  Map<String, Set<String>> _selectedFilters = {};

  List<User> _roommates = [];

  

  void _updateGroupButtonSelection() {
    _filterButtonController.unselectAll();
    for (int i = 0; i < allCategories.length; i++) {
      String majorCategoryName = allCategories[i].categoryName;
      for (String key in _selectedFilters.keys) {
        if (key.startsWith(majorCategoryName)) {
          _filterButtonController.selectIndex(i);
          break;
        }
      }
    }
    print(_selectedFilters);
  }

  void _clearFilters() {
    setState(() {
      _filterButtonController.unselectAll();
      _selectedFilters.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _filterButtonController = GroupButtonController(selectedIndex: 0);
    _loadRoommates();
  }


List<User> _allRoommates = []; // 전체 사용자
List<User> _filteredRoommates = []; // 필터 적용 후

bool _isLoading = true;

Future<void> _loadRoommates() async {
  setState(() => _isLoading = true); // 로딩 시작

  final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;

  final snapshot = await FirebaseFirestore.instance
      .collection('checklists')
      .get(const GetOptions(source: Source.server));

  final futures = snapshot.docs.map((doc) async {
    if (doc.id == currentUserId) return null; // 본인 제외

    final checklistData = doc.data()['checklist'] as Map<String, dynamic>? ?? {};
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(doc.id).get();
    if (!userDoc.exists) return null;
    final userData = userDoc.data()!;

    final convertedChecklist = <String, Map<String, dynamic>>{};
    final categories = ['생활패턴', '생활습관', '성격', '성향', '취미/기타'];
    for (var category in categories) {
      final categoryData = checklistData[category];
      if (categoryData != null && categoryData is Map<String, dynamic>) {
        convertedChecklist[category] = {};
        categoryData.forEach((subKey, value) {
          if (value != null) {
            if (value is List) {
              convertedChecklist[category]![subKey] = List<String>.from(value);
            } else {
              convertedChecklist[category]![subKey] = value;
            }
          }
        });
      } else {
        convertedChecklist[category] = {};
      }
    }

    final dormitory = checklistData['취미/기타']?['생활관'] ?? '';
    final smokingStatus = checklistData['생활습관']?['흡연여부'] as String? ?? '비흡연';
    final isSmoking = smokingStatus == '흡연';


    // 사용자의 단과대 추론
    String? matchedCollege;
    collegeToDepartments.forEach((college, departments) {
      if (departments.contains(userData['department'])) {
        matchedCollege = college;
      }
    });

    // 단과대 이미지 적용 (없으면 기본 이미지)
    final profileImagePath = matchedCollege != null
        ? (collegeProfileImages[matchedCollege!] ?? 'assets/profile_man.png')
        : 'assets/profile_man.png';


    return User(
      id: doc.id,
      nickname: userData['nickname'] ?? '이름없음',
      dormitory: dormitory,
      department: userData['department'] ?? '',
      enrollYear: userData['enrollYear'] ?? '',
      birthYear: userData['birthYear'] ?? '',
      isSmoking: isSmoking,
      profilePath: profileImagePath,
      checklist: convertedChecklist,
    );
  }).toList();

  _allRoommates = (await Future.wait(futures)).whereType<User>().toList();
  _allRoommates.sort((a, b) => a.nickname.compareTo(b.nickname));

  _applyFilters(); // 필터 적용

  setState(() => _isLoading = false); // 로딩 끝

}

void _applyFilters() {
  if (_selectedFilters.isEmpty) {
    _filteredRoommates = List.from(_allRoommates);
  } else {
    _filteredRoommates = _allRoommates.where((user) {
      for (var key in _selectedFilters.keys) {
        final values = _selectedFilters[key]!;
        final parts = key.split(':'); 
        final category = parts[0];
        final subKey = parts[1];


        


        if (category == '기본정보') {
          if (subKey == '단과대') {
            // 사용자가 선택한 단과대 값들
            final selectedColleges = values;

            // user.department가 어느 단과대에 속하는지 확인
            bool matches = false;
            for (var college in selectedColleges) {
              final departments = collegeToDepartments[college] ?? [];
              if (departments.contains(user.department)) {
                matches = true;
                break;
              }
            }

            // 간호대 예외 처리: '간호'가 포함되어 있으면 매칭
            if (!matches && selectedColleges.contains('간호대') && user.department.contains('간호')) {
              matches = true;
            }
            
            if (!matches) return false;

          } else {
            // 기존 처리
            final userValue = {
              '생활관': user.dormitory,
              '학번': user.enrollYear,
              '생년': user.birthYear,
            }[subKey];

            if (userValue == null || !values.contains(userValue)) return false;
          }
        } else if (category == 'MBTI') {
          // UI에서 'EI' 선택 -> checklist key 'MBTI_EI'
          final checklistKey = 'MBTI_$subKey'; 
          final userValue = user.checklist['성격']?[checklistKey];
          if (userValue == null) return false;

          final userValueList = userValue is List ? userValue : [userValue.toString()];
          if (!values.any((v) => userValueList.contains(v))) return false;

        } else { 
          final userValue = user.checklist[category]?[subKey];
          if (userValue == null) return false;

          final userValueList = userValue is List ? userValue : [userValue.toString()];
          if (!values.any((v) => userValueList.contains(v))) return false;
        }
      }
      return true;
    }).toList();
  }
  setState(() {});
}










  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text('룸메이트 검색', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: Row(
                children: [
                  InkWell(
                    child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: group_button_outline, width: 1.0),
                        ),
                        child: Icon(Icons.refresh_rounded, color: black, size: 20)),
                    onTap: _clearFilters,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IgnorePointer(
                        ignoring: true,
                        child: GroupButton(
                          buttons: filterOptions,
                          controller: _filterButtonController,
                          isRadio: false,
                          onSelected: (val, i, selected) {},
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: grey_button_greyBG,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: grey_button_greyBG, width: 1.0),
                        ),
                        child: Icon(Icons.tune_rounded, color: black, size: 20)),
                    onTap: () async {
                      final result = await showBarModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) =>
                            FilterSelectModal(selectedFilters: _selectedFilters, onModalReset: _clearFilters),
                        isDismissible: false,
                        enableDrag: false,
                      );

                      if (result != null && result is Map<String, Set<String>>) {
                        setState(() {
                          _selectedFilters = result;
                        });
                        _updateGroupButtonSelection();
                        _applyFilters();
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: _isLoading
                ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
                : _filteredRoommates.isEmpty
                  ? Center(
                      child: Text("검색된 룸메이트가 없습니다.", style: mediumGrey14),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredRoommates.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: RoommateListItem(_filteredRoommates[index]),
                        onTap: () {
                          showBarModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) =>
                                RoommateDetailModal(isMine: false, user: _filteredRoommates[index]),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(height: 1, color: grey_seperating_line),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

Widget RoommateListItem(User user) {
  final isSmoking = user.isSmoking;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 51.w,
          height: 51.h,
          child: CircleAvatar(
            backgroundImage: AssetImage(user.profilePath),
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${user.nickname}', style: mediumBlack16),
                SizedBox(width: 6.w),
                if (isSmoking)
                  Image.asset('assets/smoke.png', width: 25.w, height: 25.h)
                else
                  SizedBox(width: 20.w, height: 20.h),
              ],
            ),
            SizedBox(height: 2.h),
            RichText(
              text: TextSpan(
                style: mediumGrey14,
                children: [
                  TextSpan(text: user.dormitory),
                  TextSpan(text: ' | ', style: TextStyle(letterSpacing: -1.0)), // 간격 줄임
                  TextSpan(text: '${user.enrollYear}학번'),
                  TextSpan(text: ' | ', style: TextStyle(letterSpacing: -1.0)),
                  TextSpan(text: '${user.birthYear}년생'),
                  TextSpan(text: ' | ', style: TextStyle(letterSpacing: -1.0)),
                  TextSpan(text: user.department),
                ],
              ),
            )
          ],
        ),
      ],
    ),
  );
}
