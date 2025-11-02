import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_page.dart';
import 'package:untitled/roommate/filter_select_modal.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/roommate/roommate_detail_modal.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:group_button/group_button.dart';
import 'package:untitled/models/group_category.dart';

class FilterSearchPage extends StatefulWidget {
  const FilterSearchPage({super.key});

  @override
  State<FilterSearchPage> createState() => _FilterSearchPageState();
}

class _FilterSearchPageState extends State<FilterSearchPage> {
  final List<String> filterOptions = ['기본정보', '생활패턴', '생활습관', '성격', '성향', '기타'];
  late GroupButtonController  _filterButtonController;
  Map<String, Set<String>> _selectedFilters = {};

  List<User> _roommates = [];

  void _updateGroupButtonSelection() {
    _filterButtonController.unselectAll();
    for(int i = 0; i< allCategories.length; i++) {
      String majorCategoryName = allCategories[i].categoryName;
      for(String key in _selectedFilters.keys) {
        if(key.startsWith(majorCategoryName)) {
          _filterButtonController.selectIndex(i);
          break;
        }
      }
    }
    print(_selectedFilters);
  }

  void _clearFilters() {
    setState(() {
      _filterButtonController.unselectAll();
      _selectedFilters.clear();
    });
  }

  @override
  void initState(){
    super.initState();
    _filterButtonController = GroupButtonController(
      selectedIndex: 0,
    );

    for(int i = 0; i<40; i++){ // 테스트용 더미데이터
      _roommates.add(User(
        name: '키위',
        dormitory: '예지관',
        department: '전정대',
        yearEnrolled: '25',
        birthYear: '07',
        profilePath: 'assets/profile_economy.png',
        isSmoking: true,
        checklist: checklistMap
      ));
      _roommates.add(User(
          name: '바나나',
          dormitory: '신민관',
          department: '인문대',
          yearEnrolled: '25',
          birthYear: '07',
          profilePath: 'assets/profile_business.png',
          isSmoking: true,
          checklist: checklistMap
      ));
      _roommates.add(User(
          name: '사과',
          dormitory: '지선관',
          department: '사과대',
          yearEnrolled: '21',
          birthYear: '02',
          profilePath: 'assets/profile_teacher.png',
          isSmoking: false,
          checklist: checklistMap
      ));
      _roommates.add(User(
          name: '배',
          dormitory: '인의관',
          department: '공대',
          yearEnrolled: '24',
          birthYear: '06',
          profilePath: 'assets/profile_vet.png',
          isSmoking: false,
          checklist: checklistMap
      ));
      _roommates.add(User(
          name: 'Orange',
          dormitory: '계영원',
          department: '경영대',
          yearEnrolled: '24',
          birthYear: '05',
          profilePath: 'assets/profile_computer.png',
          isSmoking: false,
          checklist: checklistMap
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text('룸메이트 검색', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: Row(
                children: [
                  InkWell(
                    /*splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,*/
                    child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: group_button_outline, width: 1.0)),
                        child: Icon(Icons.refresh_rounded, color: black, size: 20)
                    ),
                    onTap: () {
                      setState(() {
                        _clearFilters();
                      });
                    }
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IgnorePointer(
                        ignoring: true,
                        child: GroupButton(
                            buttons: filterOptions,
                            controller : _filterButtonController,
                            isRadio: false,
                            onSelected: (val, i, selected) {},
                            buttonBuilder: (selected, value, context) {
                              return checklistGroupButton(selected, value);
                            },
                            options: GroupButtonOptions(spacing: 4, )
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                      child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(color: grey_button_greyBG, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: grey_button_greyBG, width: 1.0)),
                          child: Icon(Icons.tune_rounded, color: black, size: 20)
                      ),
                      onTap: () async {
                        final result = await showBarModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) => FilterSelectModal(selectedFilters: _selectedFilters, onModalReset: _clearFilters),
                          isDismissible: false,
                          enableDrag: false
                        );

                        if(result != null && result is Map<String, Set<String>>){
                          setState(() {
                            _selectedFilters = result;
                          });
                          _updateGroupButtonSelection();
                        }
                      }
                  ),
                ]
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _roommates.length,
                itemBuilder: (context, index) {
                  return InkWell(child: RoommateListItem(_roommates[index]), onTap: (){
                    showBarModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) => RoommateDetailModal(isMine: false, user: _roommates[index]),
                    );
                  });
                },
                separatorBuilder: (context, index) => Divider(height: 1, color: grey_seperating_line),
              ),
            )
          ]
        )
      )
    );
  }
}

Widget RoommateListItem (User user) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50.w,
          height: 50.h,
          child: CircleAvatar(
            backgroundImage: AssetImage(user.profilePath),
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${user.name}', style: mediumBlack16),
                SizedBox(width: 6.w),
                if(user.isSmoking)
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: Image.asset('assets/smoking.png')
                  )
                else
                  SizedBox(
                    width: 20.w,
                    height: 20.h
                  )
              ]
            ),
            SizedBox(height: 2.h),
            Text('${user.dormitory} | ${user.yearEnrolled}학번 | ${user.birthYear}년생', style: mediumGrey14)
          ]
        )
      ]
    )
  );
}
