import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';


class RoommateDetailModal extends StatefulWidget {
  User user;
  bool isMine;
  RoommateDetailModal({super.key, required this.user, required this.isMine});

  @override
  State<RoommateDetailModal> createState() => _RoommateDetailModalState();
}

class _RoommateDetailModalState extends State<RoommateDetailModal> with TickerProviderStateMixin {
  late TabController _tabController;

  void initState(){
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
          height: 0.65.sh,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          ),
          child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 60.h, top: 16.h),
                  child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Row(
                              children: [
                                Text('상세정보', style: boldBlack18)
                              ]
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                            width: 70.w,
                            height: 70.h,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: grey_seperating_line, width: 1.0)
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(widget.user.profilePath),
                            )
                        ),
                        SizedBox(
                            height: 6.h
                        ),
                        Text(widget.user.name, style: mediumBlack16, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, softWrap: false),
                        SizedBox(height: 2.h),
                        Text('${checklistMap[4]['생활관']} | ${widget.user.yearEnrolled}학번 | ${widget.user.birthYear}년생 | ${widget.user.department}', style: mediumGrey14, textAlign: TextAlign.center),
                        SizedBox(height: 20.h),
                        TabBar(
                            controller: _tabController,
                            tabAlignment: TabAlignment.center,
                            labelStyle: mediumBlack16,
                            unselectedLabelColor: grey,
                            indicatorColor: black,
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            indicatorPadding: EdgeInsets.only(bottom: 0),
                            overlayColor: WidgetStatePropertyAll(Colors.transparent),
                            labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                            tabs: [
                              Tab(text: '생활패턴'),
                              Tab(text: '생활습관'),
                              Tab(text: '성격'),
                              Tab(text: '성향'),
                              Tab(text: '취미/기타'),
                            ]
                        ),
                        Container(height: 1, color: grey_seperating_line),
                        Expanded(
                            child: TabBarView(
                                controller: _tabController,
                                children: List.generate(checklistMap.length, (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(left: 50.w, top: 10.h),
                                    child: GridTab(checklist_item: checklistMap[index]),
                                  );
                                })
                            )
                        )
                      ]
                  ),
                ),
                Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 24.h,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                          onPressed: () {
                            if(widget.isMine) {
                              Navigator.pop(context); // 내 정보 보기일 떄
                            } else {
                               // 다른 사람의 정보 보기일 때 - 1:1 대화하기
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: black,
                              overlayColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                              elevation: 0
                          ),
                          child: widget.isMine ? Text('닫기', style: boldWhite15) : Text('1:1 대화하기', style: boldWhite15)
                      ),
                    )
                )
              ]
          )
      ),
    );
  }
}

class GridTab extends StatelessWidget {
  Map<String, String> checklist_item;
  GridTab({super.key, required this.checklist_item});

  @override
  Widget build(BuildContext context) {
    final items = checklist_item.entries.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 32.h,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 4.h,
          childAspectRatio: 0.5
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
            decoration: BoxDecoration(
                color: white
            ),
            child: Row(
                children: [
                  Text(item.key, style: mediumBlack14),
                  SizedBox(width: 10.w),
                  Text(item.value, style: mediumGrey14)
                ]
            )
        );
      },
    );
  }
}