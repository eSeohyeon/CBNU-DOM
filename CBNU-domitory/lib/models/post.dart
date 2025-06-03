class Post {
  final String title;
  final String writer;
  final String date;
  final String time;
  final String contents;
  final int likeCount;

  Post({required this.title, required this.writer, required this.date, required this.time, required this.contents, required this.likeCount});
}

class GroupBuyPost {
  final Post basePost;
  final String itemUrl;
  final String itemImagePath;
  final int itemPrice;
  final int maxParticipants;
  final int currentParticipants;

  GroupBuyPost({required this.basePost, required this.itemUrl, required this.itemImagePath, required this.itemPrice, required this.maxParticipants, required this.currentParticipants});
}