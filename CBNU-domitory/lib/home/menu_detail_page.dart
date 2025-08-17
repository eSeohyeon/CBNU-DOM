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
  late String _content = '<p>불러오는 중...</p>';

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
        final element = document.querySelector('#contentBody > table.contTable_c.m_table_c.margin_t_30');
        _content = element?.outerHtml ?? '<p>내용을 불러올 수 없습니다.</p>';
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
      body: Column(
        children: [
          TabBar(
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
                Tab(text: '본관'),
                Tab(text: '양성재'),
                Tab(text: '양진재'),
              ]
          ),
          SizedBox(height: 6.h),
          TabBarView(
              controller: _tabController,
              children: [
                HtmlWidget(_content!, textStyle: const TextStyle(fontSize: 14)),
                HtmlWidget(_content!, textStyle: const TextStyle(fontSize: 14)),
                HtmlWidget(_content!, textStyle: const TextStyle(fontSize: 14)),
              ]
          )
        ],
      ),
    );
  }
}