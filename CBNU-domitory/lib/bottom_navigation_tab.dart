import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

import 'package:untitled/home_page.dart';
import 'package:untitled/roommate/roommate_page.dart';
import 'package:untitled/community/community_page.dart';
import 'package:untitled/message/message_page.dart';


class BottomNavigationTab extends StatefulWidget {
  int navigatedIndex = 0;
  BottomNavigationTab({super.key, required this.navigatedIndex});

  @override
  State<BottomNavigationTab> createState() => _BottomNavigationTabState();
}

class _BottomNavigationTabState extends State<BottomNavigationTab> with TickerProviderStateMixin{
  late TabController _tabController;
  int _index = 0;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: _navItems.length, vsync: this);
    _tabController.addListener(tabListener);
    _tabController.index = widget.navigatedIndex;
  }

  @override
  void dispose(){
    _tabController.removeListener(tabListener);
    super.dispose();
  }

  void tabListener(){
    setState(() {
      _index = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          // 탭 본문 내용
          TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              HomePage(),
              RoommatePage(),
              CommunityPage(),
              MessagePage()
            ],
          ),
          // 하단에 내비게이션 바
          Align(
            alignment: Alignment.bottomCenter,
            child: PhysicalModel(
              color: white,
              elevation: 12,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
              clipBehavior: Clip.antiAlias,
              child: BottomNavigationBar(
                backgroundColor: white,
                selectedItemColor: black,
                unselectedItemColor: grey,
                selectedLabelStyle: mediumBlack12,
                unselectedLabelStyle: mediumGrey12,
                type: BottomNavigationBarType.fixed,
                currentIndex: _index,
                onTap: (index) {
                  setState(() {
                    _index = index;
                    _tabController.index = index;
                  });
                },
                items: _navItems.map((item) {
                  return BottomNavigationBarItem(
                    icon: Icon(item.inactiveIcon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem{
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavItem({required this.activeIcon, required this.inactiveIcon, required this.label});
}

const _navItems = [
  NavItem(
      activeIcon: Icons.home,
      inactiveIcon: Icons.home_outlined,
      label: '홈'
  ),
  NavItem(
      activeIcon: Icons.person_search,
      inactiveIcon: Icons.person_search_outlined,
      label: '룸메찾기'
  ),
  NavItem(
      activeIcon: Icons.comment,
      inactiveIcon: Icons.comment_outlined,
      label: '커뮤니티'
  ),
  NavItem(
      activeIcon: Icons.forum,
      inactiveIcon: Icons.forum_outlined,
      label: '쪽지'
  )
];