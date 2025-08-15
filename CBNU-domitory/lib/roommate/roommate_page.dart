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

class RoommatePage extends StatefulWidget {
  const RoommatePage({super.key});

  @override
  State<RoommatePage> createState() => _RoommatePageState();
}

class _RoommatePageState extends State<RoommatePage> {
  bool _isMatched = false;
  bool _isCheckListAnswered = true;
  final List<User> _recommendedUsers = [];

  @override
  void initState(){
    super.initState();

    User item = User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전자정보대학', yearEnrolled: '25', isSmoking: true, checklist: checklistMap);
    for (int i = 0; i<4; i++){
      _recommendedUsers.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                Text('AI 추천 룸메이트', style: boldBlack18),
                SizedBox(height: 4.h),
                CarouselSlider.builder(
                    itemCount: _recommendedUsers.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) => RecommendItem(user: _recommendedUsers[itemIndex]),
                    options: CarouselOptions(
                        height: 0.37.sh,
                        viewportFraction: 0.65,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: true,
                        autoPlay: false,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        enlargeFactor: 0.17
                    )
                ),
                SizedBox(height: 56.h),
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
                ),
              ]
          ),
        ),
      ),
    );
  }
}


class RecommendItem extends StatelessWidget {
  final User user;
  const RecommendItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: BorderSide(color: grey_seperating_line, width: 1.0),),
          child: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 8.h, bottom: 8.h),
              child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: grey_seperating_line, width: 1.0)
                                ),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(user.profilePath),
                                )
                            ),
                            SizedBox(
                                height: 10.h
                            ),
                            Text('${user.name}', style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, softWrap: false),
                            Text('${user.department} | ${user.yearEnrolled}학번', style: mediumGrey14, textAlign: TextAlign.center),
                            SizedBox(
                                height: 20.h
                            ),
                            ElevatedButton(
                              child: Text('1:1 대화하기', style: mediumBlack14),
                              style: ElevatedButton.styleFrom(overlayColor: grey_8, backgroundColor: grey_button, padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 9.h, bottom: 9.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), elevation: 0),
                              onPressed: () {
                                //쪽지 생성
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SimilarityDetailPage()));
                              },
                            )
                          ]),
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                            icon: Icon(Icons.add, color: grey_outline_inputtext, size: 24),
                            onPressed: () {
                              print('Add Button is Clicked!');
                              showBarModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) => RoommateDetailModal(user: user),
                              );
                            }
                        )
                    )
                  ]
              )
          )
      ),
    );
  }
}

