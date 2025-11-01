import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/grey_filled_text_field.dart';
import 'package:untitled/common/popup_dialog.dart';
import 'package:untitled/community/free/free_create_page.dart';
import 'package:untitled/community/report.dart';
import 'package:untitled/message/chatting_page.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:intl/intl.dart';

class FreePostDetailPage extends StatefulWidget {
  final Post post;
  const FreePostDetailPage({super.key, required this.post});

  @override
  State<FreePostDetailPage> createState() => _FreePostDetailPageState();
}

class _FreePostDetailPageState extends State<FreePostDetailPage> {
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

  // --- 1:1 쪽지 보내기 ---
  Future<void> _startDirectMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
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

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final currentUserNickname = currentUserDoc.data()?['nickname'] ?? '이름 없음';

    final otherUserUid = widget.post.authorUid;
    final otherUserNickname = widget.post.writer;

    // 나와 상대방의 UID를 정렬하여 고유한 채팅방 ID 생성
    List<String> participants = [currentUser.uid, otherUserUid];
    participants.sort();
    String chatRoomId = participants.join('_');

    // 채팅방 정보 설정 (없으면 생성, 있으면 업데이트)
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
      'type': 'free_board', // 쪽지 출처 타입 지정
      'participants': [currentUser.uid, otherUserUid],
      'participants_info': {
        currentUser.uid: currentUserNickname,
        otherUserUid: otherUserNickname,
      },
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 채팅 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChattingPage(
          chatRoomId: chatRoomId,
          otherUserId: otherUserUid,
          otherUserNickname: otherUserNickname,
        ),
      ),
    );
  }

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

    if (_commentController.text.trim().isEmpty) return;

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

      final postRef = FirebaseFirestore.instance
          .collection('free_posts')
          .doc(widget.post.postId);

      if (_replyingToCommentId == null) {
        await postRef.collection('comments').add(commentData);
      } else {
        await postRef
            .collection('comments')
            .doc(_replyingToCommentId)
            .collection('replies')
            .add(commentData);
      }

      _commentController.clear();
      _cancelReplying();
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

  void _startReplying(String commentId, String authorNickname) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToAuthorNickname = authorNickname;
    });
    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  void _cancelReplying() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorNickname = null;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _showDeleteConfirmationDialog(
      {required String title,
        required String content,
        required VoidCallback onDelete}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[Text(content)])),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
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

  Future<void> _deletePost() async {
    await _showDeleteConfirmationDialog(
      title: '게시글 삭제',
      content: '이 게시글을 정말 삭제하시겠습니까? 모든 댓글 정보가 함께 삭제되며, 되돌릴 수 없습니다.',
      onDelete: () async {
        try {
          final postRef = FirebaseFirestore.instance
              .collection('free_posts')
              .doc(widget.post.postId);
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

          if (mounted) Navigator.of(context).pop();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('게시글 삭제에 실패했습니다: $e')));
          }
        }
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    await _showDeleteConfirmationDialog(
      title: '댓글 삭제',
      content: '이 댓글과 모든 대댓글이 삭제됩니다. 정말 삭제하시겠습니까?',
      onDelete: () async {
        try {
          final postRef = FirebaseFirestore.instance
              .collection('free_posts')
              .doc(widget.post.postId);
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('댓글 삭제에 실패했습니다: $e')));
        }
      },
    );
  }

  Future<void> _deleteReply(String commentId, String replyId) async {
    await _showDeleteConfirmationDialog(
      title: '대댓글 삭제',
      content: '정말 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await FirebaseFirestore.instance
              .collection('free_posts')
              .doc(widget.post.postId)
              .collection('comments')
              .doc(commentId)
              .collection('replies')
              .doc(replyId)
              .delete();
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('대댓글 삭제에 실패했습니다: $e')));
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

    final postRef =
    FirebaseFirestore.instance.collection('free_posts').doc(widget.post.postId);

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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMyPost = currentUser?.uid == widget.post.authorUid;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
          backgroundColor: white,
          surfaceTintColor: white,
          title: Text('자유게시판', style: boldBlack16),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              color: white,
              icon: Icon(Icons.more_vert_rounded, color: black, size: 24),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateFreePost(existingPost: widget.post)));
                } else if (value == 'delete') {
                  _deletePost();
                } else if (value == 'dm') {
                  _startDirectMessage();
                } else if (value == 'report') {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ReportDialog(post: widget.post, postType: 'free_posts'),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];
                if (isMyPost) {
                  items.add(PopupMenuItem(
                      value: 'edit', child: Text('수정', style: mediumBlack16)));
                  items.add(PopupMenuItem(
                      value: 'delete', child: Text('삭제', style: mediumBlack16)));
                } else {
                  items.add(PopupMenuItem(
                      value: 'dm', child: Text('1:1 쪽지', style: mediumBlack16)));
                  items.add(PopupMenuItem(
                      value: 'report',
                      child: Text('신고하기', style: mediumBlack16)));
                }
                return items;
              },
              offset: const Offset(0, 56),
            ),
          ]),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(children: [
                                SizedBox(
                                    width: 36.w,
                                    height: 36.h,
                                    child: CircleAvatar(backgroundImage: AssetImage('assets/profile6.png'))),
                                SizedBox(width: 6.w),
                                Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(widget.post.writer,
                                          style: boldBlack14),
                                      Text(
                                          '${widget.post.date} ${widget.post.time}',
                                          style: mediumGrey13)
                                    ])
                              ]),
                              SizedBox(height: 16.h),
                              Text(widget.post.title, style: boldBlack16),
                              SizedBox(height: 4.h),
                              Text(widget.post.contents, style: mediumBlack14),
                              if (widget.post.imageUrls != null &&
                                  widget.post.imageUrls!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: widget.post.imageUrls!.length,
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          widget.post.imageUrls![index],
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              SizedBox(height: 24.h),
                              // --- 좋아요 버튼 및 카운트 ---
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('free_posts')
                                    .doc(widget.post.postId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  final data = snapshot.data!.data()
                                  as Map<String, dynamic>?;
                                  final likes = List<String>.from(
                                      data?['likes'] ?? []);
                                  final isLiked =
                                  likes.contains(currentUser?.uid);
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
                            ]),
                      ),
                      Container(
                          width: double.infinity,
                          height: 1.h,
                          color: grey_seperating_line),
                      SizedBox(height: 16.h),
                      ////////////////////////////// 댓글 //////////////////////////////////////////
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('free_posts')
                            .doc(widget.post.postId)
                            .collection('comments')
                            .orderBy('createdAt')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Row(
                                    children: [
                                      Text('댓글', style: boldBlack14),
                                      SizedBox(width: 4.w),
                                      Text('0', style: mediumGrey14)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Icon(Icons.comments_disabled_rounded,
                                    size: 56, color: grey_seperating_line),
                                SizedBox(height: 6.h),
                                Text('댓글이 없습니다.', style: mediumGrey14)
                              ],
                            );
                          }
                          final comments = snapshot.data!.docs;
                          return Column(
                            children: [
                              Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 18.w),
                                child: Row(children: [
                                  Text('댓글', style: boldBlack14),
                                  SizedBox(width: 4.w),
                                  FutureBuilder<int>(
                                    future: () async {
                                      int totalCount = comments.length;
                                      for (final commentDoc in comments) {
                                        final replySnapshot = await commentDoc
                                            .reference
                                            .collection('replies')
                                            .count()
                                            .get();
                                        totalCount += replySnapshot.count ?? 0;
                                      }
                                      return totalCount;
                                    }(),
                                    builder: (context, countSnapshot) {
                                      return Text(
                                          '${countSnapshot.data ?? comments.length}',
                                          style: mediumGrey14);
                                    },
                                  )
                                ]),
                              ),
                              ListView.separated(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return CommentsItem(
                                    commentDoc: comments[index],
                                    isStudent: _isStudent,
                                    postId: widget.post.postId,
                                    onReply: _startReplying,
                                    onDelete: _deleteComment,
                                    onDeleteReply: _deleteReply,
                                  );
                                },
                                separatorBuilder: (context, index) => Divider(
                                    height: 1, color: grey_seperating_line),
                              ),
                            ],
                          );
                        },
                      )
                    ]),
              ),
            ),
            //if (_isStudent)
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
                            child: Icon(Icons.close, size: 16, color: grey))
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
                          borderRadius: BorderRadius.circular(18.0),
                          onTap: _isStudent
                              ? (_isRegisteringComment ? null : _submitComment)
                              : () {
                            showDialog(
                                context: context,
                                builder: (context) => PopupDialog(),
                                barrierDismissible: false);
                          },
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
                                            color: white, strokeWidth: 2))
                                        : const Icon(Icons.send_rounded,
                                        color: white, size: 28))),
                          ))
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsItem extends StatelessWidget {
  final bool isStudent;
  final DocumentSnapshot commentDoc;
  final String postId;
  final Function(String, String) onReply;
  final Function(String) onDelete;
  final Function(String, String) onDeleteReply;
  const CommentsItem(
      {super.key,
        required this.isStudent,
        required this.commentDoc,
        required this.postId,
        required this.onReply,
        required this.onDelete,
        required this.onDeleteReply});

  @override
  Widget build(BuildContext context) {
    final data = commentDoc.data() as Map<String, dynamic>;
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
                    child: CircleAvatar(backgroundImage: AssetImage('assets/profile7.png'))),
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
                            value: 'delete', child: Text('삭제')),
                      ],
                    ),
                  ),
              ]),
              SizedBox(height: 8.h),
              Padding(
                  padding: EdgeInsets.only(left: 36.w),
                  child: Text(data['contents'], style: mediumBlack14)),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    isStudent
                        ? onReply(commentDoc.id, authorNickname)
                        : showDialog(
                        context: context,
                        builder: (context) => PopupDialog(),
                        barrierDismissible: false);
                  },
                  child: Text('답글 달기', style: mediumGrey13),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: commentDoc.reference
                    .collection('replies')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(left: 24.w, top: 8.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return SubCommentItem(
                          replyDoc: snapshot.data!.docs[index],
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
                          child: CircleAvatar(backgroundImage: AssetImage('assets/profile7.png'))),
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
                                  value: 'delete', child: Text('삭제')),
                            ],
                          ),
                        ),
                    ]),
                    SizedBox(height: 8.h),
                    Padding(
                        padding: EdgeInsets.only(left: 36.w),
                        child: Text(data['contents'], style: mediumBlack14))
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

