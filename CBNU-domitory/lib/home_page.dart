import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/profile/profile_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/models/notice.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:untitled/home/weather_service.dart';
import 'package:shimmer/shimmer.dart';

import 'package:untitled/home/menu_detail_page.dart';
import 'package:untitled/home/notice_detail_page.dart';
import 'package:untitled/home/notice_list_page.dart';
import 'package:untitled/home/dorm_score_ranking.dart';
import 'package:untitled/home/chatbot_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedDorm = '본관';
  String _currentDate = '';
  final List<String> dorms = ['본관', '양성재', '양진재'];
  final List<String> circleButtons = ['챗봇', '세탁카드', '환산점수', '공구쪽지', '룸메쪽지'];
  final List<Image> circleButtonImages = [
    Image.asset('assets/chatbot.png'),
    Image.asset('assets/washer.png'),
    Image.asset('assets/ranking.png'),
    Image.asset('assets/shopping_bags.png'),
    Image.asset('assets/two_speech_bubles.png'),
  ];
  List<String> _todayMenu = [];
  WeatherData? _currentWeather;
  List<Notice> _latestNotices = [];
  bool _isMealLoading = false;
  bool _isWeatherLoading = false;
  bool _isNoticeLoading = false;
  bool _isAnyLoadingError = false;
  final ScrollController _scrollController = ScrollController();

  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // 로그아웃 성공 시 AuthGate가 자동으로 LoginPage로 이동시킴
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  bool isTodayWeekEnd() {
    DateTime today = DateTime.now();
    if (today.weekday == DateTime.saturday || today.weekday == DateTime.sunday) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentDate = getCurrentDate();
    _onRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isAnyLoadingError = false;
    });

    try {
      await Future.wait([
        fetchTodayMenu(),
        fetchWeatherData(),
        fetchLatestNotice()
      ]);
    } catch (e) {
      debugPrint('Error in _onRefresh: $e');
      setState(() {
        _isAnyLoadingError = true;
      });
    }
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      _isWeatherLoading = true;
      _isAnyLoadingError = false;
    });

    try {
      if(_selectedDorm == '본관'){
        _currentWeather = await WeatherService.fetchWeather(68, 107);
      } else {
        _currentWeather = await WeatherService.fetchWeather(68, 106);
      }
    } catch (e) {
      debugPrint("Failed to get weather data: $e");
      setState(() {
        _isAnyLoadingError = true;
      });
    }

    setState(() {
      _isWeatherLoading = false;
    });
  }

  Future<void> fetchTodayMenu() async {
    setState(() {
      _isMealLoading = true;
      _isAnyLoadingError = false;
    });

    String url = '';
    if(_selectedDorm == '본관'){
      url = 'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&cur_day=$_currentDate&type=1';

      if(isTodayWeekEnd()){
        _todayMenu.add('본관 주말 식단 없음');
        _todayMenu.add('본관 주말 식단 없음');
        _todayMenu.add('본관 주말 식단 없음');

        setState(() {
          _isMealLoading = false;
        });
        return;
      }
    } else if (_selectedDorm == '양성재') {
      url = 'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&cur_day=$_currentDate&type=2';
    } else if (_selectedDorm == '양진재') {
      url = 'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20041&cur_day=$_currentDate&type=3';
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        print('status code 200 아님');
        _todayMenu.add('');
        _todayMenu.add('');
        _todayMenu.add('');
        setState(() {
          _isAnyLoadingError = true;
          _isMealLoading = false;
        });
        return;
      }
      final document = parser.parse(response.body);
      final tbody = document.querySelector('#contentBody > table.contTable_c.m_table_c.margin_t_30 > tbody');
      if (tbody == null) {
        print('@@@@@@@@@@@@@@t body null @@@@@@@@@@@@@@@@@@@@');
        _todayMenu.add('식단 데이터가 없습니다.');
        _todayMenu.add('식단 데이터가 없습니다.');
        _todayMenu.add('식단 데이터가 없습니다.');
        setState(() {
          _isMealLoading = false;
        });
        return;
      }
      final rows = tbody.querySelectorAll('tr');
      if(rows.length != 7) {
        _todayMenu.add('등록된 식단이 없습니다.');
        _todayMenu.add('등록된 식단이 없습니다.');
        _todayMenu.add('등록된 식단이 없습니다.');
        setState(() {
          _isMealLoading = false;
        });
        return;
      }
      _todayMenu.clear();

      for (var row in rows) {
        final rowId = row.id;
        if (rowId != _currentDate) continue;

        final cells = row.querySelectorAll('td');
        if (cells.length < 4) continue;

        _todayMenu.add(cells[1].innerHtml.replaceAll('<br>', '\n').trim());
        _todayMenu.add(cells[2].innerHtml.replaceAll('<br>', '\n').trim());
        _todayMenu.add(cells[3].innerHtml.replaceAll('<br>', '\n').trim());
      }
    } catch (e) {
      debugPrint("Failed to get data: $e");
      _todayMenu.add('');
      _todayMenu.add('');
      _todayMenu.add('');
      setState(() {
        _isAnyLoadingError = true;
      });
    }
    setState(() {
      _isMealLoading = false;
    });
  }

  Future<void> fetchLatestNotice() async {
    setState(() {
      _isNoticeLoading = true;
      _isAnyLoadingError = false;
    });

    final url = Uri.parse(
        'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20039&mod=&page=1&scode=00000002&listCnt=20');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        int count = 0;
        final document = parser.parse(response.body);
        final rows = document.querySelectorAll('#contentBody > form > div.containerIn > table > tbody > tr');

        _latestNotices.clear();

        for (var row in rows) {
          final isPinned = row.classes.contains('brd_notice'); // 고정 공지 UI에서 분리해야함.
          if (isPinned) continue;

          final cells = row.querySelectorAll('td');
          if (cells.length >= 4) {
            final titleAnchor = cells[1].querySelector('a');
            final title = titleAnchor?.text.trim() ?? '';
            final writer = cells[2].text.trim();
            final date = cells[3].text.trim();
            final href = titleAnchor?.attributes['href'] ?? '';
            final link =
                'https://dorm.chungbuk.ac.kr/home/$href';

            _latestNotices.add(Notice(
                title: title,
                writer: writer,
                date: date,
                link: link
            ));

            count++;
            if(count>=2) break;
          }
        }
      } else {
        _latestNotices.add(Notice(
            title: '공지사항을 불러올 수 없습니다.',
            writer: '',
            date: '',
            link: ''
        ));
        _latestNotices.add(Notice(
            title: '새로고침 시도.',
            writer: '',
            date: '',
            link: ''
        ));
        setState(() {
          _isAnyLoadingError = true;
        });
      }
    } catch (e) {
      debugPrint("Failed to get data: $e");
      _latestNotices.add(Notice(
          title: '공지사항을 불러올 수 없습니다.',
          writer: '',
          date: '',
          link: ''
      ));
      _latestNotices.add(Notice(
          title: '새로고침 시도.',
          writer: '',
          date: '',
          link: ''
      ));
      setState(() {
        _isAnyLoadingError = true;
      });
    }

    setState(() {
      _isNoticeLoading = false;
    });
  }


  // 테스트용
  final Post _post1 = Post(postId: 00001, title: '취업 꿀팁', writer: '서울사이버대학', date: '05/09', time: '03:34', contents: '서울사이버대학에 다니고 나의 성공시대 시작됐다.');
  final Post _post2 = Post(postId: 00002, title: '사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거같잖아피로하잖아겁에질렸잖아몽롱하잖아고문당하는거같잖아불안하잖아죽을거같잖아고통스럽잖아미칠거같잖아숨이막히잖아', writer: '부족한사람', date: '05/07', time: '12:34', contents: '사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거같잖아피로하잖아겁에질렸잖아몽롱하잖아고문당하는거같잖아불안하잖아죽을거같잖아고통스럽잖아미칠거같잖아숨이막히잖아폐가아프잖아그만해야하잖아정신나갈거같잖아루나틱하잖아토할거같잖아구역질이나올거같잖아속이뒤트는거같잖아비틀어질거같잖아휘청거릴거샅잖아어지럽잖아배사아프잖아위가꼬이는거같잖아장이꼬이는거같잖아온몸에쥐난거같잖아심장이아프잖아다들지쳤잖아사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거');
  final GroupBuyPost _groupBuyPost1 = GroupBuyPost(basePost: Post(postId: 10001,title: '싱싱한 국내산 흙당근 제주구좌당근 2kg', writer: '멋진농부', date: '2025/05/11', time: '20:59', contents: '당근 같이 먹을 사람~'), itemUrl: 'https://item.gmarket.co.kr/Item?goodscode=3293466711&buyboxtype=ad', itemImagePath: 'assets/img_item.png', itemPrice: 11130, maxParticipants: 4, currentParticipants: 3);
  final GroupBuyPost _groupBuyPost2 = GroupBuyPost(basePost: Post(postId: 10002, title: '싱싱한 국내산 흙당근 제주구좌당근 2kg', writer: '멋진농부', date: '2025/05/11', time: '20:59', contents: '당근 같이 먹을 사람~'), itemUrl: 'https://item.gmarket.co.kr/Item?goodscode=3293466711&buyboxtype=ad', itemImagePath: 'assets/img_item.png', itemPrice: 22040, maxParticipants: 8, currentParticipants: 7);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          surfaceTintColor: background,
          leading: PopupMenuButton<String>(
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: black, size: 24),
            onSelected: (String dorm) {
              setState(() {
                _selectedDorm = dorm;
                fetchTodayMenu();
                fetchWeatherData();
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
          titleSpacing: 0,
          title: Text(_selectedDorm, style: boldBlack18),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle_rounded, color: black, size: 32),
              onPressed: () {
                // ProfilePage로 이동합니다.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            )
          ],
          actionsPadding: EdgeInsets.only(right: 8),
        ),
        body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: _isAnyLoadingError
                ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/screen_error.png'),
                            SizedBox(height: 10.h),
                            Text('화면 로딩 중에 오류가 발생했어요', style: boldBlack18),
                            SizedBox(height: 2.h),
                            Text('화면을 아래로 당겨서 새로고침', style: mediumBlack14)
                          ]
                      )
                  ),
                )
            )
                : SingleChildScrollView(
              controller: _scrollController,
              child: Column( // 본문 내용
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    child: _isWeatherLoading ?
                    Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 95.h,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.shade300),
                        )) :
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [_currentWeather!.gradientStartColor, _currentWeather!.gradientEndColor],
                              stops: [0.0, 1.0]
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_currentWeather!.description, style: _currentWeather!.description == '비' ? boldBlack14.copyWith(color: white) : boldBlack14),
                                    Text('${_currentWeather!.temperature.toStringAsFixed(0)}°C', style: _currentWeather!.description == '비' ?  boldBlack24.copyWith(color: white) : boldBlack24),
                                    Text('체감온도 ${_currentWeather!.feelsLike.toStringAsFixed(0)}°C', style: _currentWeather!.description == '비' ? mediumWhite13 : mediumGrey13),
                                  ]
                              ),
                              Image.asset(
                                _currentWeather!.iconPath,
                                width: 70.w,
                                height: 70.h
                              )
                            ]
                          )
                        )
                  ),
                  SizedBox(height: 12.h),
                  SingleChildScrollView( // CircleButtons
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(circleButtons.length, (index) {
                            return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Column(
                                    children: [
                                      InkWell(
                                          borderRadius: BorderRadius.circular(30.0),
                                          onTap: () {
                                            if(index == 0){
                                              print('chatbot');
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage()));
                                            } else if(index==1){
                                              print('세탁카드');
                                            } else if(index==2){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => DormScoreRanking()));
                                            } else if(index==3){
                                              print('공구쪽지');
                                            } else if(index==4){
                                              print('룸메쪽지');
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Container(
                                                width: 42.w,
                                                height: 42.h,
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(25.0)),
                                                child: circleButtonImages[index]
                                            ),
                                          )
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(circleButtons[index], style: mediumBlack14)
                                    ]
                                )
                            );
                          })
                      )
                  ),
                  SizedBox(height: 36.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        Column( // 식단 메뉴 타이틀
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 12.w),
                                  Expanded(child: Text('오늘의 식단', style: boldBlack18)),
                                  InkWell(child: Text('더 보기 >', style: mediumGrey14), onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MealDetailPage())
                                    );
                                  }),
                                  SizedBox(width: 10.w)
                                ],
                              ),
                              SizedBox(height: 10.h),
                              _isMealLoading ?
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: double.infinity,
                                        height: 300.h,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.shade300),
                                      ))
                              )
                                  : CarouselSlider(
                                  items: [MealCard(menu: _todayMenu[0], timeIndex: 0), MealCard(menu: _todayMenu[1], timeIndex: 1), MealCard(menu: _todayMenu[2], timeIndex: 2)],
                                  options: CarouselOptions(
                                      viewportFraction: 0.88,
                                      height: 300.h,
                                      initialPage: 1,
                                      enableInfiniteScroll: true,
                                      autoPlay: false,
                                      enlargeCenterPage: true,
                                      scrollDirection: Axis.horizontal,
                                      enlargeFactor: 0.15
                                  )
                              ), // 식단 메뉴 카드
                            ]
                        ),
                        SizedBox(height: 42.h),
                        Column( // 최신공지사항 타이틀
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                  children: [
                                    SizedBox(width: 12.w),
                                    Expanded(child: Text('공지사항', style: boldBlack18)),
                                    InkWell(child: Text('더 보기 >', style: mediumGrey14), onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => NoticeListPage())
                                      );
                                    }),
                                    SizedBox(width: 10.w)
                                  ]
                              ),
                              SizedBox(height: 6.h),
                              _isNoticeLoading?
                              Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: double.infinity,
                                    height: 150.h,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey.shade300),
                                  ))
                                  : NoticeCard(notice1: _latestNotices[0], notice2: _latestNotices[1])// 공지사항 카드
                            ]
                        ),
                        SizedBox(height: 42.h),
                        Column( // 실시간 인기글 타이틀
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: Align(alignment: AlignmentDirectional.centerStart, child: Text('실시간 인기 글', style: boldBlack18)),
                              ),
                              SizedBox(height: 6.h),
                              Column(
                                  children: [
                                    BestPostCard(bestPost: _post1),
                                    SizedBox(height: 2.h),
                                    BestPostCard(bestPost: _post2)
                                  ]
                              )
                            ]
                        ),
                        SizedBox(height: 42.h),
                        Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: Align(alignment: AlignmentDirectional.centerStart, child: Text('너만 오면 되는 공동구매', style: boldBlack18)),
                              ),
                              SizedBox(height: 6.h),
                              GroupBuyPostCard(groupBuyPost: _groupBuyPost1),
                              SizedBox(height: 2.h),
                              GroupBuyPostCard(groupBuyPost: _groupBuyPost2)
                            ]
                        ),
                        SizedBox(height: 150.h)
                      ]
                    ),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}


class MealCard extends StatelessWidget {
  final String menu;
  final int timeIndex;
  const MealCard({super.key, required this.timeIndex, required this.menu});

  @override
  Widget build(BuildContext context) {
    List<String> timeLabels = ['아침', '점심', '저녁'];
    List<String> weekdayTime = ['07:20 ~ 09:00', '11:30 ~ 13:30', '17:30 ~ 19:10'];
    List<String> weekendTime = ['08:00 ~ 09:00', '12:00 ~ 13:00', '17:30 ~ 19:00'];

    bool isWeekend(){
      final now = DateTime.now();
      return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    }

    String mealLabel = timeLabels[timeIndex];
    String mealTime = isWeekend() ? weekendTime[timeIndex] : weekdayTime[timeIndex];

    return Container(
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0), border: Border.all(color: grey_seperating_line, width: 1.0)),
        width: double.infinity,
        child: Padding(
            padding: EdgeInsets.only(top:14.h, bottom: 12.h),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mealLabel, style: boldBlack16),
                  Text(mealTime, style: mediumGrey14),
                  SizedBox(height: 20.h),
                  SizedBox(
                      height: 195.h,
                      child: SingleChildScrollView(child: Text(menu, style: mediumBlack16, textAlign: TextAlign.center)))
                ]
            )
        )
    );
  }
}


class NoticeCard extends StatelessWidget {
  final Notice notice1;
  final Notice notice2;
  const NoticeCard({super.key, required this.notice1, required this.notice2});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: grey_seperating_line, width: 1.0)),
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width:10.w),
                        SizedBox(width:10.w,)
                      ]
                  ),
                  InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoticeDetailPage(url: notice1.link, item: notice1))
                        );
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notice1.title, style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                            SizedBox(height: 2.h),
                            Text(notice1.date, style: mediumGrey14)
                          ]
                      )
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoticeDetailPage(url: notice2.link, item: notice2))
                        );
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notice2.title, style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                            SizedBox(height: 2.h),
                            Text(notice2.date, style: mediumGrey14)
                          ]
                      )
                  )
                ]
            )
        )
    );
  }
}

class BestPostCard extends StatelessWidget { // 카드 위젯-실시간 인기글
  final Post bestPost;
  const BestPostCard({super.key, required this.bestPost});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: grey_seperating_line, width: 1.0)),
      elevation: 0,
      child: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 16.w, top: 12.h, bottom: 14.h),
          child: Column(
              children: [
                Row(
                    children: [
                      Icon(Icons.account_box_rounded, color: Colors.teal, size: 36),
                      SizedBox(width: 4.w),
                      Expanded(child: Text(bestPost.writer, style: mediumBlack14)),
                      Text('${bestPost.date} ${bestPost.time}', style: mediumGrey13)
                    ]
                ),
                SizedBox(height: 16.h),
                Align(alignment: AlignmentDirectional.centerStart, child: Text(bestPost.title, style: boldBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false)),
                SizedBox(height: 4.h),
                Align(alignment: AlignmentDirectional.centerStart, child: Text(bestPost.contents, style: mediumBlack14, maxLines: 2, overflow: TextOverflow.ellipsis, softWrap: false)),
                SizedBox(height: 18.h),
                Row(
                    children: [
                      Spacer(),
                      Icon(Icons.thumb_up_outlined, color: Colors.red, size: 18),
                      SizedBox(width: 4.w),
                    ]
                )
              ]
          )
      ),
    );
  }
}

class GroupBuyPostCard extends StatelessWidget { // 카드 위젯 - 너만 오면 되는 공동구매
  final GroupBuyPost groupBuyPost;
  const GroupBuyPostCard({super.key, required this.groupBuyPost});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: grey_seperating_line, width: 1.0)),
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 16.w, top: 14.h, bottom: 14.h),
            child: Row(
                children: [
                  SizedBox(width: 100.w, height: 100.h, child: Image.asset(groupBuyPost.itemImagePath)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(groupBuyPost.basePost.title, style: mediumBlack14, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                          Text('${groupBuyPost.itemPrice}원', style: boldBlack16),
                          Text('1인당 ${groupBuyPost.itemPrice / groupBuyPost.maxParticipants}원', style: mediumGrey13),
                          SizedBox(height: 20.h),
                          Row(
                              children: [
                                Icon(Icons.person, color: grey_8, size: 20),
                                SizedBox(width: 2.w),
                                Text('${groupBuyPost.currentParticipants}/${groupBuyPost.maxParticipants}', style: mediumGrey13)
                              ]
                          )
                        ]
                    ),
                  ),

                ]
            )
        )
    );
  }
}