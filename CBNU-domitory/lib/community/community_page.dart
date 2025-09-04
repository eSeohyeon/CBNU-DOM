import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/popup_dialog.dart';
import 'package:untitled/community/free/free_create_page.dart';
import 'package:untitled/community/groupbuy/group_buy_create_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/community/free/community_free_tab.dart';
import 'package:untitled/community/groupbuy/community_groupbuy_tab.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  // --- 글쓰기 버튼 클릭 시 사용자 역할 확인 ---
  Future<void> _handleCreatePost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글을 작성하려면 로그인이 필요합니다.')),
      );
      return;
    }

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'];

      Navigator.of(context).pop(); // 로딩 제거

      if (role == '재학생') {
        if (_tabController.index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateFreePost()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupBuyCreatePage()));
        }
      } else {
        // 재학생이 아닐 경우 팝업 표시
        showDialog(
          context: context,
          builder: (context) => const PopupDialog(),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 인디케이터 제거
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 확인하는 중 오류가 발생했습니다: $e')),
      );
    }
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
                indicatorPadding: const EdgeInsets.only(bottom: -3),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                tabs: const [
                  Tab(text: '자유게시판'),
                  Tab(text: '공동구매')
                ]
            ),
          ),
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          actions: [
            IconButton(icon: const Icon(Icons.edit, color: black, size: 24), onPressed: _handleCreatePost),
            IconButton(icon: const Icon(Icons.search, color: black, size: 24), onPressed: () { print("Search Button is Cliked!"); },),
          ],
          actionsPadding: EdgeInsets.only(right: 4.w),
        ),
        body: TabBarView(
            controller: _tabController,
            children: const [
              FreePostTab(),
              GroupBuyPostTab()
            ])
    );
  }
}
