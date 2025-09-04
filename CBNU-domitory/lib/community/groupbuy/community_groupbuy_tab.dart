import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/community/groupbuy/group_buy_create_page.dart';
import 'package:untitled/community/groupbuy/group_buy_detail_page.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:intl/intl.dart';

class GroupBuyPostTab extends StatefulWidget {
  const GroupBuyPostTab({super.key});

  @override
  State<GroupBuyPostTab> createState() => _GroupBuyPostTabState();
}

class _GroupBuyPostTabState extends State<GroupBuyPostTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      // 1. Firestore 데이터를 실시간으로 가져오기 위해 StreamBuilder 사용
      body: StreamBuilder<QuerySnapshot>(
        //group_buy_posts 컬렉션의 데이터를 createdAt 필드 기준 내림차순으로 정렬합니다.
        stream: FirebaseFirestore.instance
            .collection('group_buy_posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 2. 데이터 로딩 중일 때 로딩 아이콘을 보여줍니다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 3. 에러가 발생했을 때 에러 메시지를 보여줍니다.
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }
          // 4. 데이터가 없을 때 안내 메시지를 보여줍니다.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('등록된 게시글이 없습니다.'));
          }

          // 5. Firestore에서 가져온 문서 목록을 변수에 저장합니다.
          final posts = snapshot.data!.docs;

          // 6. ListView.builder를 사용해 게시글 목록을 효율적으로 만듭니다.
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDocument = posts[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                // 각 게시글 데이터를 카드 위젯에 전달합니다.
                child: GroupBuyPostCard(postDocument: postDocument),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupBuyCreatePage()));
        },
        backgroundColor: black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: white),
      ),
    );
  }
}

// 게시글 카드 위젯
class GroupBuyPostCard extends StatelessWidget {
  // Firestore 문서 자체를 데이터로 받도록 수정합니다.
  final DocumentSnapshot postDocument;
  const GroupBuyPostCard({super.key, required this.postDocument});

  @override
  Widget build(BuildContext context) {
    // 문서에서 데이터를 Map 형태로 추출합니다.
    final data = postDocument.data() as Map<String, dynamic>;

    // 필드별로 데이터를 추출하고, 값이 없을 경우 기본값을 사용합니다.
    final String productName = data['productName'] ?? '상품명 없음';
    final String imageUrl = data['productImageUrl'] ?? '';
    final int totalPrice = data['totalPrice'] ?? 0;
    final int maxParticipants = data['maxParticipants'] ?? 1;
    final int currentParticipants = data['currentParticipants'] ?? 1;

    // 상세 페이지로 데이터를 넘기기 위해 GroupBuyPost 객체를 생성합니다.
    final groupBuyPostForDetail = GroupBuyPost(
      basePost: Post(
        postId: postDocument.id,
        authorUid: data['authorUid'] ?? '',
        title: productName,
        writer: data['authorNickname'] ?? '작성자 없음',
        date: DateFormat('MM/dd').format((data['createdAt'] as Timestamp).toDate()),
        time: DateFormat('HH:mm').format((data['createdAt'] as Timestamp).toDate()),
        contents: data['content'] ?? '',
      ),
      itemUrl: data['productUrl'] ?? '',
      itemImagePath: imageUrl,
      itemPrice: totalPrice,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
    );

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupBuyPostDetailPage(post: groupBuyPostForDetail)));
      },
      child: Card(
          color: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: const BorderSide(color: grey_seperating_line, width: 1.0)),
          elevation: 0,
          child: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 16.w, top: 14.h, bottom: 14.h),
              child: Row(
                  children: [
                    SizedBox(
                      width: 100.w,
                      height: 100.h,
                      // 인터넷 URL 이미지를 표시하기 위해 Image.network를 사용합니다.
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                      )
                          : Container( // 이미지가 없을 경우 회색 박스와 아이콘을 보여줍니다.
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(productName, style: mediumBlack14, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                            Text('${NumberFormat('#,###').format(totalPrice)}원', style: boldBlack16),
                            if (maxParticipants > 0)
                              Text('1인당 ${NumberFormat('#,###').format(totalPrice ~/ maxParticipants)}원', style: mediumGrey13),
                            SizedBox(height: 20.h),
                            Row(
                                children: [
                                  const Icon(Icons.person, color: grey_8, size: 20),
                                  SizedBox(width: 2.w),
                                  Text('$currentParticipants/$maxParticipants', style: mediumGrey13)
                                ]
                            )
                          ]
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }
}

