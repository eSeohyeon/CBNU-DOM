import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:untitled/common/grey_filled_text_field.dart';
import 'package:untitled/models/chat_message.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  late TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();

  //더미 채팅 메시지
  final List<ChatMessage> _chatMessages = [
    ChatMessage(messageId: '1', senderId: '키위', content: '안녕하세요!', timestamp: DateTime(2025, 8, 10, 13, 50), isMe: false),
    ChatMessage(messageId: '2', senderId: '나', content: '안녕~~', timestamp: DateTime(2025, 8, 10, 13, 53), isMe: true),
    ChatMessage(messageId: '3', senderId: '키위', content: '점심은 드셨나요', timestamp: DateTime(2025, 8, 10, 14, 00), isMe: false),
    ChatMessage(messageId: '4', senderId: '나', content: '아직이요. 뭐 먹을지 고민 중이에요', timestamp: DateTime(2025, 8, 10, 14, 01), isMe: true),
    ChatMessage(messageId: '5', senderId: '키위', content: '피자는 어떠세요', timestamp: DateTime(2025, 8, 10, 14, 05), isMe: false),
    ChatMessage(messageId: '6', senderId: '키위', content: '여기 맛있어 보이는데', timestamp: DateTime(2025, 8, 10, 14, 05), isMe: false),
    ChatMessage(messageId: '7', senderId: '나', content: '네', timestamp: DateTime(2025, 8, 10, 14, 06), isMe: true),
    ChatMessage(messageId: '8', senderId: '키위', content: '어제 피자 맛있었어요', timestamp: DateTime(2025, 8, 11, 09, 07), isMe: false),
    ChatMessage(messageId: '9', senderId: '나', content: 'ㅎㅎ 저도요', timestamp: DateTime(2025, 8, 11, 09, 30), isMe: true),
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) { // 새 메시지 추가 시 스크롤 맨 아래로 이동
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final messageItem = _chatMessages[index];
                  final previousItem = index > 0 ? _chatMessages[index -1] : null;

                  // 날짜 바뀌면 날짜 구분선 표시
                  final bool showDateSeparator = previousItem == null || !isSameDay(messageItem.timestamp, previousItem.timestamp);

                  return Column(
                    children: [
                      if(showDateSeparator) _DateSeparator(date: messageItem.timestamp),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: _MessageItem(messageItem: messageItem),
                      )
                    ]
                  );
                }
              )
            ),
            Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h, top: 10.h),
                child: Row(
                    children: [
                      Expanded(
                          child: GreyFilledTextField(controller: _messageController, name: '메시지 입력', inputType: TextInputType.visiblePassword)
                      ),
                      SizedBox(width: 4.w),
                      InkWell(
                        borderRadius: BorderRadius.circular(18.0),
                          onTap: () {
                            // 메시지 전송 로직 추가
                            if(_messageController.text.isNotEmpty){
                              setState(() {
                                _chatMessages.add(
                                  ChatMessage(
                                    messageId: DateTime.now().millisecondsSinceEpoch.toString(),
                                    senderId: '나',
                                    content: _messageController.text,
                                    timestamp: DateTime.now(),
                                    isMe: true
                                  )
                                );
                                _messageController.clear();
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                                decoration: BoxDecoration(color: black, borderRadius: BorderRadius.circular(28)),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                    child: Icon(
                                        Icons.keyboard_return_rounded,
                                        color: white,
                                        size: 28
                                    )
                                )
                            ),
                          )
                      )
                    ]
                )
            ),
          ]
        )
      ),
    );
  }
}

// 날짜 구분선 위젯
class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: grey_button,
        borderRadius: BorderRadius.circular(25.0)
      ),
      child: Text(
        DateFormat('MM/dd').format(date),
        style: mediumBlack14
      )
    );
  }
}

// 두 DateTime 객체가 같은 날짜인지 확인하는 함수
bool isSameDay(DateTime a, DateTime b){
  return a.year == b.year && a.month == b.month && a.day == b.day;
}


class _MessageItem extends StatelessWidget {
  final ChatMessage messageItem;
  const _MessageItem({super.key, required this.messageItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: messageItem.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(!messageItem.isMe) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: grey_button_greyBG,
              child: Image.asset('assets/profile_man.png'),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  messageItem.senderId,
                  style: mediumBlack14
                ),
                SizedBox(height: 4.h),
                _MessageBubble(messageItem: messageItem)
              ]
            )
          ] else ...[
            _MessageBubble(messageItem: messageItem)
          ]
        ],
      )
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage messageItem;
  const _MessageBubble({super.key, required this.messageItem});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: messageItem.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if(messageItem.isMe) ...[
          _TimestampText(timestamp: messageItem.timestamp),
          SizedBox(width: 8.w),
        ],

        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.8),
          decoration: BoxDecoration(
            color: messageItem.isMe ? white : grey_button_greyBG,
            border: messageItem.isMe ? Border.all(color: grey_button_greyBG, width: 1) : null,
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
              topLeft: messageItem.isMe ? const Radius.circular(20) : const Radius.circular(0),
              topRight: messageItem.isMe ? const Radius.circular(0) : const Radius.circular(20)
            )
          ),
          child: Text(
            messageItem.content,
            style: mediumBlack14
          )
        ),

        if(!messageItem.isMe) ...[
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
      child: Text(
        DateFormat('hh:mm').format(timestamp),
        style: mediumGrey13
      )
    );
  }
}


