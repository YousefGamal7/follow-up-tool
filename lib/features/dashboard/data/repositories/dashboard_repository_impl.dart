import '../../../../models/student.dart';
import '../../domain/entities/instructor_data_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../services/google_sheets_service.dart';
import '../../../../services/multi_sheet_sync_service.dart';
import '../../../../core/config/cycle_config.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final GoogleSheetsService sheetsService;
  final MultiSheetSyncService multiSheetSyncService;

  DashboardRepositoryImpl({
    required this.sheetsService,
    required this.multiSheetSyncService,
  });

  @override
  void setCycle(String cycleName) {
    final cycle = availableCycles.firstWhere(
      (c) => c.name == cycleName,
      orElse: () => availableCycles.first,
    );
    sheetsService.setSpreadsheetId(cycle.gradesSpreadsheetId);
    multiSheetSyncService.setSpreadsheetIds(
      cycle.gradesSpreadsheetId,
      cycle.followUpSpreadsheetId,
    );
  }

  @override
  Future<InstructorDataEntity?> fetchInstructorData(String instructorName, String? selectedAssignment) async {
    final data = await sheetsService.fetchInstructorData(instructorName, selectedAssignment);
    if (data == null) return null;

    final List<Student> studentsModel = data['students'];
    final List<StudentEntity> students = studentsModel.map((s) => StudentEntity(
      name: s.name,
      email: s.email,
      phone: s.phone,
      group: s.group,
      grade: s.grade,
      missedCount: s.missedCount,
      allGrades: s.allGrades,
    )).toList();

    return InstructorDataEntity(
      students: students,
      groups: data['groups'],
      assignments: data['assignments'],
      selectedAssignment: data['selectedAssignment'],
    );
  }

  @override
  Future<void> processStudentTickets(String instructorSheetName, String assignmentColumnName) async {
    return sheetsService.processStudentTickets(instructorSheetName, assignmentColumnName);
  }

  @override
  Future<void> applyTickets({required String taskName, required String gradesSheetName}) async {
    return multiSheetSyncService.applyTickets(taskName: taskName, gradesSheetName: gradesSheetName);
  }

  @override
  Future<void> addExcusedStatus({required String email, required List<String> assignments, required String reason, required String sheetName}) async {
    return multiSheetSyncService.addExcusedStatus(email: email, assignments: assignments, reason: reason, sheetName: sheetName);
  }

  @override
  Future<void> addNoAnswerStatus({required String email, required List<String> assignments, required String sheetName}) async {
    return multiSheetSyncService.addNoAnswerStatus(email: email, assignments: assignments, sheetName: sheetName);
  }

  @override
  Future<int> syncGradesToStatus(String task, {required String sheetName}) async {
    return multiSheetSyncService.syncGradesToStatus(task, sheetName: sheetName);
  }

  @override
  Future<int> syncAllAssignmentsToFollowUp({required String sheetName}) async {
    return multiSheetSyncService.syncAllAssignmentsToFollowUp(sheetName: sheetName);
  }

  @override
  Future<void> markAsFollowedUp({required String email, required String messageSent, required String sheetName, required List<String> assignments}) async {
    return multiSheetSyncService.markAsFollowedUp(email: email, messageSent: messageSent, sheetName: sheetName, assignments: assignments);
  }
}
