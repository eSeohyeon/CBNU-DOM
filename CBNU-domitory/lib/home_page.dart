import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/themes/styles.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/models/notice.dart';

import 'package:untitled/home/menu_detail_page.dart';
import 'package:untitled/home/notice_detail_page.dart';
import 'package:untitled/home/notice_list_page.dart';

enum MealType { breakfast, lunch, dinner }

class MealTime {
  final String start;
  final String end;
  MealTime({required this.start, required this.end});
}

final Map<MealType, String> mealNames = {
  MealType.breakfast: '아침',
  MealType.lunch: '점심',
  MealType.dinner: '저녁',
};

final Map<MealType, MealTime> weekdayTimes = {
  MealType.breakfast: MealTime(start: '07:20', end: '09:00'),
  MealType.lunch: MealTime(start: '11:30', end: '13:30'),
  MealType.dinner: MealTime(start: '17:30', end: '19:10'),
};

final Map<MealType, MealTime> weekendTimes = {
  MealType.breakfast: MealTime(start: '08:00', end: '09:00'),
  MealType.lunch: MealTime(start: '12:00', end: '13:00'),
  MealType.dinner: MealTime(start: '17:30', end: '19:00'),
};

bool isWeekend(){
  final now = DateTime.now();
  return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showRoomMateAlert = true;
  bool _showGroupBuyAlert = true;
  String _selectedDorm = '본관';
  final List<String> dorms = ['본관', '양성재', '양진재'];

  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // 로그아웃 성공 시 AuthGate가 자동으로 LoginPage로 이동시킴
  }

  // 테스트용
  final Notice _notice1 = Notice(title: '[양성재, 양진재] 조경 작업 안내 (시비,전정 및 수목 병충해 방제 작업 등)', writer: '운영사(주)체스넛1', date: '2025/05/09', link: 'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20039&mod=view&no=454178657&listCnt=20');
  final Notice _notice2 = Notice(title: '[양성재] 지선관 LED 전등 교체 공사 안내 (일정 변경)', writer: '운영사(주)체스넛1', date: '2025/05/07', link: 'https://dorm.chungbuk.ac.kr/home/sub.php?menukey=20039&mod=view&no=454178656&listCnt=20');
  final Post _post1 = Post(title: '취업 꿀팁', writer: '서울사이버대학', date: '05/09', time: '03:34', contents: '서울사이버대학에 다니고 나의 성공시대 시작됐다.', likeCount: 222);
  final Post _post2 = Post(title: '사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거같잖아피로하잖아겁에질렸잖아몽롱하잖아고문당하는거같잖아불안하잖아죽을거같잖아고통스럽잖아미칠거같잖아숨이막히잖아', writer: '부족한사람', date: '05/07', time: '12:34', contents: '사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거같잖아피로하잖아겁에질렸잖아몽롱하잖아고문당하는거같잖아불안하잖아죽을거같잖아고통스럽잖아미칠거같잖아숨이막히잖아폐가아프잖아그만해야하잖아정신나갈거같잖아루나틱하잖아토할거같잖아구역질이나올거같잖아속이뒤트는거같잖아비틀어질거같잖아휘청거릴거샅잖아어지럽잖아배사아프잖아위가꼬이는거같잖아장이꼬이는거같잖아온몸에쥐난거같잖아심장이아프잖아다들지쳤잖아사람들이지쳤잖아힘들잖아그만해야하잖아이러면안되는거잖아그만해야하잖아맞잖아지쳤잖아힘들잖아괴롭잖아숨막히잖아정신나갈거', likeCount: 55);
  final GroupBuyPost _groupBuyPost1 = GroupBuyPost(basePost: Post(title: '싱싱한 국내산 흙당근 제주구좌당근 2kg', writer: '멋진농부', date: '2025/05/11', time: '20:59', contents: '당근 같이 먹을 사람~', likeCount: 2), itemUrl: 'https://item.gmarket.co.kr/Item?goodscode=3293466711&buyboxtype=ad', itemImagePath: 'assets/img_item.png', itemPrice: 11130, maxParticipants: 4, currentParticipants: 3);
  final GroupBuyPost _groupBuyPost2 = GroupBuyPost(basePost: Post(title: '싱싱한 국내산 흙당근 제주구좌당근 2kg', writer: '멋진농부', date: '2025/05/11', time: '20:59', contents: '당근 같이 먹을 사람~', likeCount: 2), itemUrl: 'https://item.gmarket.co.kr/Item?goodscode=3293466711&buyboxtype=ad', itemImagePath: 'assets/img_item.png', itemPrice: 22040, maxParticipants: 8, currentParticipants: 7);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: Stack(
          children: [
            Scaffold(
              backgroundColor: background,
              appBar: AppBar(
                backgroundColor: background,
                surfaceTintColor: background,
                leading: PopupMenuButton<String>(
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: black, size: 24),
                  onSelected: (String dorm) {
                    setState(() {
                      _selectedDorm = dorm;
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
                actions: [ // 임시로 로그아웃 버튼
                  IconButton(icon: Icon(Icons.account_circle_rounded, color: black, size: 32), onPressed: signOut)
                ],
                actionsPadding: EdgeInsets.only(right: 8),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 2.h),
                  child: Column( // 본문 내용
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(_showRoomMateAlert)
                        Card( // 대화 중인 룸메 카드 알림
                            color: white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.only(left:4.w),
                              child: Row(
                                children: [
                                  Image.asset('assets/roommate_cardAlert.png'),
                                  SizedBox(width: 4.w),
                                  Expanded(child: Text('지금 대화 중인 룸메가 있어요!', style: mediumBlack16)),
                                  IconButton(icon: Icon(Icons.close, color: grey_outline_inputtext, size: 20),  onPressed: () { setState(() {
                                    _showRoomMateAlert = false;
                                  });})
                                ],
                              ),
                            )
                        ),
                      if(_showGroupBuyAlert)
                        Card( // 참여 중인 공동구매 있음 카드 알림
                            color: white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.only(left:10.w),
                              child: Row(
                                children: [
                                  Image.asset('assets/groupBuy_cardAlert.png'),
                                  SizedBox(width: 8.w),
                                  Expanded(child: Text('지금 참여 중인 공동구매가 있어요!', style: mediumBlack16)),
                                  IconButton(icon: Icon(Icons.close, color: grey_outline_inputtext, size: 20),  onPressed: () {
                                    _showGroupBuyAlert = false;
                                  })
                                ],
                              ),
                            )
                        ),
                      Card( // 세탁 카드 잔액 확인 카드
                          color: white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: grey_seperating_line, width: 1.0)
                          ),
                          elevation: 0,
                          child: InkWell(
                            splashColor: Colors.white70,
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () { print('LaundryCard tapped@'); },
                            child: Padding(
                                padding: EdgeInsets.only(left: 16.w, right: 14.w, top: 14.h, bottom: 14.h),
                                child: Row(
                                    children: [
                                      Expanded(child: Text('세탁카드 잔액 확인', style: mediumBlack16)),
                                      Icon(Icons.chevron_right_rounded, color: black, size: 24)
                                    ]
                                )
                            ),
                          )
                      ),
                      SizedBox(height: 42.h),
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
                            SizedBox(height: 6.h),
                            MealCard(selectedDormType: _selectedDorm) // 식단 메뉴 카드
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
                            NoticeCard(notice1: _notice1, notice2: _notice2) // 공지사항 카드
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
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                left: 145.w,
                bottom: 60.h,
                child: ElevatedButton.icon(
                  onPressed: () { print('chatbot button clicked'); },
                  icon: Image.asset('assets/chatbot.png'),
                  label: Text('챗봇', style: mediumBlack16),
                  style: ElevatedButton.styleFrom(overlayColor: grey_8, backgroundColor: white, side: BorderSide(color: grey_seperating_line, width: 1.0), padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 2, ),
                )
            )
          ]
      ),
    );
  }
}





class MealCard extends StatefulWidget {
  final String selectedDormType;
  const MealCard({super.key, required this.selectedDormType});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  MealType _selectedMeal = MealType.breakfast;

  void _switchMeal(bool isNext){
    setState(() {
      final nextIndex = (_selectedMeal.index + (isNext ? 1:-1)) % 3;
      _selectedMeal = MealType.values[nextIndex < 0 ? 2:nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealTimes = isWeekend()? weekendTimes:weekdayTimes;
    final time = mealTimes[_selectedMeal]!;

    String menus = '${widget.selectedDormType}\n${mealNames[_selectedMeal]}\n흰밥/우유(두유)/김치\n감자양파국\n부추계란찜\n치커리사과오렌지소스무침\n구운김\n에너지: 1111kcal\n단백질: 60g';

    return Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: grey_seperating_line, width: 1.0)),
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.only(top:2.h, bottom: 18.h),
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: Icon(Icons.chevron_left_rounded, color: black, size: 24), onPressed: () => _switchMeal(false)),
                        Text(mealNames[_selectedMeal]!, style: mediumBlack18),
                        IconButton(icon: Icon(Icons.chevron_right_rounded, color: black, size: 24), onPressed: () => _switchMeal(true))
                      ]
                  ),
                  Text('${time.start} ~ ${time.end}', style: mediumGrey14.copyWith(height: -0.4)),
                  SizedBox(height: 28.h),
                  Text(menus, style: mediumBlack16.copyWith(height: 1.6), textAlign: TextAlign.center)
                ]
            )
        )
    );
  }
}

class NoticeCard extends StatefulWidget {
  final Notice notice1;
  final Notice notice2;
  const NoticeCard({super.key, required this.notice1, required this.notice2});

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: grey_seperating_line, width: 1.0)),
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
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
                            MaterialPageRoute(builder: (context) => NoticeDetailPage(url: widget.notice1.link, item: widget.notice1))
                        );
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.notice1.title, style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                            SizedBox(height: 2.h),
                            Text(widget.notice1.date, style: mediumGrey14)
                          ]
                      )
                  ),
                  SizedBox(height: 10.h),
                  InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoticeDetailPage(url: widget.notice2.link, item: widget.notice2))
                        );
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.notice2.title, style: mediumBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                            SizedBox(height: 2.h),
                            Text(widget.notice2.date, style: mediumGrey14)
                          ]
                      )
                  )
                ]
            )
        )
    );
  }
}

class BestPostCard extends StatefulWidget { // 카드 위젯-실시간 인기글
  final Post bestPost;
  const BestPostCard({super.key, required this.bestPost});

  @override
  State<BestPostCard> createState() => _BestPostCardState();
}

class _BestPostCardState extends State<BestPostCard> {

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
                      Expanded(child: Text(widget.bestPost.writer, style: mediumBlack14)),
                      Text('${widget.bestPost.date} ${widget.bestPost.time}', style: mediumGrey13)
                    ]
                ),
                SizedBox(height: 16.h),
                Align(alignment: AlignmentDirectional.centerStart, child: Text(widget.bestPost.title, style: boldBlack16, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false)),
                SizedBox(height: 4.h),
                Align(alignment: AlignmentDirectional.centerStart, child: Text(widget.bestPost.contents, style: mediumBlack14, maxLines: 2, overflow: TextOverflow.ellipsis, softWrap: false)),
                SizedBox(height: 18.h),
                Row(
                    children: [
                      Spacer(),
                      Icon(Icons.thumb_up_outlined, color: Colors.red, size: 18),
                      SizedBox(width: 4.w),
                      Text(widget.bestPost.likeCount.toString(), style: mediumGrey13.copyWith(color: Colors.red))
                    ]
                )
              ]
          )
      ),
    );
  }
}

class GroupBuyPostCard extends StatefulWidget { // 카드 위젯 - 너만 오면 되는 공동구매
  final GroupBuyPost groupBuyPost;
  const GroupBuyPostCard({super.key, required this.groupBuyPost});

  @override
  State<GroupBuyPostCard> createState() => _GroupBuyPostCardState();
}

class _GroupBuyPostCardState extends State<GroupBuyPostCard> {
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
                  SizedBox(width: 100.w, height: 100.h, child: Image.asset(widget.groupBuyPost.itemImagePath)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.groupBuyPost.basePost.title, style: mediumBlack14, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                          Text('${widget.groupBuyPost.itemPrice}원', style: boldBlack16),
                          Text('1인당 ${widget.groupBuyPost.itemPrice / widget.groupBuyPost.maxParticipants}원', style: mediumGrey13),
                          SizedBox(height: 20.h),
                          Row(
                              children: [
                                Icon(Icons.person, color: grey_8, size: 20),
                                SizedBox(width: 2.w),
                                Text('${widget.groupBuyPost.currentParticipants}/${widget.groupBuyPost.maxParticipants}', style: mediumGrey13)
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