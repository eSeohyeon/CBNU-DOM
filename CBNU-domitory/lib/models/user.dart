class User {
  final String id; //수정
  final String profilePath;
  final String nickname;
  final String department;
  final String enrollYear; // 임시로
  final String birthYear; // 임시로
  final bool isSmoking;
  final Map<String, dynamic> checklist;
  final double dormScore;

  final String dormitory; // 임시로,

  User({required this.id, required this.profilePath, required this.nickname, required this.department, required this.enrollYear, required this.isSmoking, required this.checklist, this.dormScore = -1, this.birthYear = '0', this.dormitory=' '});
}