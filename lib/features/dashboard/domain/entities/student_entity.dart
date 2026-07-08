import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  final String name;
  final String? email;
  final String phone;
  final String group;
  final String grade;
  final int missedCount;
  final Map<String, String> allGrades;

  const StudentEntity({
    required this.name,
    this.email,
    required this.phone,
    required this.group,
    required this.grade,
    required this.missedCount,
    required this.allGrades,
  });

  @override
  List<Object?> get props => [name, email, phone, group, grade, missedCount, allGrades];
}
