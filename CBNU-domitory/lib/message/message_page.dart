import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/profile/profile_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:untitled/message/chat_list_item.dart';
import 'package:untitled/models/chat_message.dart';
import 'package:untitled/message/chatting_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isStudent = true;
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'];
      if (mounted) {
        setState(() {
          _isStudent = (role == '재학생');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("Error checking user role: $e");
    }
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: white, body: Center(child: CircularProgressIndicator()));
    }

    return _isStudent ? Scaffold(
        backgroundColor: white,
        appBar: AppBar(
            backgroundColor: white,
            shape: Border(bottom: BorderSide(color: grey_seperating_line, width: 1.0)),
            title: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: TabBar(
                  controller: _tabController,
                  tabAlignment: TabAlignment.start,
                  labelStyle: boldBlack16,
                  unselectedLabelColor: grey,
                  indicatorColor: black,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  indicatorPadding: const EdgeInsets.only(bottom: -3),
                  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                  tabs: const [
                    Tab(text: '자유게시판'),
                    Tab(text: '룸메이트'),
                    Tab(text: '공동구매')
                  ]
              ),
            ),
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            actions: [
              IconButton(icon: const Icon(Icons.more_vert_rounded, color: black, size: 24), onPressed: () { print("Search Button is Cliked!"); },)
            ]
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
              MessageListTab(chatType: 'free_board'),
              MessageListTab(chatType: 'roommate'), //룸메이트 쪽지 타입 정의 필요
              MessageListTab(chatType: 'group_buy'),
            ])
    ) :
    Scaffold(
        backgroundColor: background,
        body: SafeArea(
            bottom: false,
            child: Center(
                child: Column(
                    children: [
                      SizedBox(height: 200.h),
                      Text('재학생 인증 미완료', style: boldBlack18),
                      SizedBox(height: 6.h),
                      Image.asset('assets/not_student.png'),
                      SizedBox(height: 10.h),
                      Text('쪽지 기능을 이용하려면 재학생 인증이 필요해요', style: mediumBlack16),
                      SizedBox(height: 2.h),
                      Text('합격증 또는 학생증으로 인증할 수 있어요!', style: mediumGrey14),
                      SizedBox(height: 20.h),
                      SizedBox(
                        child: ElevatedButton(
                          child: Text('재학생 인증하기', style: mediumBlack16.copyWith(color: white)),
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: black,
                              overlayColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                          },
                        ),
                      ),
                    ]
                )
            )
        )
    );
  }
}

class MessageListTab extends StatelessWidget {
  final String chatType;
  const MessageListTab({super.key, required this.chatType});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      return const Center(child: Text("로그인이 필요합니다."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserUid)
          .where('type', isEqualTo: chatType) // 타입별로 필터링
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("오류가 발생했습니다."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("대화 내역이 없습니다."));
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.separated(
            itemCount: chatDocs.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final doc = chatDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final participants = List<String>.from(data['participants'] ?? []);

              String chatRoomName;
              String otherUserId = '';
              String? imageUrl;

              if (chatType == 'group_buy') {
                chatRoomName = data['groupTitle'] ?? '공동구매 채팅';
                imageUrl = data['groupImageUrl'] as String?;
              } else {
                otherUserId = participants.firstWhere((id) => id != currentUserUid, orElse: () => '');
                final participantsInfo = data['participants_info'] as Map<String, dynamic>? ?? {};
                chatRoomName = participantsInfo[otherUserId] ?? '상대방';
                // 해야할일 : 1:1 채팅방의 경우 상대방 프로필 이미지를 가져오는 로직을 추가
                imageUrl = null;
              }

              final chatItem = ChatItem(
                chatId: doc.id,
                senderId: chatRoomName, // 채팅방 이름으로 설정
                latestContent: data['lastMessage'] ?? '',
                latestTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),imageUrl: imageUrl,
              );
              return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChattingPage(
                      chatRoomId: doc.id,
                      otherUserId: otherUserId,
                      otherUserNickname: chatRoomName,
                    )));
                  },
                  child: ChatListItem(chatItem: chatItem));},
            separatorBuilder: (context, index) {
              return Container(
                height: 1.0,
                color: grey_seperating_line,
              );}
        );
      },
    );
  }
}
