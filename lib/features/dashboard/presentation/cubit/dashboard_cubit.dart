import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_state.dart';
import '../../domain/usecases/fetch_instructor_data_usecase.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/student_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final FetchInstructorDataUseCase fetchInstructorDataUseCase;
  final DashboardRepository repository; // Used directly for mutations

  DashboardCubit({
    required this.fetchInstructorDataUseCase,
    required this.repository,
  }) : super(const DashboardState()) {
    _init();
  }

  Future<void> _init() async {
    await _loadTemplates();
    await _loadSentHistory();
    repository.setCycle(state.selectedCycle);
    await fetchData();
  }

  void _addLog(String message) {
    final newLogs = List<String>.from(state.actionLogs);
    newLogs.insert(0, "[${DateTime.now().toLocal().toString().split('.')[0]}] $message");
    if (newLogs.length > 50) newLogs.removeLast();
    emit(state.copyWith(actionLogs: newLogs));
  }

  Future<void> _loadSentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sentPhones = prefs.getStringList('sent_history') ?? [];
    emit(state.copyWith(sentPhones: sentPhones));
  }

  Future<void> markAsSent(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    if (!state.sentPhones.contains(phone)) {
      final newSentPhones = List<String>.from(state.sentPhones)..add(phone);
      await prefs.setStringList('sent_history', newSentPhones);
      emit(state.copyWith(sentPhones: newSentPhones));
    }
  }

  Future<void> clearSentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sent_history');
    emit(state.copyWith(sentPhones: []));
    _addLog("Sent history cleared.");
  }

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final maleTemplates = prefs.getStringList('wa_templates_male') ?? [];
    final femaleTemplates = prefs.getStringList('wa_templates_female') ?? [];
    emit(state.copyWith(
      savedMaleTemplates: maleTemplates,
      savedFemaleTemplates: femaleTemplates,
    ));
  }

  void toggleTemplateGender(bool isMale) {
    emit(state.copyWith(
      isMaleTemplate: isMale,
      selectedTemplate: null,
    ));
  }

  Future<void> saveTemplate(String text) async {
    if (text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    
    final list = List<String>.from(state.isMaleTemplate ? state.savedMaleTemplates : state.savedFemaleTemplates);
    final key = state.isMaleTemplate ? 'wa_templates_male' : 'wa_templates_female';

    if (!list.contains(text)) {
      list.add(text);
      await prefs.setStringList(key, list);
      _addLog("Template saved.");
      if (state.isMaleTemplate) {
        emit(state.copyWith(savedMaleTemplates: list, selectedTemplate: text));
      } else {
        emit(state.copyWith(savedFemaleTemplates: list, selectedTemplate: text));
      }
    }
  }

  void selectTemplate(String? v) {
    emit(state.copyWith(selectedTemplate: v));
  }

  String generateMessage(StudentEntity s, String templateText) {
    String msg = templateText;
    if (msg.isEmpty) {
      msg = "Hello [الاسم], your grade is [الدرجه], and you missed [الغياب] tasks.";
    }
    
    msg = msg.replaceAll('[الاسم]', s.name);
    msg = msg.replaceAll('[الدرجه]', s.grade.isEmpty ? 'Not Submitted' : s.grade);
    msg = msg.replaceAll('[الغياب]', s.missedCount.toString());

    List<String> missingTasks = [];
    s.allGrades.forEach((task, grade) {
      if (grade.isEmpty) missingTasks.add(task);
    });

    msg = msg.replaceAll('[Tasks]', missingTasks.join(', '));
    return msg;
  }

  Future<void> launchWhatsAppWeb(StudentEntity s, String customMessage, List<String> assignments, {bool isAndroid = false}) async {
    bool launched = false;

    if (isAndroid) {
      final String waBusinessUrl = "intent://send?phone=${s.phone}&text=${Uri.encodeComponent(customMessage)}#Intent;package=com.whatsapp.w4b;scheme=whatsapp;end;";
      try { launched = await launchUrl(Uri.parse(waBusinessUrl), mode: LaunchMode.externalApplication); } catch (_) {}
      
      if (!launched) {
        final String waNormalUrl = "whatsapp://send?phone=${s.phone}&text=${Uri.encodeComponent(customMessage)}";
        try { launched = await launchUrl(Uri.parse(waNormalUrl), mode: LaunchMode.externalApplication); } catch (_) {}
      }
    }

    if (!launched) {
      final String webUrl = "https://web.whatsapp.com/send?phone=${s.phone}&text=${Uri.encodeComponent(customMessage)}";
      try { launched = await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication); } catch (_) {}
    }

    if (launched) {
      await markAsSent(s.phone);
      _addLog("WhatsApp launched for ${s.name}");
      
      try {
        await repository.markAsFollowedUp(
          email: s.email ?? '${s.name.replaceAll(' ', '')}@gmail.com',
          messageSent: customMessage,
          sheetName: state.selectedInstructor!,
          assignments: assignments,
        );
        if (assignments.isNotEmpty) {
          _addLog("Marked ${s.name} as Followed up in assignments.");
        } else {
          _addLog("Marked ${s.name} as Followed up in Follow-up column.");
        }
      } catch (e) {
         _addLog("Warning: Could not mark follow up in sheets: $e");
      }
    }
  }

  Future<void> launchTelegramWeb(StudentEntity s, String customMessage, List<String> assignments, {bool isAndroid = false}) async {
    bool launched = false;
    final String encodedMsg = Uri.encodeComponent(customMessage);
    
    String cleanPhone = s.phone.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('00')) {
      cleanPhone = cleanPhone.substring(2);
    }
    if (cleanPhone.startsWith('01') && cleanPhone.length == 11) {
      cleanPhone = '20${cleanPhone.substring(1)}';
    }

    final String tgUrl = "tg://resolve?phone=%2B$cleanPhone&text=$encodedMsg";
    try { launched = await launchUrl(Uri.parse(tgUrl), mode: LaunchMode.externalApplication); } catch (_) {}

    if (!launched) {
      final String webUrl = "https://t.me/+$cleanPhone?text=$encodedMsg";
      try { launched = await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication); } catch (_) {}
    }

    if (launched) {
      await markAsSent(s.phone);
      _addLog("Telegram launched for ${s.name}");
      
      try {
        await repository.markAsFollowedUp(
          email: s.email ?? '${s.name.replaceAll(' ', '')}@gmail.com',
          messageSent: customMessage,
          sheetName: state.selectedInstructor!,
          assignments: assignments,
        );
        if (assignments.isNotEmpty) {
          _addLog("Marked ${s.name} as Followed up in assignments.");
        } else {
          _addLog("Marked ${s.name} as Followed up in Follow-up column.");
        }
      } catch (e) {
         _addLog("Warning: Could not mark follow up in sheets: $e");
      }
    }
  }

  void setInstructor(String? instructor) {
    emit(state.copyWith(selectedInstructor: instructor));
    fetchData();
  }

  void setCycle(String? cycleName) {
    if (cycleName == null) return;
    emit(state.copyWith(selectedCycle: cycleName));
    repository.setCycle(cycleName);
    fetchData();
  }

  void setGroup(String? group) {
    emit(state.copyWith(selectedGroup: group));
    _applyFilters();
  }

  void setAssignment(String? assignment) {
    emit(state.copyWith(selectedAssignment: assignment));
    fetchData();
  }

  void setFilter(String? filter) {
    emit(state.copyWith(selectedFilter: filter));
    _applyFilters();
  }

  void setDynamicTask(String? task) {
    emit(state.copyWith(selectedDynamicTask: task));
  }

  void toggleStudentSelection(StudentEntity s, bool isSelected) {
    final newSelection = List<StudentEntity>.from(state.selectedStudents);
    if (isSelected) {
      newSelection.add(s);
    } else {
      newSelection.remove(s);
    }
    emit(state.copyWith(selectedStudents: newSelection));
  }

  Future<void> fetchData() async {
    if (state.selectedInstructor == null) return;
    
    emit(state.copyWith(isLoading: true, selectedStudents: []));

    try {
      final data = await fetchInstructorDataUseCase(state.selectedInstructor!, state.selectedAssignment);
      if (data != null) {
        emit(state.copyWith(
          allStudents: data.students,
          groups: data.groups,
          assignments: data.assignments,
          selectedAssignment: data.selectedAssignment,
        ));
        _applyFilters();
        _addLog("Fetched data for instructor: ${state.selectedInstructor}");
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      _addLog("Error fetching data: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _applyFilters() {
    final filtered = state.allStudents.where((s) {
      bool groupMatch = state.selectedGroup == 'All' || s.group == state.selectedGroup;
      bool filterMatch = true;
      if (state.selectedFilter == 'Late only (late)') {
        filterMatch = s.grade.toLowerCase().contains('late');
      } else if (state.selectedFilter == 'Not submitted (empty)') {
        filterMatch = s.grade.trim().isEmpty;
      } else if (state.selectedFilter == 'Grades under 10') {
        double? g = double.tryParse(s.grade);
        filterMatch = g != null && g < 10;
      } else if (state.selectedFilter == 'Warned (Missed 6+)') {
        filterMatch = s.missedCount >= 6;
      }
      return groupMatch && filterMatch;
    }).toList();
    emit(state.copyWith(filteredStudents: filtered));
  }

  Future<void> processTickets() async {
    if (state.selectedInstructor == null || state.selectedAssignment == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await repository.processStudentTickets(state.selectedInstructor!, state.selectedAssignment!);
      _addLog("Tickets synced successfully for current view.");
      await fetchData();
    } catch (e) {
      emit(state.copyWith(error: "Error syncing tickets: $e"));
      _addLog("Error syncing tickets: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> applyDynamicTickets() async {
    if (state.selectedDynamicTask == null || state.selectedInstructor == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await repository.applyTickets(
        taskName: state.selectedDynamicTask!,
        gradesSheetName: state.selectedInstructor!,
      );
      _addLog("Dynamically applied tickets for ${state.selectedDynamicTask}");
      await fetchData();
    } catch (e) {
      emit(state.copyWith(error: "Failed to update dynamic tickets: $e"));
      _addLog("Failed to update dynamic tickets: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> excuseStudent(StudentEntity s, List<String> assignmentsToExcuse, String reason) async {
    if (reason.isEmpty || assignmentsToExcuse.isEmpty) return;
    emit(state.copyWith(isLoading: true));
    String identifier = s.email ?? s.name;
    try {
      await repository.addExcusedStatus(
        email: identifier,
        assignments: assignmentsToExcuse,
        reason: reason,
        sheetName: state.selectedInstructor!,
      );
      _addLog("Excused $identifier for ${assignmentsToExcuse.join(', ')}");
      await fetchData();
    } catch (e) {
      _addLog("Failed to excuse $identifier: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> noAnswerStudent(StudentEntity s, List<String> assignmentsToMark) async {
    if (assignmentsToMark.isEmpty) return;
    emit(state.copyWith(isLoading: true));
    String identifier = s.email ?? s.name;
    try {
      await repository.addNoAnswerStatus(
        email: identifier,
        assignments: assignmentsToMark,
        sheetName: state.selectedInstructor!,
      );
      _addLog("Marked No Answer for $identifier on ${assignmentsToMark.join(', ')}");
      await fetchData();
    } catch (e) {
      _addLog("Failed to mark No Answer for $identifier: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> syncGradesToStatus(String task) async {
    emit(state.copyWith(isLoading: true));
    try {
       int count = await repository.syncGradesToStatus(
         task,
         sheetName: state.selectedInstructor!,
       );
       _addLog("Synced grades to tracking status. Updated $count rows.");
    } catch(e) {
       _addLog("Error syncing grades to status: $e");
    } finally {
       emit(state.copyWith(isLoading: false));
    }
  }

  Future<int> syncAllAssignments() async {
    if (state.selectedInstructor == null) return 0;
    emit(state.copyWith(isLoading: true));
    try {
      final count = await repository.syncAllAssignmentsToFollowUp(
        sheetName: state.selectedInstructor!,
      );
      _addLog("Full sync complete: $count students written to Follow-up sheet.");
      return count;
    } catch (e) {
      _addLog("Error in full sync: $e");
      throw e;
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(state.copyWith(
      sentPhones: [],
      savedMaleTemplates: [],
      savedFemaleTemplates: [],
      selectedTemplate: null,
    ));
    _addLog("Local cache cleared.");
  }
}
