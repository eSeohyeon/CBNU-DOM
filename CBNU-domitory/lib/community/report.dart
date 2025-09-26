import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/models/post.dart';
import 'package:untitled/themes/styles.dart';

class ReportDialog extends StatefulWidget {
  final Post post;
  final String postType; // 'free_posts' or 'group_buy_posts'

  const ReportDialog({super.key, required this.post, required this.postType});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _additionalCommentController = TextEditingController();
  bool _isLoading = false;

  final Map<String, bool> _reportReasons = {
    '스팸홍보/도배글입니다.': false,
    '음란물입니다.': false,
    '불법정보를 포함하고 있습니다.': false,
    '욕설/생명경시/혐오/차별적 표현입니다.': false,
    '불쾌한 표현이 있습니다.': false,
    '개인정보 노출 게시물입니다.': false,
  };

  Future<void> _submitReport() async {
    final selectedReasons = _reportReasons.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedReasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 사유를 하나 이상 선택해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final reporterNickname = userDoc.data()?['nickname'] ?? '이름 없음';

      await FirebaseFirestore.instance.collection('reports').add({
        'reporterUid': currentUser.uid,
        'reporterNickname': reporterNickname,
        'reportedPostId': widget.post.postId,
        'reportedPostType': widget.postType,
        'reportedPostTitle': widget.post.title,
        'reportedPostContent': widget.post.contents,
        'reportedUserUid': widget.post.authorUid,
        'reportedUserNickname': widget.post.writer,
        'reportReasons': selectedReasons,
        'additionalComment': _additionalCommentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 성공적으로 접수되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신고 접수에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _additionalCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('게시물 신고'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._reportReasons.keys.map((reason) {
                return CheckboxListTile(
                  title: Text(reason, style: mediumBlack14),
                  value: _reportReasons[reason],
                  onChanged: (bool? value) {
                    setState(() {
                      _reportReasons[reason] = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
              SizedBox(height: 16.h),
              Text('추가 설명 (선택)', style: mediumBlack16),
              SizedBox(height: 8.h),
              TextField(
                controller: _additionalCommentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '자세한 내용을 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitReport,
          child: _isLoading
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('신고하기'),
        ),
      ],
    );
  }
}
