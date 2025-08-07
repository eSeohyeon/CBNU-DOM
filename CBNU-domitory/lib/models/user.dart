class User {
  final String profilePath;
  final String name;
  final String department;
  final String yearEnrolled; // 임시로
  final String birthYear; // 임시로
  final bool isSmoking;
  final List<Map<String, String>> checklist;
  final double dormScore;

  final String dormitory; // 임시로,

  User({required this.profilePath, required this.name, required this.department, required this.yearEnrolled, required this.isSmoking, required this.checklist, this.dormScore = -1, this.birthYear = '0', this.dormitory=' '});
}