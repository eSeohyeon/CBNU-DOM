import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/grey_filled_text_field.dart';
import 'package:untitled/common/popup_dialog.dart';
import 'package:untitled/community/groupbuy/group_buy_create_page.dart';
import 'package:untitled/community/report.dart';
import 'package:untitled/message/chatting_page.dart';
import 'package:untitled/message/group_chat.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupBuyPostDetailPage extends StatefulWidget {
  final GroupBuyPost post;
  const GroupBuyPostDetailPage({super.key, required this.post});

  @override
  State<GroupBuyPostDetailPage> createState() => _GroupBuyPostDetailPageState();
}

class _GroupBuyPostDetailPageState extends State<GroupBuyPostDetailPage> {
  final _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isRegisteringComment = false;
  bool _isStudent = false;

  String? _replyingToCommentId;
  String? _replyingToAuthorNickname;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'];
      if (mounted && role == '재학생') {
        setState(() {
          _isStudent = true;
        });
      }
    } catch (e) {
      print("Error checking user role: $e");
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // --- 댓글 또는 대댓글 추가 함수 ---
  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 작성하려면 로그인이 필요합니다.')),
      );
      return;
    }

    if (!_isStudent) {
      showDialog(
        context: context,
        builder: (context) => const PopupDialog(),
        barrierDismissible: false,
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isRegisteringComment = true);

    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final nickname = userDoc.data()?['nickname'] ?? '이름 없음';
      final commentData = {
        'contents': _commentController.text.trim(),
        'authorUid': user.uid,
        'authorNickname': nickname,
        'createdAt': Timestamp.now(),
      };

      if (_replyingToCommentId == null) {
        // 일반 댓글 추가
        await FirebaseFirestore.instance
            .collection('group_buy_posts')
            .doc(widget.post.basePost.postId)
            .collection('comments')
            .add(commentData);
      } else {
        // 대댓글 추가
        await FirebaseFirestore.instance
            .collection('group_buy_posts')
            .doc(widget.post.basePost.postId)
            .collection('comments')
            .doc(_replyingToCommentId)
            .collection('replies')
            .add(commentData);
      }

      _commentController.clear();
      _cancelReplying(); // 입력창 상태 초기화
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 등록에 실패했습니다: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isRegisteringComment = false);
      }
    }
  }

  // 대댓글 작성을 시작하는 함수
  void _startReplying(String commentId, String authorNickname) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToAuthorNickname = authorNickname;
    });
    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  // 대댓글 작성을 취소하는 함수
  void _cancelReplying() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorNickname = null;
    });
    FocusScope.of(context).unfocus();
  }

  // --- 삭제 확인 다이얼로그 ---
  Future<void> _showDeleteConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onDelete,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- 게시글 삭제 함수 ---
  Future<void> _deletePost() async {
    await _showDeleteConfirmationDialog(
      title: '게시글 삭제',
      content:
      '이 게시글을 정말 삭제하시겠습니까? 모든 댓글과 참여 정보가 함께 삭제되며, 되돌릴 수 없습니다.',
      onDelete: () async {
        try {
          final postRef = FirebaseFirestore.instance
              .collection('group_buy_posts')
              .doc(widget.post.basePost.postId);

          final commentsSnapshot = await postRef.collection('comments').get();
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (final commentDoc in commentsSnapshot.docs) {
            final repliesSnapshot =
            await commentDoc.reference.collection('replies').get();
            for (final replyDoc in repliesSnapshot.docs) {
              batch.delete(replyDoc.reference);
            }
            batch.delete(commentDoc.reference);
          }
          await batch.commit();

          await postRef.delete();

          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('게시글 삭제에 실패했습니다: $e')),
            );
          }
        }
      },
    );
  }

  // --- 댓글 삭제 함수 ---
  Future<void> _deleteComment(String commentId) async {
    await _showDeleteConfirmationDialog(
      title: '댓글 삭제',
      content: '이 댓글과 모든 대댓글이 삭제됩니다. 정말 삭제하시겠습니까?',
      onDelete: () async {
        try {
          final postRef = FirebaseFirestore.instance
              .collection('group_buy_posts')
              .doc(widget.post.basePost.postId);

          final repliesSnapshot = await postRef
              .collection('comments')
              .doc(commentId)
              .collection('replies')
              .get();
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (var doc in repliesSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();

          await postRef.collection('comments').doc(commentId).delete();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('댓글 삭제에 실패했습니다: $e')),
          );
        }
      },
    );
  }

  // --- 대댓글 삭제 함수 ---
  Future<void> _deleteReply(String commentId, String replyId) async {
    await _showDeleteConfirmationDialog(
      title: '대댓글 삭제',
      content: '정말 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await FirebaseFirestore.instance
              .collection('group_buy_posts')
              .doc(widget.post.basePost.postId)
              .collection('comments')
              .doc(commentId)
              .collection('replies')
              .doc(replyId)
              .delete();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('대댓글 삭제에 실패했습니다: $e')),
          );
        }
      },
    );
  }

  // --- 좋아요 기능 ---
  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }
    if (!_isStudent) {
      showDialog(
          context: context,
          builder: (context) => const PopupDialog(),
          barrierDismissible: false);
      return;
    }

    final postRef = FirebaseFirestore.instance
        .collection('group_buy_posts')
        .doc(widget.post.basePost.postId);

    try {
      final DocumentSnapshot postDoc = await postRef.get();
      final postData = postDoc.data() as Map<String, dynamic>?;
      final List<String> likes =
      List<String>.from(postData?['likes'] ?? []);

      if (likes.contains(user.uid)) {
        // 좋아요 취소
        await postRef.update({
          'likes': FieldValue.arrayRemove([user.uid]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // 좋아요
        await postRef.update({
          'likes': FieldValue.arrayUnion([user.uid]),
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('좋아요 처리에 실패했습니다: $e')));
    }
  }

  // --- URL 실행 함수 ---
  Future<void> _launchUrl(String urlString) async {
    String formattedUrl = urlString;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      formattedUrl = 'https://$urlString';
    }

    final Uri url = Uri.parse(formattedUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('링크를 열 수 없습니다: $formattedUrl')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final isMyPost = currentUserUid == widget.post.basePost.authorUid;

    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
            backgroundColor: white,
            surfaceTintColor: white,
            title: Text('공동구매 게시판', style: boldBlack16),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: black, size: 24),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GroupBuyCreatePage(existingPost: widget.post)));
                  } else if (value == 'delete') {
                    _deletePost();
                  } else if (value == 'report') {
                    showDialog(
                      context: context,
                      builder: (context) => ReportDialog(
                          post: widget.post.basePost,
                          postType: 'group_buy_posts'),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry<String>> items = [];
                  if (isMyPost) {
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('수정'),
                      ),
                    );
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    );
                  } else {
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Text('신고하기'),
                      ),
                    );
                  }
                  return items;
                },
              ),
            ]),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            // 게시글 내용
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10.h),
                              child: Column(children: [
                                Row(children: [
                                  SizedBox(
                                      width: 36.w,
                                      height: 36.h,
                                      child: CircleAvatar(backgroundImage: AssetImage('assets/profile7.png'))),
                                  SizedBox(width: 6.w),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(widget.post.basePost.writer,
                                            style: boldBlack14),
                                        Text(
                                            '${widget.post.basePost.date} ${widget.post.basePost.time}',
                                            style: mediumGrey13)
                                      ])
                                ]),
                                SizedBox(height: 10.h),
                                Container(
                                  width: 200.w,
                                  height: 200.h,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: widget.post.itemImagePath.isNotEmpty
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      widget.post.itemImagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                    ),
                                  )
                                      : Icon(Icons.image_not_supported,
                                      color: Colors.grey[400]),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(widget.post.basePost.title,
                                                  style: mediumBlack16),
                                              Text(
                                                  '${NumberFormat('#,###').format(widget.post.itemPrice)}원',
                                                  style: boldBlack18),
                                              if (widget.post.maxParticipants > 0)
                                                Text(
                                                    '1인당 ${NumberFormat('#,###').format(widget.post.itemPrice ~/ widget.post.maxParticipants)}원',
                                                    style: mediumGrey14),
                                              SizedBox(height: 10.h),
                                              Row(children: [
                                                const Icon(Icons.person,
                                                    color: grey, size: 20),
                                                SizedBox(width: 4.w),
                                                Text(
                                                    '${widget.post.currentParticipants}/${widget.post.maxParticipants}',
                                                    style: mediumGrey14),
                                              ]),
                                            ]),
                                      ),
                                      Row(
                                        children: [
                                          if (widget.post.itemUrl.isNotEmpty)
                                            Container(
                                                width: 36.w,
                                                height: 36.h,
                                                decoration: BoxDecoration(
                                                    color: grey_seperating_line,
                                                    borderRadius:
                                                    BorderRadius.circular(15)),
                                                child: IconButton(
                                                    icon: const Icon(
                                                        Icons.open_in_new_rounded,
                                                        color: black,
                                                        size: 24),
                                                    onPressed: () =>
                                                        _launchUrl(widget.post.itemUrl))),
                                          SizedBox(width: 6.w),
                                          Container(
                                              width: 36.w,
                                              height: 35.h,
                                              decoration: BoxDecoration(
                                                  color: isMyPost
                                                      ? grey_button_greyBG
                                                      : (_isStudent
                                                      ? black
                                                      : black40),
                                                  borderRadius:
                                                  BorderRadius.circular(15)),
                                              child: IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .chat_bubble_outline_rounded,
                                                      color: white,
                                                      size: 24),
                                                  onPressed: isMyPost
                                                      ? null
                                                      : () {
                                                    _isStudent
                                                        ? showDialog(
                                                        context: context,
                                                        builder:
                                                            (context) =>
                                                            AlertDialog(
                                                              backgroundColor:
                                                              white,
                                                              content:
                                                              Container(
                                                                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
                                                                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10.0)),
                                                                child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text('공동구매 채팅에\n참여하시겠습니까?', style: boldBlack16, textAlign: TextAlign.center),
                                                                      SizedBox(height: 16.h),
                                                                      Column(mainAxisSize: MainAxisSize.min, children: [
                                                                        SizedBox(
                                                                          width: double.infinity,
                                                                          child: ElevatedButton(
                                                                              onPressed: () => GroupChatService.joinGroupChatAndNavigate(
                                                                                context: context,
                                                                                post: widget.post,
                                                                                isStudent: _isStudent,
                                                                              ),
                                                                              child: Text('참여하기', style: mediumWhite14),
                                                                              style: ElevatedButton.styleFrom(
                                                                                  elevation: 0,
                                                                                  backgroundColor: black,
                                                                                  overlayColor: Colors.transparent,
                                                                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)))),
                                                                        ),
                                                                        SizedBox(height: 8.h),
                                                                        SizedBox(
                                                                          width: double.infinity,
                                                                          child: ElevatedButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Text('닫기', style: mediumBlack14),
                                                                              style: ElevatedButton.styleFrom(
                                                                                  elevation: 0,
                                                                                  backgroundColor: grey_button,
                                                                                  overlayColor: Colors.transparent,
                                                                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)))),
                                                                        )
                                                                      ])
                                                                    ]),
                                                              ),
                                                            ))
                                                        : showDialog(
                                                        context: context,
                                                        builder:
                                                            (context) =>
                                                            PopupDialog(),
                                                        barrierDismissible:
                                                        false);
                                                  })),
                                        ],
                                      ),
                                    ]),
                                SizedBox(height: 24.h),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(widget.post.basePost.contents,
                                      style: mediumBlack14),
                                ),
                                SizedBox(height: 24.h),
                                // --- 좋아요 버튼 및 카운트 ---
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('group_buy_posts')
                                      .doc(widget.post.basePost.postId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }
                                    final data = snapshot.data!.data()
                                    as Map<String, dynamic>?;
                                    final likes =
                                    List<String>.from(data?['likes'] ?? []);
                                    final isLiked =
                                    likes.contains(currentUserUid);
                                    final likeCount = data?['likeCount'] ?? 0;

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked ? Colors.red : grey,
                                          ),
                                          onPressed: _toggleLike,
                                        ),
                                        Text('$likeCount'),
                                      ],
                                    );
                                  },
                                )
                              ])),
                          Container(
                            // 구분선
                              width: double.infinity,
                              height: 1.h,
                              color: grey_seperating_line),
                          SizedBox(height: 16.h),
                          // --- 댓글 섹션 ---
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('group_buy_posts')
                                .doc(widget.post.basePost.postId)
                                .collection('comments')
                                .orderBy('createdAt', descending: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ));
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('댓글을 불러오는데 실패했습니다.'));
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 18.w),
                                        child: Row(children: [
                                          Text('댓글', style: boldBlack14),
                                          SizedBox(width: 4.w),
                                          Text('0', style: mediumGrey14)
                                        ]),
                                      ),
                                      SizedBox(height: 20.h),
                                      Icon(Icons.comments_disabled_rounded,
                                          size: 56, color: grey_seperating_line),
                                      SizedBox(height: 6.h),
                                      Text('댓글이 없습니다.', style: mediumGrey14),
                                    ],
                                  ),
                                );
                              }

                              final comments = snapshot.data!.docs;

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                      child: Row(
                                        children: [
                                          Text('댓글', style: boldBlack14),
                                          SizedBox(width: 4.w),
                                          FutureBuilder<int>(
                                            future: () async {
                                              int totalCount = comments.length;
                                              for (final commentDoc in comments) {
                                                final replySnapshot =
                                                await FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                    'group_buy_posts')
                                                    .doc(widget.post.basePost
                                                    .postId)
                                                    .collection('comments')
                                                    .doc(commentDoc.id)
                                                    .collection('replies')
                                                    .count()
                                                    .get();
                                                totalCount +=
                                                    replySnapshot.count ?? 0;
                                              }
                                              return totalCount;
                                            }(),
                                            builder: (context, countSnapshot) {
                                              if (countSnapshot.connectionState ==
                                                  ConnectionState.waiting ||
                                                  !countSnapshot.hasData ||
                                                  countSnapshot.hasError) {
                                                return Text('${comments.length}',
                                                    style: mediumGrey14);
                                              }
                                              return Text('${countSnapshot.data}',
                                                  style: mediumGrey14);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        final commentDoc = comments[index];
                                        return CommentsItem(
                                          commentDoc: commentDoc,
                                          postId: widget.post.basePost.postId,
                                          onReply: _startReplying,
                                          onDelete: _deleteComment,
                                          onDeleteReply: _deleteReply,
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                              height: 1,
                                              color: grey_seperating_line),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ])),
              ),
              // --- 댓글 입력창 ---
              Column(
                children: [
                  if (_replyingToCommentId != null)
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "'@${_replyingToAuthorNickname ?? ''}'님에게 답글 남기는 중...",
                              style: mediumGrey13),
                          InkWell(
                            onTap: _cancelReplying,
                            child: Icon(Icons.close, size: 16, color: grey),
                          )
                        ],
                      ),
                    ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 16.w, right: 16.w, bottom: 10.h, top: 10.h),
                      child: Row(children: [
                        Expanded(
                            child: GreyFilledTextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                name: _isStudent
                                    ? '댓글을 입력하세요'
                                    : '재학생 인증이 필요합니다',
                                inputType: TextInputType.text)),
                        SizedBox(width: 4.w),
                        InkWell(
                            onTap: _isStudent
                                ? _isRegisteringComment
                                ? null
                                : _submitComment
                                : () {
                              showDialog(
                                  context: context,
                                  builder: (context) => PopupDialog(),
                                  barrierDismissible: false);
                            },
                            borderRadius: BorderRadius.circular(18.0),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: _isStudent ? black : black40,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 8.h),
                                      child: _isRegisteringComment
                                          ? const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                              color: white,
                                              strokeWidth: 2))
                                          : const Icon(Icons.send_rounded,
                                          color: white, size: 28))),
                            ))
                      ])),
                ],
              )
            ],
          ),
        ));
  }
}

class CommentsItem extends StatelessWidget {
  final DocumentSnapshot commentDoc;
  final String postId;
  final Function(String, String) onReply;
  final Function(String) onDelete;
  final Function(String, String) onDeleteReply;
  const CommentsItem({
    super.key,
    required this.commentDoc,
    required this.postId,
    required this.onReply,
    required this.onDelete,
    required this.onDeleteReply,
  });

  @override
  Widget build(BuildContext context) {
    final data = commentDoc.data() as Map<String, dynamic>;
    final contents = data['contents'] ?? '';
    final authorUid = data['authorUid'] ?? '';
    final authorNickname = data['authorNickname'] ?? '이름 없음';
    final timestamp = (data['createdAt'] as Timestamp).toDate();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                SizedBox(
                    width: 28.w,
                    height: 28.h,
                    child: CircleAvatar(backgroundImage: AssetImage('assets/profile7.png')) // TODO: 사용자 프로필 이미지로 교체
                ),
                SizedBox(width: 8.w),
                Text(authorNickname, style: boldBlack14),
                SizedBox(width: 8.w),
                Text(getTimeAgo(timestamp), style: mediumGrey14),
                const Spacer(),
                if (currentUserUid == authorUid)
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_vert, size: 16, color: grey),
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete(commentDoc.id);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('삭제'),
                        ),
                      ],
                    ),
                  ),
              ]),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 36.w),
                child: Text(contents, style: mediumBlack14),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => onReply(commentDoc.id, authorNickname),
                  child: Text('답글 달기', style: mediumGrey13),
                ),
              ),
              // --- 대댓글 목록 ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('group_buy_posts')
                    .doc(postId)
                    .collection('comments')
                    .doc(commentDoc.id)
                    .collection('replies')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final replies = snapshot.data!.docs;
                  return Padding(
                    padding: EdgeInsets.only(left: 24.w, top: 8.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: replies.length,
                      itemBuilder: (context, index) {
                        return SubCommentItem(
                          replyDoc: replies[index],
                          commentId: commentDoc.id,
                          onDelete: onDeleteReply,
                        );
                      },
                    ),
                  );
                },
              ),
            ]));
  }
}

// --- 대댓글을 표시 ---
class SubCommentItem extends StatelessWidget {
  final DocumentSnapshot replyDoc;
  final String commentId;
  final Function(String, String) onDelete;
  const SubCommentItem(
      {super.key,
        required this.replyDoc,
        required this.commentId,
        required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final data = replyDoc.data() as Map<String, dynamic>;
    final contents = data['contents'] ?? '';
    final authorUid = data['authorUid'] ?? '';
    final authorNickname = data['authorNickname'] ?? '이름 없음';
    final timestamp = (data['createdAt'] as Timestamp).toDate();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
      child: Container(
          decoration: BoxDecoration(
              color: background, borderRadius: BorderRadius.circular(10)),
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      SizedBox(
                          width: 28.w,
                          height: 28.h,
                          child: CircleAvatar(backgroundImage: AssetImage('assets/profile7.png')) // TODO: 사용자 프로필 이미지
                      ),
                      SizedBox(width: 8.w),
                      Text(authorNickname, style: boldBlack14),
                      SizedBox(width: 8.w),
                      Text(getTimeAgo(timestamp), style: mediumGrey14),
                      const Spacer(),
                      if (currentUserUid == authorUid)
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert, size: 16, color: grey),
                            onSelected: (value) {
                              if (value == 'delete') {
                                onDelete(commentId, replyDoc.id);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('삭제'),
                              ),
                            ],
                          ),
                        ),
                    ]),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 36.w),
                      child: Text(contents, style: mediumBlack14),
                    )
                  ]))),
    );
  }
}

String getTimeAgo(DateTime dateTime) {
  Duration diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) {
    return '방금 전';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}분 전';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}시간 전';
  } else if (diff.inDays < 14) {
    return '${diff.inDays}일 전';
  } else {
    return DateFormat('yy/MM/dd').format(dateTime);
  }
}

