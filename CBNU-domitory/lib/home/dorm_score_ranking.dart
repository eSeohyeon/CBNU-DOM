import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/user.dart';
import 'package:untitled/home/dorm_score_calculate.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/roommate/filter_search_page.dart';

class DormScoreRanking extends StatefulWidget {
  const DormScoreRanking({super.key});

  @override
  State<DormScoreRanking> createState() => _DormScoreRankingState();
}

class _DormScoreRankingState extends State<DormScoreRanking> {
  //bool _isCalculated = true;
  final List<User> _ranking = [];
  User? _currentUserData; // 로그인 사용자 정보

  // lazyloading
  final int _loadedItemCount = 8;
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? lastDocument;
  late ScrollController _scrollController;
  String? _currentUserDorm;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadCurrentUserDormAndRanking();
  }

  Future<void> _loadCurrentUserDormAndRanking() async {
  final currentUserId = auth.FirebaseAuth.instance.currentUser!.uid;
  final myChecklistDoc = await FirebaseFirestore.instance
      .collection('checklists')
      .doc(currentUserId)
      .get();

  _currentUserDorm = myChecklistDoc.data()?['checklist']?['취미/기타']?['생활관'] as String?;

  await _loadRanking();
}


  void _scrollListener() {
    if (_isLoading) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      _loadRanking();
    }
  }

  Future<void> _loadRanking() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('users')
        .orderBy('dormScore', descending: true)
        .limit(_loadedItemCount);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
    }

    final newUsers = <User>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      // 현재 사용자와 같은 기숙사인지 확인
      final checklistDoc = await FirebaseFirestore.instance
          .collection('checklists')
          .doc(doc.id)
          .get();
      final dorm = checklistDoc.data()?['checklist']?['취미/기타']?['생활관'] as String?;
      if (dorm != _currentUserDorm) continue;

    // 단과대 이미지 매핑
      String profilePath = 'assets/profile_man.png';
      String? matchedCollege;
      final userDept = data['department'] as String? ?? '';
      collegeToDepartments.forEach((college, departments) {
        if (departments.contains(userDept)) matchedCollege = college;
      });
      if (matchedCollege != null) {
        profilePath = collegeProfileImages[matchedCollege!] ?? 'assets/profile_man.png';
      }

    newUsers.add(User(
      id: doc.id,
      nickname: data['nickname'] as String? ?? '이름없음',
      department: data['department'] as String? ?? '',
      enrollYear: data['enrollYear'] as String? ?? '',
      birthYear: data['birthYear'] as String? ?? '',
      profilePath: profilePath,
      isSmoking: data['isSmoking'] as bool? ?? false,
      checklist: Map<String, dynamic>.from(data['checklist'] ?? {}),
      dormScore: (data['dormScore'] as num?)?.toDouble() ?? 0,
    ));
  }
  


    setState(() {
      _ranking.addAll(newUsers);
      _isLoading = false;
      if (newUsers.length < _loadedItemCount) _hasMore = false;
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _currentUserStream() {
    final currentUserId = auth.FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots();
  }

  Future<void> _updateDormScore(double score) async {
    final currentUserId = auth.FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'dormScore': score,
    });
  }

  Future<int> _getUserRank(double dormScore) async {
    final higherDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('dormScore', isGreaterThan: dormScore)
        .get();

    return higherDocs.size + 1; // 자신보다 높은 사람 수 + 1 = 내 순위
  }

  Future<Map<String, int>> _getRankAndTotal() async {
    final currentUserId = auth.FirebaseAuth.instance.currentUser!.uid;

    // 내 체크리스트 문서 가져오기
    final myChecklistDoc = await FirebaseFirestore.instance
        .collection('checklists')
        .doc(currentUserId)
        .get();

    final myChecklistData = myChecklistDoc.data();
    if (myChecklistData == null || myChecklistData['checklist']?['취미/기타']?['생활관'] == null) {
      return {'rank': 0, 'total': 1};
    }

    final myDormitory = myChecklistData['checklist']['취미/기타']['생활관'] as String;

    // 전체 체크리스트 가져오기
    final allChecklistDocs = await FirebaseFirestore.instance
        .collection('checklists')
        .get();

    // 같은 생활관 사용자만 필터링
    final dormUsers = allChecklistDocs.docs.where((doc) {
      final checklist = doc.data()['checklist'] as Map<String, dynamic>?;
      final dorm = checklist?['취미/기타']?['생활관'] as String?;
      return dorm == myDormitory;
    }).toList();

    if (dormUsers.isEmpty) {
      return {'rank': 0, 'total': 1};
    }

    final userIds = dormUsers.map((doc) => doc.id).toList();

    // users 컬렉션에서 dormScore 가져오기 (whereIn 10개씩 쪼개서 조회)
    final usersWithScores = <Map<String, dynamic>>[];
    for (var i = 0; i < userIds.length; i += 10) {
      final chunk = userIds.sublist(i, (i + 10) > userIds.length ? userIds.length : (i + 10));
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      usersWithScores.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        final score = (data['dormScore'] as num?)?.toDouble();
        if (score == null) return null; // dormScore 없으면 제외
        return {
          'id': doc.id,
          'score': score,
        };
      }).whereType<Map<String, dynamic>>()); // null 제거
    }
    // 점수순으로 정렬
    usersWithScores.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // 내 순위 계산
    final rank = usersWithScores.indexWhere((u) => u['id'] == currentUserId) + 1;
    final totalUsers = usersWithScores.length;

    return {'rank': rank, 'total': totalUsers};
  }




  String _getProfilePathForDepartment(String department) {
    String? matchedCollege;
    collegeToDepartments.forEach((college, departments) {
      if (departments.contains(department)) matchedCollege = college;
    });
    if (matchedCollege != null) {
      return collegeProfileImages[matchedCollege!] ?? 'assets/profile_man.png';
    }
    return 'assets/profile_man.png';
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            // 사용자 정보 + 점수/랭킹
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _currentUserStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final data = snapshot.data!.data()!;
                final currentUserId = snapshot.data!.id;

                _currentUserData = User(
                  id: currentUserId,
                  nickname: data['nickname'] ?? '이름없음',
                  department: data['department'] ?? '',
                  enrollYear: data['enrollYear'] ?? '',
                  birthYear: data['birthYear'] ?? '',
                  profilePath: _getProfilePathForDepartment(data['department'] ?? ''),
                  isSmoking: false,
                  checklist: {},
                  dormScore: data['dormScore'] ?? 0,
                );

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 44.0,
                      backgroundImage: AssetImage(_currentUserData!.profilePath),
                    ),
                    SizedBox(height: 10.h),
                    Text(_currentUserData!.nickname, style: mediumBlack18),
                    SizedBox(height: 2.h),
                    Text('${_currentUserData!.department} / ${_currentUserData!.enrollYear}', style: mediumGrey14),
                    SizedBox(height: 20.h),
                    Container(
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                      child: FutureBuilder<Map<String, int>>(
                        future: _getRankAndTotal(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                          final rank = snapshot.data!['rank'] ?? 0;
                          final totalUsers = snapshot.data!['total'] ?? 1;
                          final dormScore = _currentUserData?.dormScore ?? 0;

                          final topPercent = totalUsers <= 1 
                              ? 100 
                              :((rank / totalUsers) * 100).round();

                          print('DEBUG: rank=$rank, totalUsers=$totalUsers');
                          print('DEBUG: rank=$rank, totalUsers=$totalUsers');
                          print('DEBUG: rank=$rank, totalUsers=$totalUsers');
                          print('DEBUG: rank=$rank, totalUsers=$totalUsers');
                          print('DEBUG: rank=$rank, totalUsers=$totalUsers');


                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(children: [
                                Text('환산점수', style: mediumGrey14),
                                Text('${dormScore.toStringAsFixed(1)}점', style: boldBlack20),
                              ]),
                              Column(children: [
                                Text('랭킹', style: mediumGrey14),
                                Text('${rank}위', style: boldBlack20),
                              ]),
                              Column(children: [
                                Text('상위', style: mediumGrey14),
                                Text('$topPercent%', style: boldBlack20),
                              ]),
                            ],
                          );
                        },
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
                          decoration: BoxDecoration(
                            color: grey_button,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _ranking.clear();
                              lastDocument = null;
                              _hasMore = true;
                              _loadRanking();
                            },
                            icon: Icon(Icons.refresh_rounded, color: grey, size: 20),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                );
              },
            ),

            // 랭킹 리스트
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _ranking.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _ranking.length) {
                      if (_isLoading) {
                        return Center(child: CircularProgressIndicator(color: black));
                      } else {
                        return SizedBox.shrink();
                      }
                    }
                    return RankingItem(rank: index + 1, user: _ranking[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: () async {
                final newScore = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DormScoreCalculate()),
                );
                if (newScore != null) {
                  await _updateDormScore(newScore.toDouble());

                  setState(() {
                    if (_currentUserData != null) {
                      _currentUserData = User(
                        id: _currentUserData!.id,
                        nickname: _currentUserData!.nickname,
                        department: _currentUserData!.department,
                        enrollYear: _currentUserData!.enrollYear,
                        birthYear: _currentUserData!.birthYear,
                        profilePath: _currentUserData!.profilePath,
                        isSmoking: _currentUserData!.isSmoking,
                        checklist: _currentUserData!.checklist,
                        dormScore: newScore.toDouble(),
                      );
                    }
                  });

                  _ranking.clear();
                  lastDocument = null;
                  _hasMore = true;
                  _loadRanking();
                  await _loadRanking();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: black,
                padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                elevation: 2,
              ),
              child: Text("환산점수 계산하기", style: mediumWhite16),
            ),
          ),
        ),
      )
    );
    }
  }

  class RankingItem extends StatelessWidget {
    final User user;
    final int rank;
    const RankingItem({super.key, required this.rank, required this.user});

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text(rank.toString(), style: mediumBlack18),
              SizedBox(width: 20.w),
              CircleAvatar(
                  radius: 20.0,
                  backgroundImage: AssetImage(user.profilePath),
              ),
              SizedBox(width: 8.w),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nickname, style: mediumBlack14),
                    Text('${user.department} / ${user.enrollYear}',
                        style: mediumGrey14)
                  ]),
            ]),
            Text('${user.dormScore.toStringAsFixed(1)}점', style: mediumBlack18)
          ],
        ),
      );
    }
  }
