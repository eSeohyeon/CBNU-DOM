import 'package:flutter/material.dart';
import 'package:untitled/community/free/free_create_page.dart';
import 'package:untitled/community/groupbuy/group_buy_create_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/community/free/community_free_tab.dart';
import 'package:untitled/community/groupbuy/community_groupbuy_tab.dart';
import 'package:untitled/common/popup_dialog.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isStudent = true;

  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
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
                  labelStyle: boldBlack16,
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
            leadingWidth: 0,
            actions: [
              IconButton(icon: Icon(Icons.edit, color: _isStudent ? black : black40, size: 24), onPressed: () {
                if(_isStudent) {
                  if(_tabController.index==0){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateFreePost()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GroupBuyCreatePage()));
                  }
                } else {
                  showDialog(context: context, builder: (context) => PopupDialog(), barrierDismissible: false);
                }
              },),
              IconButton(icon: Icon(Icons.search, color: black, size: 24), onPressed: () { print("Search Button is Cliked!"); },),
            ],
          actionsPadding: EdgeInsets.only(right: 4.w),
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

