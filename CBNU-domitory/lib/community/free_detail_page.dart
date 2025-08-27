import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/models/comment.dart';
import 'dart:math';
import 'package:untitled/common/grey_filled_text_field.dart';

class FreePostDetailPage extends StatefulWidget {
  final Post post;
  FreePostDetailPage({super.key, required this.post});

  @override
  State<FreePostDetailPage> createState() => _FreePostDetailPageState();
}

class _FreePostDetailPageState extends State<FreePostDetailPage> {
  final _commentController = TextEditingController();
  final bool _isCommentsEmpty = false;
  final List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();

    final Comment subCommentExample = Comment(postId: widget.post.postId, commentId: 800, userId: '대댓글 예시~~', contents: '가나다라', dateTime: getRandomPastTime(daysBack: 30), subComments: []);

    _comments.add(Comment(postId: widget.post.postId, commentId: 777, userId: '피카츄', contents: '가나다라', dateTime: getRandomPastTime(daysBack: 1), subComments: [subCommentExample, subCommentExample, subCommentExample]));
    _comments.add(Comment(postId: widget.post.postId, commentId: 778, userId: '라이츄', contents: '마바사', dateTime: getRandomPastTime(daysBack: 7), subComments: [subCommentExample]));
    _comments.add(Comment(postId: widget.post.postId, commentId: 779, userId: '파이리', contents: '아자차카', dateTime: getRandomPastTime(daysBack: 30), subComments: []));
    _comments.add(Comment(postId: widget.post.postId, commentId: 780, userId: '꼬북이', contents: '타파하', dateTime: getRandomPastTime(daysBack: 365), subComments: []));
    _comments.add(Comment(postId: widget.post.postId, commentId: 781, userId: '버터플', contents: '가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라', dateTime: getRandomPastTime(daysBack: 365), subComments: []));
    _comments.add(Comment(postId: widget.post.postId, commentId: 782, userId: '야도란', contents: '가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라가나다라', dateTime: getRandomPastTime(daysBack: 365), subComments: []));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        title: Text('자유게시판', style: boldBlack16),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: black, size: 24),
            onPressed: () {
              print('more button clicked!');
            }
          )
        ]
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                              children: [
                                SizedBox(
                                    width: 36.w,
                                    height: 36.w,
                                    child: Image.asset('assets/profile_man.png')
                                ),
                                SizedBox(width: 6.w),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(widget.post.writer, style: boldBlack14),
                                      Text('${widget.post.date} ${widget.post.time}', style: mediumGrey13)
                                    ]
                                )
                              ]
                          ),
                          SizedBox(height: 16.h),
                          Text(widget.post.title, style: boldBlack16),
                          SizedBox(height: 4.h),
                          Text(widget.post.contents, style: mediumBlack14),
                          SizedBox(height: 24.h),
                        ]
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1.h,
                      color: grey_seperating_line
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Text('댓글', style: boldBlack14),
                          SizedBox(width: 4.w),
                          Text('${_comments.length}', style: mediumGrey14)
                        ]
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      child: _isCommentsEmpty? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.comments_disabled_rounded, size: 56, color: grey_seperating_line),
                          SizedBox(height: 6.h),
                          Text('댓글이 없습니다.', style: mediumGrey14)
                        ]
                      ) : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index){
                          final comment = _comments[index];
                          return CommentsItem(comment: comment);
                        },
                        separatorBuilder: (context, index) => Divider(height: 1, color: grey_seperating_line),
                      )
                    )
                  ]
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h, top: 10.h),
                child: Row(
                    children: [
                      Expanded(
                          child: GreyFilledTextField(controller: _commentController, name: '댓글을 입력하세요', inputType: TextInputType.visiblePassword)
                      ),
                      SizedBox(width: 4.w),
                      InkWell(
                          onTap: () {
                            if(_commentController.text.isNotEmpty) {
                              setState(() {
                                _comments.add(Comment(postId: widget.post.postId, commentId: _comments.length+1, userId: '사자', contents: _commentController.text, dateTime: DateTime.now(), subComments: []));
                              });
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(color: black, borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                  child: Icon(
                                      Icons.send_rounded,
                                      color: white,
                                      size: 28
                                  )
                              )
                          )
                      )
                    ]
                )
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsItem extends StatelessWidget {
  final Comment comment;
  CommentsItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28.w,
                height: 28.h,
                child: Image.asset('assets/profile_man.png')
              ),
              SizedBox(width: 8.w),
              Text(comment.userId, style: boldBlack14),
              SizedBox(width: 8.w),
              Text(getTimeAgo(comment.dateTime), style: mediumGrey14)
            ]
          ),
          SizedBox(height: 8.h),
          Text(comment.contents, style: mediumBlack14),
          SizedBox(height: 4.h),
          if(comment.subComments.isNotEmpty)
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: comment.subComments.map((subComment) => SubCommentItem(comment: subComment)).toList()
            )
        ]
      )
    );
  }
}

class SubCommentItem extends StatelessWidget {
  final Comment comment;
  SubCommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 4.h, left: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  children: [
                    SizedBox(
                        width: 28.w,
                        height: 28.h,
                        child: Image.asset('assets/profile_man.png')
                    ),
                    SizedBox(width: 8.w),
                    Text(comment.userId, style: boldBlack14),
                    SizedBox(width: 8.w),
                    Text(getTimeAgo(comment.dateTime), style: mediumGrey14)
                  ]
              ),
              SizedBox(height: 8.h),
              Text(comment.contents, style: mediumBlack14)
            ]
          )
        )
      ),
    );
  }
}



String getTimeAgo(DateTime dateTime) {
  Duration diff = DateTime.now().difference(dateTime);

  if(diff.inMinutes<1){
    return '방금 전';
  } else if(diff.inMinutes<60) {
    return '${diff.inMinutes}분 전';
  } else if(diff.inHours<24) {
    return '${diff.inHours}시간 전';
  } else if(diff.inDays<14) {
    return '${diff.inDays}일 전';
  } else {
    return "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}";
  }
}

DateTime getRandomPastTime({int daysBack = 7}) {
  final random = Random();
  final now = DateTime.now();

  int maxSeconds = daysBack * 24 * 60 * 60;
  int randomSeconds = random.nextInt(maxSeconds);

  return now.subtract(Duration(seconds: randomSeconds));
}
