class Meal {
  final String date; // 2025-04-27
  final String dayOfWeek; // 일요일
  final String breakfast; // 잡곡밥or쌀밥\n김칫국\n돈채야채볶음\n(돈육:국산)\n검정콩자반\n깍두기\n우유or두유\n891kcal/21g
  final String lunch;
  final String dinner;

  Meal({
    required this.date,
    required this.dayOfWeek,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}