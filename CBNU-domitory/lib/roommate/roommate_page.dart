import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/roommate/roommate_detail_modal.dart';
import 'package:untitled/roommate/filter_search_page.dart';
import 'package:untitled/roommate/similarity_detail_page.dart';
import 'package:untitled/models/similarity.dart';

class RoommatePage extends StatefulWidget {
  const RoommatePage({super.key});

  @override
  State<RoommatePage> createState() => _RoommatePageState();
}

class _RoommatePageState extends State<RoommatePage> {
  bool _isMatched = false;
  bool _isAnswered = true;
  final List<User> _recommendedUsers = [];
  final List<Similarity> _recommendedUsersSimilarity = [];

  @override
  void initState(){
    super.initState();

    User item = User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전자정보대학', yearEnrolled: '25', isSmoking: true, checklist: checklistMap);
    for (int i = 0; i<4; i++){
      _recommendedUsers.add(item);
    }

    _recommendedUsersSimilarity.add(Similarity(similarity: 95, similar_factors: ['기상시간', '더위']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 92, similar_factors: ['흡연여부', '취침시간']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 90, similar_factors: ['추위', '더위']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 85, similar_factors: ['컴퓨터게임', '향 민감도']));
    _recommendedUsersSimilarity.add(Similarity(similarity: 80, similar_factors: ['기상시간', '취침시간']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: _isAnswered ? SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 24.h),
                  Text('AI 추천 룸메이트', style: boldBlack18),
                  SizedBox(height: 8.h),
                  CarouselSlider.builder(
                      itemCount: _recommendedUsers.length,
                      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => RecommendItem(user: _recommendedUsers[itemIndex], similarity: _recommendedUsersSimilarity[itemIndex].similarity, similar_factors: _recommendedUsersSimilarity[itemIndex].similar_factors),
                      options: CarouselOptions(
                          height: 0.43.sh,
                          viewportFraction: 0.7,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          enlargeFactor: 0.14
                      )
                  ),
                  SizedBox(height: 72.h),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('추천 룸메이트가\n마음에 들지 않는다면?', style: boldBlack16, textAlign: TextAlign.center),
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: 150.w,
                          child: ElevatedButton(
                            child: Text('직접 검색하기', style: mediumBlack14.copyWith(color: grey_button)),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: black,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 9.h, bottom: 9.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSearchPage()));
                            },
                          ),
                        ),
                        SizedBox(height: 4.h),
                        SizedBox(
                          width: 150.w,
                          child: ElevatedButton(
                            child: Text('체크리스트 수정하기', style: mediumBlack14),
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: grey_button_greyBG,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 9.h, bottom: 9.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AnswerChecklistPage()));
                            },
                          ),
                        )
                      ]
                  ),]
            ),
          ),
        ) :
            Center( // 체크리스트 응답 전
              child: Column(
                children: [
                  SizedBox(height: 0.27.sh),
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
            )
      ),
    );
  }
}


class RecommendItem extends StatelessWidget {
  final User user;
  final int similarity;
  final List<String> similar_factors;
  const RecommendItem({super.key, required this.user, required this.similarity, required this.similar_factors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 10.h),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: grey_seperating_line, width: 1.0)
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(user.profilePath),
                        )
                    ),
                    SizedBox(height: 8.h),
                    Text('${user.name}', style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, softWrap: false),
                    Text('${user.department} | ${user.yearEnrolled}학번', style: mediumGrey13, textAlign: TextAlign.center),
                    SizedBox(height: 12.h),
                    Container(
                        width: double.infinity,
                        height: 1.h,
                        color: grey_seperating_line
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('유사도', style: mediumGrey14),
                            Text('$similarity%', style: boldBlack20)
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SimilarityDetailPage()));
                              },
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade500,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            similar_factors[0],
                                            style: mediumWhite14.copyWith(fontSize: 13.sp)
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.chevron_right_rounded, color: white, size: 14)
                                      ]
                                  )
                              ),
                            ),
                            SizedBox(height: 2.h),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SimilarityDetailPage()));
                              },
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade300,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            similar_factors[1],
                                            style: mediumWhite14.copyWith(fontSize: 13.sp)
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.chevron_right_rounded, color: white, size: 14)
                                      ]
                                  )
                              ),
                            )
                          ]
                        )
                      ]
                    ),
                    SizedBox(height: 28.h),
                    ElevatedButton(
                      child: Text('상세정보 보기', style: mediumBlack14),
                      style: ElevatedButton.styleFrom(overlayColor: grey_8, backgroundColor: grey_button, padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), elevation: 0),
                      onPressed: () {
                        //쪽지 생성
                        showBarModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) => RoommateDetailModal(user: user),
                        );
                      },
                    )
                  ]),
          )
      ),
    );
  }
}

