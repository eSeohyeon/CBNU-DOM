import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:untitled/models/meal.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

enum DormType{
  BONGUAN(name: "본관", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=1"),
  SEONGJAE(name: "양성재", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=2"),
  JINJAE(name: "양진재", url: "https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&type=3");

  final String name;
  final String url;
  const DormType({required this.name, required this.url});
}

class MealDetailPage extends StatefulWidget {
  const MealDetailPage({Key? key}) : super(key: key);

  @override
  State<MealDetailPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealDetailPage> with TickerProviderStateMixin{
  DormType _selectedDorm = DormType.BONGUAN;
  bool _isLoading = false;
  late TabController _tabController;
  String _content = '식단을 불러오는 중...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener((){
      if(_tabController.indexIsChanging) return;
      final currentIndex = _tabController.index;

      if(currentIndex == 0){
        setState(() {
          _selectedDorm = DormType.BONGUAN;
          fetchMealScreen();
        });
      } else if (currentIndex == 1) {
        setState(() {
          _selectedDorm = DormType.SEONGJAE;
          fetchMealScreen();
        });
      } else if (currentIndex == 2) {
        setState(() {
          _selectedDorm = DormType.JINJAE;
          fetchMealScreen();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchMealScreen() async {
    setState(() {
      _isLoading = true;
    });


    try {
      final url = _selectedDorm.url;
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        final document = parser.parse(response.body);
        final table = document.querySelector('table.contTable_c');

        if(table != null) {
          final style = '''
            <style>
    .contTable_c {
      width: 100%;
      border-collapse: collapse;
    }
    .contTable_c th, .contTable_c td {
      border: 1px solid #ddd;
      padding: 16px;  /* Increase this value for more internal spacing */
      text-align: left;
      vertical-align: top;
      font-size: 14px;
      line-height: 1.6; /* Add line height for better text readability */
    }
    .contTable_c th {
      background-color: #f2f2f2;
    }
    .contTable_c td br {
      content: "";
      display: block;
      margin-bottom: 10px; /* Add margin below line breaks */
    }
  </style>
          ''';
          setState(() {
            _content = style + table.outerHtml;
            _isLoading = false;
          });
        } else {
          setState(() {
            _content = '식단표 테이블을 찾을 수 없습니다.';
            _isLoading = false;
          });
        }
      }

    } catch(e) {
      setState(() {
        _content = '<p>에러 발생: ${e.toString()}</p>';
        _isLoading = false;
      });
    }
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.center,
                labelStyle: mediumBlack16,
                unselectedLabelColor: grey,
                indicatorColor: black,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorPadding: EdgeInsets.only(bottom: -2),
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                labelPadding: EdgeInsets.symmetric(horizontal: 24.w),
                tabs: [
                  Tab(text: '본관'),
                  Tab(text: '양성재'),
                  Tab(text: '양진재'),
                ]
            ),
            Container(
                width: double.infinity,
                height: 1.h,
                color: grey_seperating_line
            ),
            SizedBox(height: 6.h),
            Expanded( // <-- Wrap TabBarView with Expanded
              child: TabBarView(
                controller: _tabController,
                children: [
                  // You should handle the loading state within each TabView child
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: HtmlWidget(_content, textStyle: const TextStyle(fontSize: 14)),
                  ),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: HtmlWidget(_content, textStyle: const TextStyle(fontSize: 14)),
                  ),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: HtmlWidget(_content, textStyle: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}