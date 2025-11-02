import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/message/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class RoommateDetailModal extends StatefulWidget {
  User user;
  bool isMine;
  RoommateDetailModal({super.key, required this.user, required this.isMine});

  @override
  State<RoommateDetailModal> createState() => _RoommateDetailModalState();
}

class _RoommateDetailModalState extends State<RoommateDetailModal> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                      children: [Text('상세정보', style: boldBlack18)],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: grey_seperating_line, width: 1.0)),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(widget.user.profilePath),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.user.nickname,
                    style: mediumBlack16,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${widget.user.dormitory} | ${widget.user.enrollYear}학번 | ${widget.user.birthYear}년생 | ${widget.user.department}',
                    style: mediumGrey14,
                    textAlign: TextAlign.center,
                  ),
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
                    ],
                  ),
                  Container(height: 1, color: grey_seperating_line),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: ['생활패턴','생활습관','성격','성향','취미/기타'].map((category) {
                        final checklistItem = widget.user.checklist[category] ?? {};
                        return Padding(
                          padding: EdgeInsets.only(left: 50.w, top: 10.h),
                          child: GridTab(checklist_item: checklistItem, category: category),
                        );
                      }).toList(),
                    ),
                  ),
                ],
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
                  onPressed: () async{
                    if (widget.isMine) {
                      Navigator.pop(context);
                    } else {
                      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                      final otherUserId = widget.user.id; // User 모델에 uid 필드가 있어야 함
                      final chatRoomId = currentUserId.hashCode <= otherUserId.hashCode
                          ? '${currentUserId}_$otherUserId'
                          : '${otherUserId}_$currentUserId';

                      final currentUserDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserId)
                        .get();
                      final currentUserNickname = currentUserDoc.exists &&
                            currentUserDoc.data()!['nickname'] != null
                        ? currentUserDoc.data()!['nickname']
                        : '나';

                      final chatRoomRef =
                          FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
                      final chatRoomDoc = await chatRoomRef.get();

                      if (!chatRoomDoc.exists) {
                        await chatRoomRef.set({
                          'participants': [currentUserId, otherUserId],
                          'participants_info': {
                            currentUserId:
                                currentUserNickname,
                            otherUserId: widget.user.nickname,
                          },
                          'lastMessage': '',
                          'lastMessageTimestamp': FieldValue.serverTimestamp(),
                          'type': 'roommate',
                        });
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChattingPage(
                              chatRoomId: chatRoomId,
                              otherUserId: otherUserId,
                              otherUserNickname: widget.user.nickname,
                            ),
                          ),
                        );
                    }
                  }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: black,
                    overlayColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                    elevation: 0,
                  ),
                  child: Text(
                     widget.isMine ? '닫기' : '1:1 대화하기',
                     style: boldWhite15
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridTab extends StatelessWidget {
  final Map<String, dynamic> checklist_item;
  final String category;
  GridTab({super.key, required this.checklist_item, required this.category});

  final List<String> mbtiOrder = ['MBTI_EI', 'MBTI_NS', 'MBTI_TF', 'MBTI_PJ'];

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, dynamic>> items = checklist_item.entries.toList();

    // MBTI일 경우 순서 맞추기
    if (category == '성격') {
      items.sort((a, b) {
        int indexA = mbtiOrder.indexOf(a.key);
        int indexB = mbtiOrder.indexOf(b.key);
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        return indexA.compareTo(indexB);
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 36.h,
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 4.h,
          childAspectRatio: 0.5),
      itemBuilder: (context, index) {
        final item = items[index];
        String valueToDisplay;
        if (item.value is List<String>) {
          valueToDisplay = (item.value as List<String>).join(', ');
        } else {
          valueToDisplay = item.value.toString();
        }
        return Container(
          decoration: BoxDecoration(color: white),
          child: Row(
            children: [
              Text(item.key, style: mediumBlack14),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  valueToDisplay.replaceAll('[', '').replaceAll(']', ''),
                  style: mediumGrey14,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
