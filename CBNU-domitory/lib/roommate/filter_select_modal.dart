import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/group_category.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

import 'package:group_button/group_button.dart';
import 'package:untitled/roommate/checklist_group_button.dart';

class FilterSelectModal extends StatefulWidget {
  final Map<String, Set<String>> selectedFilters;
  final VoidCallback? onModalReset;
  const FilterSelectModal({super.key, required this.selectedFilters, required this.onModalReset});

  @override
  State<FilterSelectModal> createState() => _FilterSelectModalState();
}

class _FilterSelectModalState extends State<FilterSelectModal> with TickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, Set<String>> _modalSelectedFilters;

  List<Widget> _buildSelectedFilterButtons() {
    List<Widget> buttons = [];
    _modalSelectedFilters.forEach((key, values) {
      String subCategoryTitle = key.split(':').last;

      for(String selection in values) {
        buttons.add(
          Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$subCategoryTitle : $selection',
                    style: mediumWhite14
                  ),
                  SizedBox(width: 4.w),
                  InkWell(
                    child: Icon(Icons.close_rounded, color: white, size: 14),
                    onTap: () {
                      setState(() {
                        _modalSelectedFilters[key]!.remove(selection);
                        if(_modalSelectedFilters[key]!.isEmpty){
                          _modalSelectedFilters.remove(key);
                        }
                        _syncGroupButtonState(key.split(':').first, subCategoryTitle, selection, false);
                      });
                    }
                  )
                ]
              )
            )
          )
        );
      }
    });
    return buttons;
  }

  void _syncGroupButtonState(String major, String sub, String option, bool isSelected) {
    for(var category in allCategories){
      if(category.categoryName == major){
        for(var group in category.groups){
          if(group.title == sub){
            int index = group.options.indexOf(option);
            if(index != -1){
              if(isSelected){
                group.controller.selectIndex(index);
              }else{
                group.controller.unselectIndex(index);
              }
            }
            return;
          }
        }
      }
    }
  }

  void initState(){
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _modalSelectedFilters = Map.from(widget.selectedFilters);

    for(var entry in _modalSelectedFilters.entries){
      List<String> majorAndSub = entry.key.split(':');
      String major = majorAndSub.first;
      String sub = majorAndSub.last;

      for(var category in allCategories){
        if(category.categoryName == major){
          for(var group in category.groups){
            if(group.title == sub){
              for(String selectedOption in entry.value){
                int index = group.options.indexOf(selectedOption);
                if(index!=-1){
                  group.controller.selectIndex(index);
                }
              }
            }
          }
        }
      }
    }
  }

  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.7.sh,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('필터', style: boldBlack18),
                  ]
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  InkWell(
                      child: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: group_button_outline, width: 1.0)),
                          child: Icon(Icons.refresh_rounded, color: black, size: 18)
                      ),
                      onTap: () {
                        setState(() {
                          _modalSelectedFilters.clear();
                          for (var category in allCategories) {
                            for (var group in category.groups) {
                              group.controller.unselectAll();
                            }
                          }
                        });
                        if(widget.onModalReset != null) {
                          widget.onModalReset!();
                        }
                      }
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildSelectedFilterButtons(),
                      )
                    )
                  )
                ]
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
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
                    children: allCategories.map((groupCategory) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groupCategory.groups.map((groupData) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 0.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(groupData.title, style: mediumBlack16),
                                    SizedBox(height: 10.h),
                                    GroupButton(
                                      controller: groupData.controller,
                                      buttons: groupData.options,
                                      isRadio: false,
                                      onSelected: (val, i, selected) {
                                        setState(() {
                                          String filterKey = '${groupCategory.categoryName}:${groupData.title}';
                                          _modalSelectedFilters.putIfAbsent(filterKey, () => {});

                                          if(selected) {
                                            _modalSelectedFilters[filterKey]!.add(val);
                                          } else {
                                            _modalSelectedFilters[filterKey]!.remove(val);
                                            if(_modalSelectedFilters[filterKey]!.isEmpty){
                                              _modalSelectedFilters.remove(filterKey);
                                            }
                                          }
                                        });
                                      },
                                      buttonBuilder: (selected, value, context) {
                                        return filterGroupButton(selected, value);
                                      },
                                      options: GroupButtonOptions(spacing: 4, alignment: Alignment.centerLeft),
                                    ),
                                    SizedBox(height: 22.h)
                                  ]
                                )
                              );
                            }).toList()
                          )
                        )
                      );
                    }).toList()
                )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                    onPressed: () {
                      for (var category in allCategories){
                        for (var group in category.groups){
                          group.controller.unselectAll();
                        }
                      } // groupbutton 선택 해제 안되는 문제 해결

                      print(_modalSelectedFilters);

                      Navigator.pop(context, _modalSelectedFilters);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: black,
                        overlayColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
                        elevation: 0
                    ),
                    child: Text('필터 적용하고 닫기', style: boldWhite15)
                ),
              ),
            )
          ]
        )
      )
    );
  }
}
