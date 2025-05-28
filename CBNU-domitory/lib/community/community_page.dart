import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/community/community_free_tab.dart';
import 'package:untitled/community/community_groupbuy_tab.dart';



class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  late TabController _tabController;

  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                    Tab(text: '자유게시판'),
                    Tab(text: '공동구매')
                  ]
              ),
            ),
            leading: SizedBox.shrink(),
            leadingWidth: 4.w,
            actions: [
              IconButton(icon: Icon(Icons.search, color: black, size: 24), onPressed: () { print("Search Button is Cliked!"); },)
            ]
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
              FreePostTab(),
              GroupBuyPostTab()
            ])
    );
  }
}