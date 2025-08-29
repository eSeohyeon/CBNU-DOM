import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:untitled/themes/colors.dart';
import 'package:untitled/themes/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'package:untitled/common/grey_filled_text_field.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  late TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  final String serverUrl = 'http://10.0.2.2:8000/get_answer'; // 로컬서버 + 에뮬레이터
  bool _isLoading = false;

  final List<Map<String, String>> _messages = [];

  //테스트 빨래는 어떻게 해?
  String _question = '';
  String _answer = '';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) { // 새 메시지 추가 시 스크롤 맨 아래로 이동
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    _messages.add({'챗봇' : '저는 충북대학교 생활관과 관련된 질문에만 답변할 수 있어요. 관련되지 않은 질문은 답변드리기 어려운 점 양해 부탁드려요.\n\n-원하는 답변이 나오지 않는다면?\n 1. 질문을 짧고 간단하게 적어주세요.\n 2. 핵심 키워드를 반드시 포함해서 질문해주세요.\n\n무엇이 궁금하신가요?'});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getAnswerFromChatbot() async {
    _question = _messageController.text;
    if (_question.isEmpty) return;

    final payload = {'question': _question};
    _messageController.clear();

    setState(() {
      _isLoading = true;
      _messages.add({'나' : _question});
      _messages.add({'챗봇_로딩' : '로딩 중...'});
    });

    _scrollToBottom();

    try {
      final response = await http.post(
          Uri.parse(serverUrl),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final answer = data['answer'];

        setState(() {
          _answer = answer;
          _isLoading = false;
          _messages.removeLast();
          _messages.add({'챗봇' : answer});
        });

        _scrollToBottom();
        return;
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('try-catch error: $e');
    }

    setState(() {
      _isLoading = false;
      _messages.removeLast();
      _messages.add({'챗봇' : '죄송해요. 답변을 불러오는 데에 실패했어요.'});
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final item = _messages[index];
                  final isUser = item.containsKey('나');
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment:  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: grey_button_greyBG,
                            child: Image.asset('assets/profile_man.png'),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        if (isUser) ...[
                          // 사용자 메시지 버블
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                  color: grey_button_greyBG,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: const Radius.circular(20),
                                      bottomRight: const Radius.circular(20),
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(0)
                                  )
                              ),
                              child: Text(
                                  item['나']!,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: mediumBlack14
                              )
                          )
                        ] else ...[
                          // 챗봇 메시지 버블
                          item.containsKey('챗봇_로딩') ?
                          Column( // 로딩 중일떄
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('챗봇', style: boldBlack14),
                                SizedBox(height: 4.h),
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                        color: white,
                                        border : Border.all(color: grey_button_greyBG, width: 1),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: const Radius.circular(20),
                                            bottomRight: const Radius.circular(20),
                                            topLeft: const Radius.circular(0),
                                            topRight: const Radius.circular(20)
                                        )
                                    ),
                                    child: Lottie.asset('assets/chatbot_loading.json', width: 32.w, height: 20.h)
                                )
                              ]
                          ) :
                          Column( // 로딩이 끝났을 때
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('챗봇', style: boldBlack14),
                              SizedBox(height: 4.h),
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                  decoration: BoxDecoration(
                                      color: white,
                                      border : Border.all(color: grey_button_greyBG, width: 1),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: const Radius.circular(20),
                                          bottomRight: const Radius.circular(20),
                                          topLeft: const Radius.circular(0),
                                          topRight: const Radius.circular(20)
                                      )
                                  ),
                                  child: Text(
                                      item['챗봇']!,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: mediumBlack14
                                  )
                              )
                            ]
                          )
                        ]
                      ],
                    ),
                  );
                }
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h, top: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: GreyFilledTextField(
                      controller: _messageController,
                      name: '메시지 입력',
                      inputType: TextInputType.visiblePassword,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  InkWell(
                    onTap: () {
                      getAnswerFromChatbot();
                    },
                    child: Container(
                      decoration: BoxDecoration(color: black, borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 8.h, left: 12.w, right: 10.w),
                        child: Icon(
                          Icons.send_rounded,
                          color: white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('챗봇의 정보가 틀릴 수 있으니 주의해주세요.', style: mediumGrey12),
            SizedBox(height: 6.h),
          ],
        )
      )
    );
  }
}
