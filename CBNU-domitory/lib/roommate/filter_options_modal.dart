import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:untitled/models/user.dart';
import 'package:untitled/models/checklist_map.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/models/group_category.dart';
import 'package:group_button/group_button.dart';
import 'package:untitled/roommate/checklist_group_button.dart';
import 'package:untitled/roommate/selected_filter_button.dart';


class FilterOptionsModal extends StatefulWidget {
  final Map<String, Set<String>> selectedFilters;
  final List<GroupCategory> allCategories;
  final void Function(Map<String, Set<String>> filters, List<GroupCategory> categories) onFilterChanged;
  const FilterOptionsModal({super.key, required this.selectedFilters, required this.allCategories, required this.onFilterChanged});

  @override
  State<FilterOptionsModal> createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Set<String>> _selectedFilters = {};

  void initState(){
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  void updateSelectedFilter(String title, String value, bool selected){
    setState(() {
      final set = _selectedFilters[title] ?? {};

      if (selected) {
        set.add(value);
      } else {
        set.remove(value);
      }

      if (set.isEmpty) {
        _selectedFilters.remove(title);
      } else {
        _selectedFilters[title] = set;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                            children: [
                              Text('필터', style: boldBlack18),
                              IconButton(
                                icon: Icon(Icons.close_rounded, color: black, size: 20),
                                onPressed: () {
                                  widget.onFilterChanged(_selectedFilters, widget.allCategories);
                                  Navigator.pop(context);
                                },
                              )
                            ]
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                child: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: group_button_outline, width: 1.0)),
                                    child: Icon(Icons.refresh_rounded, color: black, size: 18)
                                ),
                                onTap: () {
                                  setState(() {
                                    // GroupButton 초기화
                                    for (final category in widget.allCategories) {
                                      for (final group in category.groups) {
                                        group.controller.unselectAll();
                                      }
                                    }

                                    // 선택된 필터 초기화
                                    _selectedFilters.clear();
                                  });
                                }
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _selectedFilters.entries.expand((entry) {
                                    final title = entry.key;
                                    return entry.value.map((val) => MapEntry(title, val));
                                  }).map((entry) {
                                    final title = entry.key;
                                    final val = entry.value;

                                    return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                                      child: selectedFilterItem(title, val, () {
                                        // ❌ x 버튼 눌렀을 때
                                        setState(() {
                                          // 상태 제거
                                          updateSelectedFilter(title, val, false);

                                          // 버튼 선택 해제
                                          for (var category in allCategories) {
                                            for (var group in category.groups) {
                                              if (group.title == title) {
                                                final index = group.options.indexOf(val);
                                                if (index != -1) {
                                                  group.controller.unselectIndex(index);
                                                }
                                              }
                                            }
                                          }
                                        });
                                      }),
                                    );
                                  }).toList()
                                )
                              )
                            )
                          ]
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: TabBar(
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
                              Tab(text: '기본정보'),
                              Tab(text: '생활패턴'),
                              Tab(text: '생활습관'),
                              Tab(text: '성격'),
                              Tab(text: '성향'),
                              Tab(text: '취미/기타'),
                            ]
                        ),
                      ),
                      Container(height: 1, color: grey_seperating_line),
                      Expanded(
                          child: TabBarView(
                              controller: _tabController,
                              children: List.generate(allCategories.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                                  child: FilterTab(filter_items: allCategories[index], onSelectionChanged: updateSelectedFilter),
                                );
                              })
                          )
                      )
                    ]
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: black,
                            overlayColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                            elevation: 0
                        ),
                        child: Text('필터 적용하기', style: boldWhite15)
                    ),
                  )
              )
            ]
        )
    );
  }
}

class FilterTab extends StatefulWidget {
  GroupCategory filter_items;
  final Function(String title, String value, bool selected) onSelectionChanged;
  FilterTab({super.key, required this.filter_items, required this.onSelectionChanged});

  @override
  State<FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<FilterTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.filter_items.groups.map((group) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.title, style: mediumBlack16),
                SizedBox(height: 10.h),
                GroupButton(
                  controller: group.controller,
                  buttons: group.options,
                  isRadio: false,
                  onSelected: (val, i, selected) {
                    widget.onSelectionChanged(group.title, val, selected);
                  },
                  buttonBuilder: (selected, value, context){
                    return filterGroupButton(selected, value);
                  },
                  options: GroupButtonOptions(spacing: 4, alignment: Alignment.centerLeft)
                ),
                SizedBox(height: 22.h)
              ]
            )
          );
        }).toList()
      ),
    );
  }
}

