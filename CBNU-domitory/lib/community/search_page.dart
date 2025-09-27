import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:untitled/community/free/free_detail_page.dart';
import 'package:untitled/community/groupbuy/group_buy_detail_page.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchOption = 'title+content'; // 기본 검색 옵션
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchPosts() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final searchQuery = _searchController.text.trim();
    List<DocumentSnapshot> results = [];

    // 자유게시판 검색
    Query freePostsQuery =
    FirebaseFirestore.instance.collection('free_posts');
    if (_searchOption == 'nickname') {
      freePostsQuery =
          freePostsQuery.where('authorNickname', isEqualTo: searchQuery);
    }
    final freePostsSnapshot = await freePostsQuery.get();

    for (var doc in freePostsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (_searchOption == 'title' &&
          (data['title'] as String).contains(searchQuery)) {
        results.add(doc);
      } else if (_searchOption == 'title+content' &&
          ((data['title'] as String).contains(searchQuery) ||
              (data['contents'] as String).contains(searchQuery))) {
        results.add(doc);
      } else if (_searchOption == 'nickname') {
        results.add(doc);
      }
    }

    // 공동구매 게시판 검색
    Query groupBuyPostsQuery =
    FirebaseFirestore.instance.collection('group_buy_posts');
    if (_searchOption == 'nickname') {
      groupBuyPostsQuery =
          groupBuyPostsQuery.where('authorNickname', isEqualTo: searchQuery);
    }
    final groupBuyPostsSnapshot = await groupBuyPostsQuery.get();

    for (var doc in groupBuyPostsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (_searchOption == 'title' &&
          (data['productName'] as String).contains(searchQuery)) {
        results.add(doc);
      } else if (_searchOption == 'title+content' &&
          ((data['productName'] as String).contains(searchQuery) ||
              (data['content'] as String).contains(searchQuery))) {
        results.add(doc);
      } else if (_searchOption == 'nickname') {
        results.add(doc);
      }
    }

    // createdAt 기준으로 최신순 정렬
    results.sort((a, b) {
      final aTimestamp = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
      final bTimestamp = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
      return bTimestamp.compareTo(aTimestamp);
    });


    setState(() {
      _searchResults = results;
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
        title: Text('게시글 검색', style: mediumBlack16),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _searchOption,
                  items: const [
                    DropdownMenuItem(value: 'title+content', child: Text('제목+내용')),
                    DropdownMenuItem(value: 'title', child: Text('제목')),
                    DropdownMenuItem(value: 'nickname', child: Text('닉네임')),
                  ],
                  dropdownColor: white, // 드롭다운 배경색
                  onChanged: (value) {
                    setState(() {
                      _searchOption = value!;
                    });
                  },
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchPosts,
                      ),
                    ),
                    onSubmitted: (_) => _searchPosts(),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.separated(
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: grey_seperating_line),
              itemBuilder: (context, index) {
                final doc = _searchResults[index];
                final data = doc.data() as Map<String, dynamic>;
                final isFreePost = doc.reference.parent.id == 'free_posts';

                if (isFreePost) {
                  final post = Post(
                    postId: doc.id,
                    authorUid: data['authorUid'] ?? '',
                    title: data['title'] ?? '제목 없음',
                    contents: data['contents'] ?? '',
                    writer: data['authorNickname'] ?? '작성자 없음',
                    date: DateFormat('MM/dd').format(
                        (data['createdAt'] as Timestamp).toDate()),
                    time: DateFormat('HH:mm').format(
                        (data['createdAt'] as Timestamp).toDate()),
                    imageUrls:
                    List<String>.from(data['imageUrls'] ?? []),
                  );
                  return ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.contents, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                FreePostDetailPage(post: post))),
                  );
                } else {
                  final post = GroupBuyPost(
                    basePost: Post(
                      postId: doc.id,
                      authorUid: data['authorUid'] ?? '',
                      title: data['productName'] ?? '상품명 없음',
                      writer: data['authorNickname'] ?? '작성자 없음',
                      date: DateFormat('MM/dd').format(
                          (data['createdAt'] as Timestamp)
                              .toDate()),
                      time: DateFormat('HH:mm').format(
                          (data['createdAt'] as Timestamp)
                              .toDate()),
                      contents: data['content'] ?? '',
                    ),
                    itemUrl: data['productUrl'] ?? '',
                    itemImagePath: data['productImageUrl'] ?? '',
                    itemPrice: data['totalPrice'] ?? 0,
                    maxParticipants: data['maxParticipants'] ?? 1,
                    currentParticipants:
                    data['currentParticipants'] ?? 1,
                  );
                  return ListTile(
                    title: Text(post.basePost.title),
                    subtitle: Text(post.basePost.contents, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                GroupBuyPostDetailPage(post: post))),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
