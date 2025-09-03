import 'package:flutter/material.dart';
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
  final bool _isStudent = true;

  void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  indicatorPadding: EdgeInsets.only(bottom: -3),
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                  tabs: [
                    Tab(text: '일반'),
                    Tab(text: '룸메이트'),
                    Tab(text: '공동구매')
                  ]
              ),
            ),
            leading: SizedBox.shrink(),
            leadingWidth: 0,
            actions: [
              IconButton(icon: Icon(Icons.more_vert_rounded, color: black, size: 24), onPressed: () { print("Search Button is Cliked!"); },)
            ]
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
              MessageListTab(tabIndex: 0),
              MessageListTab(tabIndex: 1),
              MessageListTab(tabIndex: 2)
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
           )
       )
     );
  }
}

class MessageListTab extends StatefulWidget {
  final int tabIndex;
  const MessageListTab({super.key, required this.tabIndex});

  @override
  State<MessageListTab> createState() => _MessageListTabState();
}

class _MessageListTabState extends State<MessageListTab> {

  // 테스틔용
  final List<ChatItem> _freeChatList = [
    ChatItem(chatId: 'F_101', senderId: '초가스', latestContent: '안녕', latestTimestamp: DateTime.now()),
    ChatItem(chatId: 'F_102', senderId: '미천한도둑', latestContent: '삥뿅뺭뿅', latestTimestamp: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: ListView.separated(
          itemCount: _freeChatList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final chatItem = _freeChatList[index];
            return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChattingPage()));
                },
                child: ChatListItem(chatItem: chatItem));},
          separatorBuilder: (context, index) {
            return Container(
              height: 1.0,
              color: grey_seperating_line,
            );}
        ),
      )
    );
  }
}
