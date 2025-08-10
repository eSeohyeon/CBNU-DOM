import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/user.dart';
import 'package:untitled/home/dorm_score_calculate.dart';

class DormScoreRanking extends StatefulWidget {
  const DormScoreRanking({super.key});

  @override
  State<DormScoreRanking> createState() => _DormScoreRankingState();
}

class _DormScoreRankingState extends State<DormScoreRanking> {
  bool _isCalculated = true;
  final List<User> _ranking = [];

  // lazyloading
  final int _loadedItemCount = 8;
  bool _isLoading = false;
  bool _hasMore = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    final List<User> _allUsers = [];
    _allUsers.add(User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 95));
    for(int i=0; i<20; i++){
      _allUsers.add(User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 95));
    }

    _ranking.addAll(_allUsers.take(_loadedItemCount));

    /*// 테스트용 더미데이터
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 95));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: '가나초콜릿', department: '전정대', yearEnrolled: '24학번', isSmoking: false, checklist: [], dormScore: 94));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: '삼성', department: '인문대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 93));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: '고구마주세요', department: '공대', yearEnrolled: '23학번', isSmoking: false, checklist: [], dormScore: 92));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: '이서현', department: '인문대', yearEnrolled: '24학번', isSmoking: false, checklist: [], dormScore: 91));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: '메에에에에론', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 90));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: 'apple', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 89));
    _ranking.add(User(profilePath: 'assets/profile_man.png', name: 'bannana', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 88));
    for(int i = 0; i<20; i++){
      _ranking.add(User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9));
    }*/
  }

  @override
  void dispose(){
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if(_isLoading) return;
    if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if(_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final int newItemsCount = 10;
    final List<User> newItems = [
      User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9),
      User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9),
      User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9),
      User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9),
      User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9),
      User(profilePath: 'assets/profile_man.png', name: '두부두부두루치기', department: '전정대', yearEnrolled: '25학번', isSmoking: false, checklist: [], dormScore: 9),
    ];

    setState(() {
      _ranking.addAll(newItems);
      _isLoading = false;
      if(newItems.length < newItemsCount){
        _hasMore=false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Column(
              children: [
                CircleAvatar(
                  child: Image.asset('assets/profile_man.png'),
                  radius: 44.0
                ),
                SizedBox(height: 10.h),
                Text('두부두부두루치기', style: mediumBlack18),
                SizedBox(height: 2.h),
                Text('전정대 / 25학번', style: mediumGrey14)
              ]
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('환산점수', style: mediumGrey14),
                      Text(_isCalculated? '77점' : '??점', style: boldBlack20)
                    ]
                  ),
                  Column(
                    children: [
                      Text('랭킹', style: mediumGrey14),
                      Text(_isCalculated ? '20위' : '??위', style: boldBlack20)
                    ]
                  ),
                  Column(
                    children: [
                      Text('상위', style: mediumGrey14),
                      Text(_isCalculated ? '10%' : '??%', style: boldBlack20)
                    ]
                  ),
                ],
              ),
            ),
            SizedBox(height: 36.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('환산점수 랭킹', style: boldBlack18),
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(color: grey_button, borderRadius: BorderRadius.circular(25.0)),
                  child: IconButton(
                    onPressed: () {
                      print('refresh button clicked!');
                    },
                    icon: Icon(Icons.refresh_rounded, color: grey, size: 20)
                  )
                )
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0)),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _ranking.length + (_hasMore ? 1:0),
                  itemBuilder: (context, index) {
                    if(index == _ranking.length){
                      if(_isLoading){
                        return Center(child: CircularProgressIndicator(color: black));
                      } else {
                        return SizedBox.shrink();
                      }
                    }
                    return RankingItem(rank: index+1, user: _ranking[index]);
                  },
                )
              ),
            )
          ]
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DormScoreCalculate()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: black, padding: EdgeInsets.only(top: 6.h, bottom: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 2,),
              child: Text(_isCalculated ? "다시 계산하기" : "나의 환산점수 계산하기", style: mediumWhite16),
            ),
          )
        )
      )
    );
  }
}

class RankingItem extends StatelessWidget {
  User user;
  int rank;
  RankingItem({super.key, required this.rank, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(rank.toString(), style: mediumBlack18),
              SizedBox(width: 20.w),
              CircleAvatar(
                  child: Image.asset(user.profilePath),
                  radius: 20.0
              ),
              SizedBox(width: 8.w),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: mediumBlack14),
                    Text('${user.department} / ${user.yearEnrolled}', style: mediumGrey14)
                  ]
              ),
            ]
          ),
          Text('${user.dormScore}점', style: mediumBlack18)
        ],
      ),
    );
  }
}

