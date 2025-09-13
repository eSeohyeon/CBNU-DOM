import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DormType{
  BONGUAN(name: "본관", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=1"),
  SEONGJAE(name: "양성재", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=2"),
  JINJAE(name: "양진재", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=3");

  final String name;
  final String url;
  const DormType({required this.name, required this.url});
}

class MealDetailPage extends StatefulWidget {
  String selectedDorm;
  MealDetailPage({super.key, required this.selectedDorm});

  @override
  State<MealDetailPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealDetailPage> with TickerProviderStateMixin{
  late String _selectedDorm;
  final List<String> dorms = ['본관', '양성재', '양진재'];
  final List<Map<String, dynamic>> _weekMenu = [];
  bool _isLoading = false;
  String _content = '식단을 불러오는 중...';

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedDorm = widget.selectedDorm;
    });
    fetchWeekMenu();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchWeekMenu() async {
    setState(() {
      _isLoading = true;
    });
    final String url;
    if(_selectedDorm == '본관') {
      url = "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=1";
    } else if (_selectedDorm == '양성재') {
      url = "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=2";
    } else if (_selectedDorm == '양진재') {
      url = "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=3";
    } else {
      url = "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=1";
    }

    try {
      final uriUrl = Uri.parse(url);
      final response = await http.get(uriUrl);

      if(response.statusCode == 200){
        final document = parser.parse(response.body);
        final rows = document.querySelectorAll('tbody tr');

        _weekMenu.clear();

        for(var row in rows) {
          final dayTd = row.querySelector('td.foodday');
          final breakfastTd = row.querySelector('td.morning');
          final lunchTd = row.querySelector('td.lunch');
          final dinnerTd = row.querySelector('td.evening');

          if (dayTd == null || dayTd.innerHtml.trim().isEmpty) {
            continue; // 유효하지 않은 행은 건너뜁니다.
          }

          final dayContent = dayTd?.querySelector('strong')?.innerHtml ?? dayTd?.innerHtml; // strong 태그 있을때만

          _weekMenu.add({
            'day': dayContent?.replaceAll('\n', '').replaceAll('<br>', '\n').trim() ?? '',
            'breakfast': breakfastTd?.innerHtml.replaceAll('\n', '').replaceAll('<br>', '\n').replaceAll('&amp;', '&').trim() ?? '',
            'lunch': lunchTd?.innerHtml.replaceAll('\n', '').replaceAll('<br>', '\n').replaceAll('&amp;', '&').trim() ?? '',
            'dinner': dinnerTd?.innerHtml.replaceAll('\n', '').replaceAll('<br>', '\n').replaceAll('&amp;', '&').trim() ?? '',
          });
        }

        for(var item in _weekMenu){
          print(item);
        }
      }
    } catch (e) {
      debugPrint("Failed to get week menu: $e");
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        titleSpacing: 0,
        title: Text('이번주 식단', style: mediumBlack16),
        actions: [
          Text(_selectedDorm, style: mediumBlack14),
          PopupMenuButton<String>(
            color: white,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: black, size: 24),
            onSelected: (String dorm) {
              setState(() {
                _selectedDorm = dorm;
                fetchWeekMenu();
              });
            },
            itemBuilder: (BuildContext context){
              return dorms.map((String dorm) {
                return PopupMenuItem<String>(
                    value: dorm,
                    child: Text(dorm, style: mediumBlack16)
                );
              }).toList();
            },
            offset: Offset(0, 56),
          ),
        ]
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: _isLoading ?
          Center(
            child: CircularProgressIndicator(
                color: black
            ),
          ) :
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                  border: TableBorder(
                    verticalInside: BorderSide(color: grey_seperating_line, width: 1),
                    horizontalInside: BorderSide(color: grey_seperating_line, width: 1),
                  ),
                  columnWidths: <int, TableColumnWidth> {
                    0: FixedColumnWidth(70.w),
                    1: FixedColumnWidth(120.w),
                    2: FixedColumnWidth(120.w),
                    3: FixedColumnWidth(120.w),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                  color: Colors.grey[200],
              ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                            child: TableCell(child: Center(child: Text('요일', style: boldBlack14))),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                            child: TableCell(child: Center(child: Text('아침', style: boldBlack14))),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                            child: TableCell(child: Center(child: Text('점심', style: boldBlack14))),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                            child: TableCell(child: Center(child: Text('저녁', style: boldBlack14))),
                          ),
                        ]
                    ),
                    ..._weekMenu.map((item) {
                      return TableRow(
                          children: item.values.map((value) {
                            return TableCell(
                                child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                                    child: Text(value.toString(), style: mediumBlack14, textAlign: TextAlign.center)
                                )
                            );
                          }).toList()
                      );
                    }).toList()
                  ]
              ),
            ),
          )
        )
            )

    );
  }
}