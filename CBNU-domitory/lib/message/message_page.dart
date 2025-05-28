import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with TickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
        appBar: AppBar(
            backgroundColor: white,
            shape: Border(bottom: BorderSide(color: grey_seperating_line, width: 1.0)),
            title: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: TabBar(
                  controller: _tabController,
                  tabAlignment: TabAlignment.start,
                  labelStyle: boldBlack18,
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
            actions: [
              IconButton(icon: Icon(Icons.more_vert_rounded, color: black, size: 24), onPressed: () { print("Search Button is Cliked!"); },)
            ]
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
              Text('일반'),
              Text('룸메이트'),
              Text('공동구매')
            ])
    );
  }
}