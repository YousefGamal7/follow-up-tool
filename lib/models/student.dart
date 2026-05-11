class Student {
  final String name;
  final String? email;
  final String phone;
  final String group;
  final String grade;
  final int missedCount;
  final Map<String, String> allGrades;

  Student({
    required this.name,
    this.email,
    required this.phone,
    required this.group,
    required this.grade,
    required this.missedCount,
    required this.allGrades,
  });
}
