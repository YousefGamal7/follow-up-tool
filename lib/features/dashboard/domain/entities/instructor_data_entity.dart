import 'student_entity.dart';

class InstructorDataEntity {
  final List<StudentEntity> students;
  final List<String> groups;
  final List<String> assignments;
  final String? selectedAssignment;

  InstructorDataEntity({
    required this.students,
    required this.groups,
    required this.assignments,
    this.selectedAssignment,
  });
}
