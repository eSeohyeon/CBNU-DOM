import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:group_button/group_button.dart';
import 'package:untitled/roommate/roommate_add_filter_modal.dart';

import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/roommate/roommate_detail_modal.dart';
import 'package:untitled/roommate/filter_search_page.dart';
import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_page.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:untitled/models/similarity.dart';
import 'package:untitled/roommate/roommate_help.dart';
import 'package:untitled/roommate/similarity_detail_page.dart';
import 'package:untitled/roommate/rating_dialog.dart';

class RoommatePage extends StatefulWidget {
  const RoommatePage({super.key});

  @override
  State<RoommatePage> createState() => _RoommatePageState();
}

class _RoommatePageState extends State<RoommatePage> {
  final bool _isStudent = true; // 재학생 인증
  bool _isMatched = false; // 매칭 완료 여부
  bool _isAnswered = true; // 체크리스트 작성
  bool _isNotEnough = false; // 생활관 인원수 부족
  bool _isFilterAdded = false; // 추가조건 설정
  List<User> _recommendedUsers = [];
  List<Similarity> _recommendedUsersSimilarity = [];
  List<Map<String, String>> _addedFilters = [];
  User? _me;

  @override
  void initState(){
    super.initState();

    _me = User(profilePath: 'assets/profile1.png', name: '까르보나라', department: '자연과학대학', yearEnrolled: '23', isSmoking: true, checklist: checklistMap);
    User item = User(profilePath: 'assets/profile7.png', name: '두부두부두루치기', department: '전자정보대학', yearEnrolled: '25', isSmoking: true, checklist: checklistMap);
    for (int i = 0; i<4; i++){
      _recommendedUsers.add(item);
    }
    _recommendedUsersSimilarity.add(Similarity(similarity: 97.8, similar_factors: ['기상시간', '취침시간', '더위', '잠버릇', '친구초대']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 80.1, similar_factors: ['기상시간', '실내취식', '추위', '잠버릇', '친구초대']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 77.3, similar_factors: ['기상시간', '취침시간', '더위', '잠버릇', '친구초대']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 64.5, similar_factors: ['기상시간', '취침시간', '더위', '잠버릇', '친구초대']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 58.1, similar_factors: ['기상시간', '취침시간', '더위', '잠버릇', '친구초대']));
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

  void _clearAllFilters() {
    setState(() {
      _addedFilters.clear();
      _isFilterAdded = false;
      // 추천 목록에 적용된 필터 완전해제
    });
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
          setState(() {
            _addedFilters = result;
            _isFilterAdded = _addedFilters.isNotEmpty;
            print(result);
          });
        }
      },
      child: Container(
        width: 110.w,
        height: 30.h,
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
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
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
                    // 인증하러 가기~
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AnswerChecklistPage()));
                  },
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
            children: [
              Image.asset('assets/roommate_not_enough.png', width: 150.w, height: 150.h),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('룸메이트 추천 불가', style: boldBlack16),
                    SizedBox(height: 6.h),
                    Text('현재 같은 생활관에 등록된 학생 수가 적어서 추천이 어려워요', style: mediumBlack14, softWrap: true,),
                    SizedBox(height: 1.h),
                    Text('직접 검색을 통해 더 빠르게 룸메이트를 만날 수 있습니다', style: mediumGrey14, softWrap: true,),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      child: Text('직접 검색하기', style: mediumBlack14),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: grey_button_greyBG,
                          overlayColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSearchPage()));
                      },
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
    return Scaffold(
        backgroundColor: background,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    child: !_isStudent ? _buildNonStudentScreen() : !_isAnswered ? _buildNoChecklistScreen() :
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 24.h),
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
                                      similarity: _recommendedUsersSimilarity[itemIndex].similarity,
                                      similar_factors: _recommendedUsersSimilarity[itemIndex].similar_factors,
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
                                              child: Icon(Icons.refresh_rounded, color: black, size: 20)
                                          ),
                                          onTap: () {
                                            showDialog(context: context, builder: (context) => RatingDialog(), barrierDismissible: false); // 임시 테스트용
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
                          SizedBox(height: 44.h)
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
  final User user;
  final double similarity;
  final List<String> similar_factors;

  const RecommendItem(
      {super.key, required this.user, required this.similarity, required this.similar_factors});

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
                                  SizedBox(
                                    width: 50.w,
                                    height: 50.h,
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage(user.profilePath),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name, style: mediumBlack14),
                                        Text('${user.department} | ${user.yearEnrolled}학번',
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
                        Text('$similarity점', style: boldBlack20)
                      ]
                  ),
                  SizedBox(height: 6.h),
                  GroupButton(
                    buttons: similar_factors,
                    buttonBuilder: (selected, value, context) {
                      return similarityGroupButton(value);
                    },
                    onSelected: (val, i, selected) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SimilarityDetailPage()));
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



