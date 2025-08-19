class ChatMessage {
  final String messageId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe
});

  // json 데이터 변환할 때 쓰는 거
  /*factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['messageId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }*/
}

class ChatItem {
  final String chatId;
  final String senderId;
  final String latestContent;
  final DateTime latestTimestamp;

  ChatItem({
    required this.chatId,
    required this.senderId,
    required this.latestContent,
    required this.latestTimestamp,
  });
}