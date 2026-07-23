import '../entities/instructor_data_entity.dart';

abstract class DashboardRepository {
  Future<InstructorDataEntity?> fetchInstructorData(String instructorName, String? selectedAssignment);
  Future<void> processStudentTickets(String instructorSheetName, String assignmentColumnName);
  
  Future<void> applyTickets({required String taskName, required String gradesSheetName});
  Future<void> addExcusedStatus({required String email, required List<String> assignments, required String reason, required String sheetName});
  Future<void> addNoAnswerStatus({required String email, required List<String> assignments, required String sheetName});
  Future<int> syncGradesToStatus(String task, {required String sheetName});
  Future<int> syncAllAssignmentsToFollowUp({required String sheetName});
  Future<void> markAsFollowedUp({required String email, required String messageSent, required String sheetName, required List<String> assignments});
  void setCycle(String cycleName);
}
