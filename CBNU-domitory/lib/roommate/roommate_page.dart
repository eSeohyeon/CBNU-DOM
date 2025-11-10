import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:group_button/group_button.dart';
import 'package:untitled/profile/profile_page.dart';
import 'package:untitled/roommate/roommate_add_filter_modal.dart';

import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/roommate/roommate_detail_modal.dart';
import 'package:untitled/roommate/filter_search_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // 충돌 방지용 수정//
import 'package:untitled/models/user.dart' as model;                // 충돌 방지용 수정//

import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_page.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:untitled/models/similarity.dart';
import 'package:untitled/roommate/roommate_help.dart';
import 'package:untitled/roommate/similarity_detail_page.dart';
import 'package:untitled/roommate/rating_dialog.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class RoommatePage extends StatefulWidget {
  const RoommatePage({super.key});

  @override
  State<RoommatePage> createState() => _RoommatePageState();
}

class _RoommatePageState extends State<RoommatePage> {
  bool? _isStudent; // 재학생 인증
  bool _isMatched = false; // 매칭 완료 여부
  bool _isAnswered = false; // 체크리스트 작성
  bool _isNotEnough = false; // 생활관 인원수 부족
  bool _isFilterAdded = false; // 추가조건 설정
  bool _isRatingNeeded = true; // 별점 필요
  List<model.User> _recommendedUsers = [];
  List<Similarity> _recommendedUsersSimilarity = [];
  List<Map<String, String>> _addedFilters = [];
  model.User? _me;

  List<model.User> _allRecommendedUsers = []; // 추가
  List<Similarity> _allRecommendedUsersSimilarity = []; // 추가


  @override
  void initState(){
    super.initState();
    _loadMeAndRecommendations();
  }

  // ---------------- Firestore에서 내 정보 가져오기 ----------------
  Future<void> _loadMeAndRecommendations() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Firestore에서 현재 사용자 정보 가져오기
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final checklistDoc = await FirebaseFirestore.instance
        .collection('checklists')
        .doc(currentUser.uid)
        .get(const GetOptions(source: Source.server));

    final checklistData = checklistDoc.data()?['checklist'] as Map<String, dynamic>? ?? {};
    final checklistMap = (checklistData is Map<String, dynamic>) ? checklistData : <String, dynamic>{};

    final smokingStatus = checklistData['생활습관']?['흡연여부'] as String? ?? '비흡연';
    final isSmoking = smokingStatus == '흡연';

    _me = model.User(
      id: userDoc.id,
      profilePath: userDoc.data()?['profilePath'] ?? 'assets/profile_pharmacy.png',
      nickname: userDoc.data()?['nickname'] ?? '이름없음',
      department: userDoc.data()?['department'] ?? '',
      enrollYear: userDoc.data()?['enrollYear'] ?? '',
      birthYear: userDoc.data()?['birthYear'] ?? '', // 추가
      isSmoking: isSmoking,
      checklist: Map<String, dynamic>.from(checklistDoc.data()?['checklist'] ?? {}),
      dormitory: (checklistDoc.data()?['checklist']?['취미/기타']?['생활관']) ?? '',
    );


    _isStudent = userDoc.data()?['isVerified'] ?? false;
    // 체크리스트 작성 여부
    _isAnswered = _me!.checklist.isNotEmpty;


    // 생활관 인원수 체크 수의학과
    // 전체 체크리스트 가져오기
    final allChecklistDocs = await FirebaseFirestore.instance
        .collection('checklists')
        .get();

    // 같은 생활관 사용자만 필터링
    final dormUsers = allChecklistDocs.docs.where((doc) {
      final checklist = doc.data()['checklist'] as Map<String, dynamic>?;
      final dorm = checklist?['취미/기타']?['생활관'] as String?;
      return dorm == _me!.dormitory;
    }).toList();

    _isNotEnough = dormUsers.length < 5;


    // 추천 사용자 불러오기
    if (_isAnswered) {
      if (!_isNotEnough) {
        await _fetchRecommendedUsers();
      } else {
        _recommendedUsers.clear();
        _recommendedUsersSimilarity.clear();
      }
    }
    print(_me!.checklist);  // 체크리스트 데이터 확인
    print(_isAnswered);     // true/false 확인

    setState(() {});
  
  }
// ---------------- 추천 사용자 API 호출 ----------------
Future<void> _fetchRecommendedUsers() async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8001/recommend'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': _me!.id,
      'method': _addedFilters.isEmpty ? 'ai' : 'filter',
      'filters': _addedFilters.isEmpty ? null : _addedFilters,
    }),
  );

  print(jsonEncode({
    'user_id': _me!.id,
    'method': _addedFilters.isEmpty ? 'ai' : 'filter',
    'filters': _addedFilters.isEmpty ? null : _addedFilters,
  }));


  // 상태 코드 확인
  print('statusCode: ${response.statusCode}');

  // 400일 때 body 확인
  if (response.statusCode != 200) {
    try {
      final errorData = jsonDecode(response.body);
      print('Error Detail: ${errorData['detail']}');
    } catch (e) {
      print('Error parsing response body: ${response.body}');
    }
  } else {
    final data = jsonDecode(response.body);
    print('Success: ${data}');
  }



  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      _recommendedUsers.clear();
      _recommendedUsersSimilarity.clear();

      for (var rec in data['recommendations']) {
        final recMap = rec as Map<String, dynamic>;
        final candidateId = recMap['candidate_id'].toString().trim();

        // 본인 제외
        if (candidateId == _me!.id.toString().trim()) continue;

        final fullInfo = recMap['full_info'] as Map<String, dynamic>?;

        // fullInfo 자체가 없거나 checklist 없는 경우 제외
        if (fullInfo == null || !fullInfo.containsKey('checklist')) continue;

        final checklistData = fullInfo['checklist'];

        // 체크리스트 비어있는 사용자 제외
        if (checklistData == null || 
            (checklistData is List && checklistData.isEmpty) || 
            (checklistData is Map && checklistData.isEmpty)) continue;


        final smokingStatus = checklistData['생활습관']?['흡연여부'] as String? ?? '비흡연';
        final isSmoking = smokingStatus == '흡연';


        // 학과 → 단과대 매핑
        String getCollegeImage(String department) {
          String? matchedCollege;
          collegeToDepartments.forEach((college, departments) {
            if (departments.contains(department)) {
              matchedCollege = college;
            }
          });
          return matchedCollege != null
              ? (collegeProfileImages[matchedCollege!] ?? collegeProfileImages['default']!)
              : collegeProfileImages['default']!;
        }
        // ✅ 통과한 사용자만 추가
        _recommendedUsers.add(
          model.User(
            id: candidateId,
            profilePath: getCollegeImage(fullInfo['department'] ?? ''),
            nickname: fullInfo['nickname'] ?? 'Unknown',
            department: fullInfo['department'] ?? '',
            enrollYear: fullInfo['enrollYear'] ?? '',
            birthYear: fullInfo['birthYear'] ?? '',
            isSmoking: isSmoking,
            dormitory: (fullInfo['checklist']?['취미/기타']?['생활관']) ?? '',
            checklist: Map<String, dynamic>.from(checklistData),
          )
        );

        final similarityScoresDynamic = recMap['similarity_scores'];
        final similarityScores = similarityScoresDynamic != null
            ? Map<String, double>.from(similarityScoresDynamic.map((key, value) => MapEntry(key, (value as num).toDouble())))
            : {};

        
        final top_features = List<String>.from(recMap['top_features'] ?? []);
        final score = (recMap['score'] is num) ? (recMap['score'] as num).toDouble() : 0.0;
        final similarity_scores = (recMap['similarity_scores'] is Map<String, dynamic>)
            ? Map<String, double>.from((recMap['similarity_scores'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble())))
            : <String, double>{};


        // similarity도 안전하게 처리
        _recommendedUsersSimilarity.add(
          Similarity(
            score: score,
            top_features: top_features,
            similarity_scores: similarity_scores,
          ),
        );
      }

      _allRecommendedUsers = [..._recommendedUsers];
      _allRecommendedUsersSimilarity = [..._recommendedUsersSimilarity];


      print(data['recommendations']);  // 실제 추천 데이터 확인
      print(_recommendedUsers.length); // 몇 명 추천되는지 확인

      for (var u in _recommendedUsers) {
        print('추천 사용자: ${u.nickname}, ${u.department}, ${u.enrollYear}');
      }
      setState(() {});

    }
  }


  
  


  setState(() {});
}




bool _checkFilter(Map<String, dynamic> checklist, String key, String value) {
  for (final entry in checklist.entries) {
    final entryKey = entry.key.toString().trim();
    final entryValue = entry.value;

    // 🔍 현재 탐색 중인 키 로그
    print("탐색 중 key: '$entryKey' → value: '$entryValue' (${entryValue.runtimeType})");

    // 값이 Map이면 재귀 탐색
    if (entryValue is Map<String, dynamic>) {
      if (_checkFilter(entryValue, key, value)) return true;
    } 
    // 값이 List이면 요소들 중에 일치하는 값 있는지 검사
    else if (entryValue is List) {
      for (var item in entryValue) {
        final itemStr = item.toString().trim();
        if (entryKey == key && itemStr == value.trim()) {
          print("리스트 매칭 성공: $entryKey = $itemStr");
          return true;
        }
      }
    } 
    // 값이 문자열이면 직접 비교
    else {
      if (entryKey == key && entryValue.toString().trim() == value.trim()) {
        print("문자열 매칭 성공: $entryKey = ${entryValue.toString()}");
        return true;
      }
    }
  }
  return false;
}





void _applyFilters(List<Map<String, String>> filters) {

  


  _addedFilters = filters;
  _isFilterAdded = filters.isNotEmpty;

  print("필터 데이터 구조 확인: $_addedFilters");
  print("필터 데이터 구조 확인: $_addedFilters");
  print("필터 데이터 구조 확인: $_addedFilters");
  print("필터 데이터 구조 확인: $_addedFilters");

  final filteredUsers = <model.User>[];
  final filteredSimilarities = <Similarity>[];

  for (int i = 0; i < _allRecommendedUsers.length; i++) {
    final user = _allRecommendedUsers[i];
    final similarity = _allRecommendedUsersSimilarity[i];

    if (user.id == _me!.id || user.checklist.isEmpty) continue;

    bool match = true;
    for (var filter in _addedFilters) {
      final key = filter.keys.first;
      final value = filter.values.first;

      final check = _checkFilter(user.checklist, key, value);
      print("유저 ${user.nickname} 필터 '$key:$value' 결과 → $check");
      if (!_checkFilter(user.checklist, key, value)) {
        match = false;
        break;
      }
    }

    if (match) {
      filteredUsers.add(user);
      filteredSimilarities.add(similarity);
    }
  }

  setState(() {
    _recommendedUsers = filteredUsers;
    _recommendedUsersSimilarity = filteredSimilarities;
  });

  
}




  //////////////////////////////////////////////////////////////////////////////
  // UI 관련 함수
  //////////////////////////////////////////////////////////////////////////////
  void _removeFilter(Map<String, String> filterToRemove) {
    setState(() {
      _addedFilters.removeWhere((filter)=>
          filter.keys.first == filterToRemove.keys.first && filter.values.first == filterToRemove.values.first);
      _isFilterAdded = _addedFilters.isNotEmpty;
      // 추천목록에 적용된 필터 해제
    });
  }

  void _clearAllFilters() async {
    setState(() {
      _addedFilters.clear();
      _isFilterAdded = false;
      _recommendedUsers = [..._allRecommendedUsers];
      _recommendedUsersSimilarity = [..._allRecommendedUsersSimilarity];
      // 추천 목록에 적용된 필터 완전해제
    });

    await _fetchRecommendedUsers();

  }

  Widget _setFilterAgain() { // 조건 설정하고 조건에 맞는 사용자 없을 때 띄우는 팝업
    return AlertDialog(
      backgroundColor: white,
      content: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 조건에 맞는 사용자가 없습니다.', style: boldBlack16),
                SizedBox(height: 4.h),
                Text('조건을 재설정 하시겠습니까?', style: mediumGrey13, textAlign: TextAlign.center),
                SizedBox(height: 20.h),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                              /*final result = await showBarModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) => AddFilterModal(addedFilters: _addedFilters),
                                  isDismissible: false,
                                  enableDrag: false
                              );
                              if(result != null) {
                                setState(() {
                                  _addedFilters = result;
                                  _isFilterAdded = _addedFilters.isNotEmpty;
                                  print(result);
                                });
                              }*/
                            },
                            child: Text('조건 재설정하기', style: mediumWhite14),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: black,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                            )
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text('닫기', style: mediumBlack14),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: grey_button,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                            )
                        ),
                      )
                    ]
                )
              ]
          )
      ),
    );
  }

  Widget _buildEmptyFilterContainer() {
    return InkWell(
      onTap: () async {
        final result = await showBarModalBottomSheet(
            context: context,
            builder: (BuildContext context) => AddFilterModal(addedFilters: _addedFilters),
            isDismissible: false,
            enableDrag: false
        );
        if(result != null) {
          _applyFilters(result); // 추가
        }
      },
      child: Container(
        width: 114.w,
        height: 34.h,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: grey_outline_inputtext, width: 1.0),
        ),
        child: Icon(Icons.add_rounded, color: grey_outline_inputtext, size: 20)
      )
    );
  }

  Widget _buildFilterItem(Map<String, String> filter) {
    final key = filter.keys.first;
    final value = filter.values.first;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  '${key} : ${value}',
                  style: mediumWhite14
              ),
              SizedBox(width: 4.w),
              InkWell(
                  child: Icon(Icons.close_rounded, color: white, size: 16),
                  onTap: () {
                    setState(() {
                      _removeFilter(filter);
                    });
                  }
              )
            ]
        )
    );
  }

  // 재학생 인증 안 됐을 때 화면
  Widget _buildNonStudentScreen() {
    return Center(
        child: Column(
            children: [
              SizedBox(height: 200.h),
              Text('재학생 인증 미완료', style: boldBlack18),
              SizedBox(height: 6.h),
              Image.asset('assets/not_student.png'),
              SizedBox(height: 10.h),
              Text('룸메추천 기능을 이용하려면 재학생 인증이 필요해요', style: mediumBlack16, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2.h),
              Text('합격증 또는 학생증으로 인증할 수 있어요!', style: mediumGrey14),
              SizedBox(height: 20.h),
              SizedBox(
                child: ElevatedButton(
                  child: Text('재학생 인증하기', style: mediumBlack16.copyWith(color: grey_button)),
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: black,
                      overlayColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
              ),
            ]
        )
    );
  }

  // 체크리스트 작성 안 했을 때 화면
  Widget _buildNoChecklistScreen() {
    return Center( // 체크리스트 응답 전
        child: Column(
            children: [
              SizedBox(height: 200.h),
              Text('AI 추천 룸메이트', style: boldBlack18),
              SizedBox(height: 6.h),
              Image.asset('assets/no_checklist.png'),
              SizedBox(height: 10.h),
              Text('아직 체크리스트를 작성하지 않으셨나요?', style: boldBlack16),
              SizedBox(height: 2.h),
              Text('체크리스트 기반 AI 룸메이트 추천!', style: mediumBlack14),
              SizedBox(height: 20.h),
              SizedBox(
                child: ElevatedButton(
                  child: Text('체크리스트 작성하기', style: mediumBlack16.copyWith(color: grey_button)),
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: black,
                      overlayColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnswerChecklistPage())
                    );

                    if(result == true) {
                      // Firestore에서 최신 체크리스트 가져오기
                      await _loadMeAndRecommendations();
                      setState(() {
                        _isAnswered = _me!.checklist.isNotEmpty;
                      });
                    }
                  }

                ),
              ),
            ]
        )
    );
  }

  // 인원수 부족할 때 슬라이더
  Widget _buildNoEnoughCarousel() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: white
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ 중앙 정렬
            children: [
              Image.asset('assets/roommate_not_enough.png', width: 150.w, height: 150.h),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('룸메이트 추천 불가', style: boldBlack16, textAlign: TextAlign.center),
                    SizedBox(height: 6.h),
                    Text('현재 같은 생활관에 등록된 학생 수가 적어서 추천이 어려워요', style: mediumBlack14, softWrap: true),
                    SizedBox(height: 1.h),
                    Text('직접 검색을 통해 더 빠르게 룸메이트를 만날 수 있습니다', style: mediumGrey14, softWrap: true),
                    SizedBox(height: 16.h),
                    Center(
                      child: ElevatedButton(
                      child: Text('직접 검색하기', style: mediumBlack14),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: grey_button_greyBG,
                          overlayColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0),),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSearchPage()));
                      },
                    )
                    )
                  ]
              ),
            ]
        )
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////
  // UI
  /////////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    if (_isStudent == null) {
      return Center(child: CircularProgressIndicator()); // 데이터 로딩 중
    }
    return Scaffold(
        backgroundColor: background,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    child: !_isStudent! ? _buildNonStudentScreen() : !_isAnswered ? _buildNoChecklistScreen() : _isNotEnough ? _buildNoEnoughCarousel() :
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 24.h),
                          if(_isRatingNeeded)...[
                            InkWell(
                              onTap: () {
                                showDialog(context: context, builder: (context) => RatingDialog());
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.star_rounded, size: 24, color: Colors.amber),
                                          SizedBox(width: 6.w),
                                          Text('AI 룸메이트 추천 별점주기', style: mediumBlack14),
                                        ],
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: grey, size: 24)
                                    ]
                                ),
                              )
                            ),
                            SizedBox(height: 24.h)
                          ],
                          // AI 추천 룸메이트 목록
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('AI 추천 룸메이트', style: boldBlack18),
                                Row(
                                    children: [
                                      Text('추가조건', style: mediumGrey14),
                                      SizedBox(width: 6.w),
                                      Text(_isFilterAdded ? 'ON' : 'OFF', style: _isFilterAdded ? mediumBlack14 : mediumGrey14)
                                    ]
                                )
                              ]
                          ),
                          SizedBox(height: 10.h),
                          _isNotEnough ? _buildNoEnoughCarousel() : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CarouselSlider.builder(
                                    itemCount: _recommendedUsers.length,
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => RecommendItem(
                                      user: _recommendedUsers[itemIndex],
                                      score: _recommendedUsersSimilarity[itemIndex].score,
                                      top_features: _recommendedUsersSimilarity[itemIndex].top_features,
                                      similarity_scores: _recommendedUsersSimilarity[itemIndex].similarity_scores,
                                    ),
                                    options: CarouselOptions(
                                      height: 200.h,
                                      viewportFraction: 0.9,
                                      initialPage: 0,
                                      enableInfiniteScroll: false,
                                      reverse: false,
                                      autoPlay: false,
                                      enlargeCenterPage: false,
                                      scrollDirection: Axis.horizontal,
                                    )
                                ),
                                SizedBox(height: 24.h),
                                Text('추가조건 설정', style: mediumBlack16),
                                SizedBox(height: 1.h),
                                Text('룸메에게 꼭 바라는 점을 최대 2개까지 선택할 수 있어요!', style: mediumGrey13),
                                SizedBox(height: 8.h),
                                Row(
                                    children: [
                                      if(_addedFilters.isEmpty) ...[ // 추가조건 없을 때
                                        _buildEmptyFilterContainer(),
                                        SizedBox(width: 6.w),
                                        _buildEmptyFilterContainer()
                                      ] else if (_addedFilters.length ==1) ...[ // 추가조건 1개
                                        _buildFilterItem(_addedFilters[0]),
                                        SizedBox(width: 6.w),
                                        _buildEmptyFilterContainer()
                                      ] else if (_addedFilters.length == 2) ...[ // 추가조건 2개
                                        _buildFilterItem(_addedFilters[0]),
                                        SizedBox(width: 6.w),
                                        _buildFilterItem(_addedFilters[1])
                                      ],
                                      SizedBox(width: 10.w),
                                      InkWell(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: Container(
                                              padding: EdgeInsets.all(6.0),
                                              decoration: BoxDecoration(color: grey_button_greyBG, borderRadius: BorderRadius.circular(10.0)),
                                              child: Icon(Icons.refresh_rounded, color: black, size: 22)
                                          ),
                                          onTap: () {
                                            _clearAllFilters();
                                          }
                                      ),
                                    ]
                                )
                              ]
                          ),
                          // 직접 검색하러 가기
                          SizedBox(height: 48.h),
                          InkWell(
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSearchPage()));
                            },
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0)),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('마음에 드는 룸메이트가 없나요?', style: boldBlack16),
                                            SizedBox(height: 1.h),
                                            Text('직접 검색하러 가기 ->', style: mediumGrey14)
                                          ]
                                      ),
                                      Image.asset('assets/not_student.png', width: 60.w, height: 60.h)
                                    ]
                                )
                            ),
                          ),
                          // 추천방식 설명
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    if (_me == null) return; // _me가 null이면 아무 동작 안 함
                                    showBarModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) => RoommateDetailModal(user: _me!, isMine: true),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset('assets/show_mine.png', width: 18.w, height: 23.h),
                                          SizedBox(width: 8.w),
                                          Text('내 체크리스트 보기', style: mediumBlack14)
                                        ]
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: grey, size: 20)
                                    ]
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AnswerChecklistPage()));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                          children: [
                                            Image.asset('assets/edit_checklist.png', width: 20.w, height: 20.h),
                                            SizedBox(width: 6.w),
                                            Text('체크리스트 수정하기', style: mediumBlack14)
                                          ]
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: grey, size: 20)
                                    ]
                                  ),
                                )
                              ]
                            )
                          ),
                          SizedBox(height: 32.h),
                          TextButton(
                              onPressed: () {
                                // 추천 방식 설명창
                                showDialog(context: context, builder: (context) => RoommateHelpDialog());
                              },
                              child: Text('추천 방식이 궁금하신가요?', style: mediumGrey13)
                          ),
                          SizedBox(height: 64.h)
                        ]
                    )
                )
            )
        )
    );
  }
}

// 추천 룸메이트 목록 아이템
class RecommendItem extends StatelessWidget {
  final model.User user;
  final double score;
  final List<String> top_features;
  final Map<String, dynamic>? similarity_scores;

  const RecommendItem(
      {super.key, required this.user, required this.score, required this.top_features, this.similarity_scores});

  Map<String, dynamic> _buildRecommendationData() {
    Map<String, double> scoreMap = {
      for (var factor in top_features) factor: score / 100
    };

    return {
      "top_features": top_features,
      "similarity_scores": similarity_scores ?? {},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 6.w),
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: white
            ),
            child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      showBarModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => RoommateDetailModal(user: user, isMine: false),
                      );
                    },
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25.w,
                                    backgroundImage: AssetImage(user.profilePath),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.nickname, style: mediumBlack14),
                                        Text('${user.department} | ${user.enrollYear}학번',
                                            style: mediumGrey13)
                                      ]
                                  ),
                                ]
                            ),
                            Icon(Icons.chevron_right_rounded, color: grey, size: 20)
                          ]
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('추천점수', style: mediumGrey14),
                        SizedBox(width: 8.w),
                        Text('$score점', style: boldBlack20)
                      ]
                  ),
                  SizedBox(height: 6.h),
                  GroupButton(
                    buttons: top_features,
                    buttonBuilder: (selected, value, context) {
                      return similarityGroupButton(value);
                    },
                    onSelected: (val, i, selected) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SimilarityDetailPage(recommendationData: _buildRecommendationData(),),),);
                    },
                    options: GroupButtonOptions(spacing: 4,
                        mainGroupAlignment: MainGroupAlignment.start),
                  ),
                ]
            )
        )
    );
  }
}

class SetFilterAgain extends StatelessWidget {
  const SetFilterAgain({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      content: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 조건에 맞는 사용자가 없습니다.', style: boldBlack16),
                SizedBox(height: 4.h),
                Text('조건을 재설정 하시겠습니까?', style: mediumGrey13, textAlign: TextAlign.center),
                SizedBox(height: 20.h),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {

                            },
                            child: Text('조건 재설정하기', style: mediumWhite14),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: black,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                            )
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('닫기', style: mediumBlack14),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: grey_button,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                            )
                        ),
                      )
                    ]
                )
              ]
          )
      ),
    );
  }
}




