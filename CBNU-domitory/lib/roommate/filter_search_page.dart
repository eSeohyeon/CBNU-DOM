import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/roommate/checklist_page.dart';
import 'package:untitled/roommate/filter_options_modal.dart';
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
  final List<String> filterOptions = ['기본정보 ▾', '생활패턴 ▾', '생활습관 ▾', '성격 ▾', '성향 ▾', '기타 ▾'];
  late GroupButtonController  _filterButtonController;
  Map<String, Set<String>> _selectedFilters = {};
  late List<GroupCategory> _filterCategories;

  List<User> _roommates = [];

  @override
  void initState(){
    super.initState();
    _filterButtonController = GroupButtonController(
      selectedIndex: 0,
    );
    _filterCategories = deepCopyAllCategories();

    for(int i = 0; i<40; i++){
      _roommates.add(User(
        name: '키위',
        dormitory: '예지관',
        department: '전정대',
        yearEnrolled: '25',
        birthYear: '07',
        profilePath: 'assets/profile_man.png',
        isSmoking: true,
        checklist: checklistMap
      ));
      _roommates.add(User(
          name: '바나나',
          dormitory: '신민관',
          department: '인문대',
          yearEnrolled: '25',
          birthYear: '07',
          profilePath: 'assets/profile_man.png',
          isSmoking: true,
          checklist: checklistMap
      ));
      _roommates.add(User(
          name: '사과',
          dormitory: '지선관',
          department: '사과대',
          yearEnrolled: '21',
          birthYear: '02',
          profilePath: 'assets/profile_man.png',
          isSmoking: false,
          checklist: checklistMap
      ));
      _roommates.add(User(
          name: '배',
          dormitory: '인의관',
          department: '공대',
          yearEnrolled: '24',
          birthYear: '06',
          profilePath: 'assets/profile_man.png',
          isSmoking: false,
          checklist: checklistMap
      ));
      _roommates.add(User(
          name: 'Orange',
          dormitory: '계영원',
          department: '경영대',
          yearEnrolled: '24',
          birthYear: '05',
          profilePath: 'assets/profile_man.png',
          isSmoking: false,
          checklist: checklistMap
      ));
    }
  }

  List<GroupCategory> deepCopyAllCategories() {
    return allCategories.map((cat) {
      return GroupCategory(
          cat.categoryName,
          cat.groups.map((group) {
            return GroupData(
                title: group.title,
                options: List<String>.from(group.options)
            );
          }).toList()
      );
    }).toList();
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
                      _filterButtonController.unselectAll();
                    }
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GroupButton(
                          buttons: filterOptions,
                          controller : _filterButtonController,
                          isRadio: false,
                          onSelected: (val, i, selected){
                            print('filter modal up!');
                          },
                          buttonBuilder: (selected, value, context) {
                            return checklistGroupButton(selected, value);
                          },
                          options: GroupButtonOptions(spacing: 4)
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
                        await showBarModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) => FilterOptionsModal(
                            selectedFilters: _selectedFilters,
                            allCategories: _filterCategories,
                            onFilterChanged: (filters, categories){
                              setState(() {
                                _selectedFilters = filters;
                                _filterCategories = categories;
                              });
                            }
                          )
                        );
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
                      builder: (BuildContext context) => RoommateDetailModal(user: _roommates[index]),
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
        CircleAvatar(
          radius: 24.0,
          child: Image.asset(user.profilePath),
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
