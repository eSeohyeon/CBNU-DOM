import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:untitled/common/grey_filled_text_field.dart';
import 'package:untitled/models/chat_message.dart';

class ChattingPage extends StatefulWidget {
  final String chatRoomId;
  final String otherUserId;
  final String otherUserNickname;
  const ChattingPage({
    super.key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserNickname,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  late TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, String> _participantsInfo = {};
  bool _isLoadingParticipants = true;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _fetchParticipantsInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _fetchParticipantsInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.chatRoomId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final info = data['participants_info'] as Map<String, dynamic>? ?? {};
        setState(() {
          _participantsInfo =
              info.map((key, value) => MapEntry(key, value.toString()));
          _isLoadingParticipants = false;
        });
      }
    } catch (e) {
      print("Error fetching participants info: $e");
      setState(() {
        _isLoadingParticipants = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();
    _scrollToBottom();

    final messageData = {
      'senderId': _currentUserId,
      'content': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // 메시지 추가 및 채팅방 정보 업데이트
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add(messageData);
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.chatRoomId)
        .update({
      'lastMessage': messageText,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(widget.otherUserNickname, style: mediumBlack16),
        backgroundColor: white,
        surfaceTintColor: white,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: _isLoadingParticipants
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .doc(widget.chatRoomId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("메시지를 보내 대화를 시작해보세요."));
                  }

                  final messages = snapshot.data!.docs;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final doc = messages[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final senderId = data['senderId'] ?? '';
                        final senderNickname =
                            _participantsInfo[senderId] ?? '알 수 없음';

                        final messageItem = ChatMessage(
                          messageId: doc.id,
                          senderId: senderId,
                          content: data['content'] ?? '',
                          timestamp:
                          (data['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now(),
                          isMe: data['senderId'] == _currentUserId,
                        );

                        final previousDoc = index > 0
                            ? messages[index - 1].data()
                        as Map<String, dynamic>
                            : null;
                        final previousTimestamp =
                        (previousDoc?['timestamp'] as Timestamp?)
                            ?.toDate();
                        final bool showDateSeparator =
                            previousTimestamp == null ||
                                !isSameDay(messageItem.timestamp,
                                    previousTimestamp);

                        return Column(children: [
                          if (showDateSeparator)
                            _DateSeparator(date: messageItem.timestamp),
                          Padding(
                            padding:
                            EdgeInsets.symmetric(vertical: 8.h),
                            child: _MessageItem(
                                messageItem: messageItem,
                                senderNickname: senderNickname),
                          )
                        ]);
                      });
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: 16.w, right: 16.w, bottom: 24.h, top: 10.h),
                child: Row(children: [
                  Expanded(
                      child: GreyFilledTextField(
                          controller: _messageController,
                          name: '메시지 입력',
                          inputType: TextInputType.text)),
                  SizedBox(width: 4.w),
                  InkWell(
                      borderRadius: BorderRadius.circular(18.0),
                      onTap: _sendMessage,
                      child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: black,
                                  borderRadius: BorderRadius.circular(28)),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 8.h),
                                  child: Icon(Icons.keyboard_return_rounded,
                                      color: white, size: 28)))))
                ])),
          ],
        ),
      ),
    );
  }
}

// 날짜 구분선 위젯
class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: grey_button, borderRadius: BorderRadius.circular(25.0)),
        child:
        Text(DateFormat('MM/dd').format(date), style: mediumBlack14));
  }
}

// 두 DateTime 객체가 같은 날짜인지 확인하는 함수
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MessageItem extends StatelessWidget {
  final ChatMessage messageItem;
  final String senderNickname;
  const _MessageItem(
      {required this.messageItem, required this.senderNickname});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment:
          messageItem.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!messageItem.isMe) ...[
              CircleAvatar(
                radius: 20,
                backgroundColor: grey_button_greyBG,
                child: Image.asset('assets/profile_man.png'),
              ),
              SizedBox(width: 8.w),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(senderNickname, style: mediumBlack14),
                    SizedBox(height: 4.h),
                    _MessageBubble(messageItem: messageItem)
                  ])
            ] else ...[
              _MessageBubble(messageItem: messageItem)
            ]
          ],
        ));
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage messageItem;
  const _MessageBubble({required this.messageItem});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      messageItem.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (messageItem.isMe) ...[
          _TimestampText(timestamp: messageItem.timestamp),
          SizedBox(width: 8.w),
        ],
        Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
            decoration: BoxDecoration(
                color: messageItem.isMe ? white : grey_button_greyBG,
                border: messageItem.isMe
                    ? Border.all(color: grey_button_greyBG, width: 1)
                    : null,
                borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(20),
                    bottomRight: const Radius.circular(20),
                    topLeft: messageItem.isMe
                        ? const Radius.circular(20)
                        : const Radius.circular(0),
                    topRight: messageItem.isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(20))),
            child: Text(messageItem.content, style: mediumBlack14)),
        if (!messageItem.isMe) ...[
          SizedBox(width: 8.w),
          _TimestampText(timestamp: messageItem.timestamp),
        ],
      ],
    );
  }
}

class _TimestampText extends StatelessWidget {
  final DateTime timestamp;
  const _TimestampText({required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Text(DateFormat('hh:mm').format(timestamp),
            style: mediumGrey13));
  }
}
