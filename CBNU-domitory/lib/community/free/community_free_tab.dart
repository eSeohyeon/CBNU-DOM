import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/community/free/free_detail_page.dart';


// 자유게시판 탭
class FreePostTab extends StatefulWidget {
  const FreePostTab({super.key});

  @override
  State<FreePostTab> createState() => _FreePostTabState();
}

class _FreePostTabState extends State<FreePostTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // free_posts 컬렉션의 문서를 createdAt 필드 기준으로 최신순으로 정렬
      stream: FirebaseFirestore.instance
          .collection('free_posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('작성된 게시글이 없습니다.'));
        }

        final posts = snapshot.data!.docs;

        return Container(
          color: white,
          child: ListView.separated(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDocument = posts[index];
              return FreePostListItem(postDocument: postDocument);
            },
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: grey_seperating_line),
          ),
        );
      },
    );
  }
}

class FreePostListItem extends StatelessWidget {
  final DocumentSnapshot postDocument;
  const FreePostListItem({super.key, required this.postDocument});

  @override
  Widget build(BuildContext context) {
    final data = postDocument.data() as Map<String, dynamic>;

    // Firestore 데이터를 Post 객체로 변환합니다.
    final post = Post(
      postId: postDocument.id,
      authorUid: data['authorUid'] ?? '',
      title: data['title'] ?? '제목 없음',
      contents: data['contents'] ?? '',
      writer: data['authorNickname'] ?? '작성자 없음',
      date: DateFormat('MM/dd').format((data['createdAt'] as Timestamp).toDate()),
      time: DateFormat('HH:mm').format((data['createdAt'] as Timestamp).toDate()),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreePostDetailPage(post: post),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: boldBlack16, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 1.h),
                  Text(post.contents, style: mediumBlack14, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(post.time, style: mediumGrey13),
                      SizedBox(width: 10.w),
                      Text('|', style: mediumGrey13),
                      SizedBox(width: 10.w),
                      Text(post.writer, style: mediumGrey13),
                    ],
                  ),
                ],
              ),
            ),
            if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    post.imageUrls!.first,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 70.w,
                        height: 70.h,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70.w,
                        height: 70.h,
                        color: Colors.grey[200],
                        child: Icon(Icons.error_outline, color: grey),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

