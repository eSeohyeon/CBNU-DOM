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
      backgroundColor: white,
      // 1. Firestore 데이터를 실시간으로 가져오기 위해 StreamBuilder 사용
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('group_buy_posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('등록된 게시글이 없습니다.'));
          }
          final posts = snapshot.data!.docs;

          return ListView.separated(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDocument = posts[index];
              return GroupBuyPostCard(postDocument: postDocument);
            },
            separatorBuilder: (context, index) => Divider(height: 1, color: grey_seperating_line),
          );
        },
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupBuyCreatePage()));
        },
        backgroundColor: black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: white),
      ),*/
    );
  }
}

// 게시글 카드 위젯
class GroupBuyPostCard extends StatelessWidget {
  final DocumentSnapshot postDocument;
  const GroupBuyPostCard({super.key, required this.postDocument});

  @override
  Widget build(BuildContext context) {
    final data = postDocument.data() as Map<String, dynamic>;
    final String productName = data['productName'] ?? '상품명 없음';
    final String imageUrl = data['productImageUrl'] ?? '';
    final int totalPrice = data['totalPrice'] ?? 0;
    final int maxParticipants = data['maxParticipants'] ?? 1;
    final int currentParticipants = data['currentParticipants'] ?? 1;
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
      child: Container(
          color: white,
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: const BorderSide(color: grey_seperating_line, width: 1.0)),
          child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 20.w, top: 16.h, bottom: 16.h),
              child: Row(
                  children: [
                    SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                      )
                          : Container(
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
                            SizedBox(height: 1.h),
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

