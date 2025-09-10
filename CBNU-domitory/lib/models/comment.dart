class Comment {
  final String postId;
  final int commentId;
  final String contents;
  final DateTime dateTime;
  final String userId;
  final List<Comment> subComments;

  Comment({required this.postId, required this.commentId, required this.contents, required this.dateTime, required this.userId, required this.subComments});
}
