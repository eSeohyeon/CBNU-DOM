class User {
  final String profilePath;
  final String name;
  final String department;
  final String yearEnrolled;
  final bool isSmoking;
  final List<Map<String, String>> checklist;

  User({required this.profilePath, required this.name, required this.department, required this.yearEnrolled, required this.isSmoking, required this.checklist});
}