import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/popup_dialog.dart';
import 'package:untitled/message/chatting_page.dart';
import 'package:untitled/models/post.dart';

class GroupChatService {
  static Future<void> joinGroupChatAndNavigate({
    required BuildContext context,
    required GroupBuyPost post,
    required bool isStudent,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }
    if (!isStudent) {
      showDialog(
          context: context,
          builder: (context) => const PopupDialog(),
          barrierDismissible: false);
      return;
    }

    // 게시글 ID를 단체 채팅방의 고유 ID로 사용
    final String chatRoomId = post.basePost.postId;
    final DocumentReference chatRoomRef =
    FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
    final DocumentReference postRef =
    FirebaseFirestore.instance.collection('group_buy_posts').doc(chatRoomId);

    try {
      // 현재 사용자의 닉네임 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final String currentUserNickname = userDoc.data()?['nickname'] ?? '이름 없음';

      // 트랜잭션을 사용하여 채팅방 생성 및 사용자 추가를 안전하게 처리
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot chatSnapshot = await transaction.get(chatRoomRef);

        if (!chatSnapshot.exists) {
          // 채팅방이 없으면 새로 생성 (작성자와 현재 사용자 포함)
          transaction.set(chatRoomRef, {
            'type': 'group_buy',
            'groupTitle': post.basePost.title, // 상품명으로 채팅방 제목 설정
            'groupImageUrl': post.itemImagePath, //상품 이미지 가져오기
            'participants': [post.basePost.authorUid, currentUser.uid],
            'participants_info': {
              post.basePost.authorUid: post.basePost.writer,
              currentUser.uid: currentUserNickname,
            },
            'lastMessage': '채팅방이 개설되었습니다.',
            'lastMessageTimestamp': FieldValue.serverTimestamp(),
          });
        } else {
          // 채팅방이 이미 있으면 현재 사용자를 참여자 목록에 추가
          transaction.update(chatRoomRef, {
            'participants': FieldValue.arrayUnion([currentUser.uid]),
            'participants_info.${currentUser.uid}': currentUserNickname,
          });
        }
      });

      // 참여 성공 후, 게시물의 참여 인원 수를 업데이트
      final updatedChatDoc = await chatRoomRef.get();
      if (updatedChatDoc.exists) {
        final data = updatedChatDoc.data() as Map<String, dynamic>;
        final participants =
        List<String>.from(data['participants'] ?? []);
        await postRef.update({'currentParticipants': participants.length});
      }

      // 채팅 페이지로 이동
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context); // 확인 다이얼로그 닫기
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChattingPage(
            chatRoomId: chatRoomId,
            otherUserNickname: post.basePost.title, // 그룹 채팅 이름으로 게시글 제목 사용
            otherUserId: '', // 단체 채팅에서는 특정 상대방 ID가 불필요
          ),
        ),
      );
    } catch (e) {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅 참여에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }
}

