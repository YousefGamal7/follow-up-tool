import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student.dart';
import '../services/google_sheets_service.dart';
import '../services/multi_sheet_sync_service.dart';
import '../core/config/cycle_config.dart' as config;

class DashboardProvider extends ChangeNotifier {
  final GoogleSheetsService _sheetsService = GoogleSheetsService();
  final MultiSheetSyncService _multiSheetSyncService = MultiSheetSyncService();

  String selectedCycle = 'C19';
  List<String> get availableCycles => config.availableCycles.map((e) => e.name).toList();

  String? selectedInstructor = 'Yousef Gamal';
  String? selectedGroup = 'All';
  String? selectedAssignment;
  String? selectedFilter = 'All';

  List<String> dynamicTasks = [
    'Assignment 1', 'Assignment 2', 'Assignment 3', 
    'OOP1', 'OOP2', 'Whatsapp', 'Facebook', 'Space', 
    'Contacts', 'Islami', 'Evently', 'News', 'Movie'
  ];
  String? selectedDynamicTask = 'Assignment 1';

  List<String> instructors = [
    'Yousef Gamal',
    'Mahmoud Ibrahim',
    'Abdelrahman Youssef',
    'Rana Osama',
    'Ali Mohamed',
  ];
  List<String> groups = ['All'];
  List<String> assignments = [];
  List<String> filters = [
    'All',
    'Late only (late)',
    'Not submitted (empty)',
    'Grades under 10',
    'Warned (Missed 6+)',
  ];

  List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  List<Student> selectedStudents = [];
  List<String> sentPhones = [];
  bool isLoading = false;

  List<String> _savedMaleTemplates = [];
  List<String> _savedFemaleTemplates = [];
  bool isMaleTemplate = true;

  List<String> get savedTemplates => isMaleTemplate ? _savedMaleTemplates : _savedFemaleTemplates;

  String? selectedTemplate;
  final TextEditingController templateController = TextEditingController();
  final TextEditingController excuseReasonController = TextEditingController();

  List<String> actionLogs = [];

  DashboardProvider() {
    _loadTemplates();
    _loadSentHistory();
    // Initialize cycle
    setCycle(selectedCycle);
  }

  void setCycle(String cycleName) {
    selectedCycle = cycleName;
    final cycle = config.availableCycles.firstWhere(
      (c) => c.name == cycleName,
      orElse: () => config.availableCycles.first,
    );
    _sheetsService.setSpreadsheetId(cycle.gradesSpreadsheetId);
    _multiSheetSyncService.setSpreadsheetIds(
      cycle.gradesSpreadsheetId,
      cycle.followUpSpreadsheetId,
    );
    fetchData();
    notifyListeners();
  }

  void _addLog(String message) {
    actionLogs.insert(0, "[${DateTime.now().toLocal().toString().split('.')[0]}] $message");
    if (actionLogs.length > 50) actionLogs.removeLast();
    notifyListeners();
  }

  Future<void> _loadSentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    sentPhones = prefs.getStringList('sent_history') ?? [];
    notifyListeners();
  }

  Future<void> markAsSent(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    if (!sentPhones.contains(phone)) {
      sentPhones.add(phone);
      await prefs.setStringList('sent_history', sentPhones);
      notifyListeners();
    }
  }

  Future<void> clearSentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sent_history');
    sentPhones = [];
    _addLog("Sent history cleared.");
    notifyListeners();
  }

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    _savedMaleTemplates = prefs.getStringList('wa_templates_male') ?? [];
    _savedFemaleTemplates = prefs.getStringList('wa_templates_female') ?? [];
    notifyListeners();
  }

  void toggleTemplateGender(bool isMale) {
    isMaleTemplate = isMale;
    selectedTemplate = null;
    templateController.text = '';
    notifyListeners();
  }

  Future<void> saveTemplate(BuildContext context) async {
    final text = templateController.text.trim();
    if (text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    
    final list = isMaleTemplate ? _savedMaleTemplates : _savedFemaleTemplates;
    final key = isMaleTemplate ? 'wa_templates_male' : 'wa_templates_female';

    if (!list.contains(text)) {
      list.add(text);
      await prefs.setStringList(key, list);
      selectedTemplate = text;
      _addLog("Template saved.");
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void selectTemplate(String? v) {
    selectedTemplate = v;
    templateController.text = v ?? '';
    notifyListeners();
  }

  String generateMessage(Student s) {
    String msg = templateController.text;
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

  Future<void> launchWhatsAppWeb(Student s, BuildContext context, List<String> assignments, String customMessage) async {
    final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
    bool launched = false;

    if (isAndroid) {
      // Try WhatsApp Business first
      final String waBusinessUrl = "intent://send?phone=${s.phone}&text=${Uri.encodeComponent(customMessage)}#Intent;package=com.whatsapp.w4b;scheme=whatsapp;end;";
      try {
        launched = await launchUrl(Uri.parse(waBusinessUrl), mode: LaunchMode.externalApplication);
      } catch (_) {}
      
      // If WhatsApp Business is not installed, fallback to normal WhatsApp App
      if (!launched) {
        final String waNormalUrl = "whatsapp://send?phone=${s.phone}&text=${Uri.encodeComponent(customMessage)}";
        try {
          launched = await launchUrl(Uri.parse(waNormalUrl), mode: LaunchMode.externalApplication);
        } catch (_) {}
      }
    }

    // Fallback for Windows/Web or if Android intents fail
    if (!launched) {
      final String webUrl = "https://web.whatsapp.com/send?phone=${s.phone}&text=${Uri.encodeComponent(customMessage)}";
      try {
        launched = await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    if (launched) {
      await markAsSent(s.phone);
      _addLog("WhatsApp launched for ${s.name}");
      
      // Auto mark as followed up in sheets
      try {
        await _multiSheetSyncService.markAsFollowedUp(
          email: s.email ?? '${s.name.replaceAll(' ', '')}@gmail.com', // fallback logic, normally should use s.email
          messageSent: customMessage,
          sheetName: selectedInstructor!,
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

  Future<void> launchTelegramWeb(Student s, BuildContext context, List<String> assignments, String customMessage) async {
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
    print ('yousef = ${tgUrl}');



    if (!launched) {
      final String webUrl = "https://t.me/+$cleanPhone?text=$encodedMsg";
      print ('yousef = ${webUrl}');

      try {
        launched = await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    if (launched) {
      await markAsSent(s.phone);
      _addLog("Telegram launched for ${s.name}");
      
      try {
        await _multiSheetSyncService.markAsFollowedUp(
          email: s.email ?? '${s.name.replaceAll(' ', '')}@gmail.com',
          messageSent: customMessage,
          sheetName: selectedInstructor!,
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
    selectedInstructor = instructor;
    fetchData();
  }

  void setGroup(String? group) {
    selectedGroup = group;
    applyFilters();
  }

  void setAssignment(String? assignment) {
    selectedAssignment = assignment;
    fetchData();
  }

  void setFilter(String? filter) {
    selectedFilter = filter;
    applyFilters();
  }

  void setDynamicTask(String? task) {
    selectedDynamicTask = task;
    notifyListeners();
  }

  void toggleStudentSelection(Student s, bool isSelected) {
    if (isSelected) {
      selectedStudents.add(s);
    } else {
      selectedStudents.remove(s);
    }
    notifyListeners();
  }

  Future<void> fetchData() async {
    isLoading = true;
    selectedStudents = [];
    notifyListeners();

    if (selectedInstructor == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final data = await _sheetsService.fetchInstructorData(selectedInstructor!, selectedAssignment);

    if (data != null) {
      allStudents = data['students'];
      groups = data['groups'];
      assignments = data['assignments'];
      selectedAssignment = data['selectedAssignment'];
      applyFilters();
      _addLog("Fetched data for instructor: $selectedInstructor");
    }

    isLoading = false;
    notifyListeners();
  }

  void applyFilters() {
    filteredStudents = allStudents.where((s) {
      bool groupMatch = selectedGroup == 'All' || s.group == selectedGroup;
      bool filterMatch = true;
      if (selectedFilter == 'Late only (late)') {
        filterMatch = s.grade.toLowerCase().contains('late');
      } else if (selectedFilter == 'Not submitted (empty)') {
        filterMatch = s.grade.trim().isEmpty;
      } else if (selectedFilter == 'Grades under 10') {
        double? g = double.tryParse(s.grade);
        filterMatch = g != null && g < 10;
      } else if (selectedFilter == 'Warned (Missed 6+)') {
        filterMatch = s.missedCount >= 6;
      }
      return groupMatch && filterMatch;
    }).toList();
    notifyListeners();
  }

  Future<void> processTickets() async {
    if (selectedInstructor == null || selectedAssignment == null) return;
    isLoading = true;
    notifyListeners();
    try {
      await _sheetsService.processStudentTickets(selectedInstructor!, selectedAssignment!);
      _addLog("Tickets synced successfully for current view.");
      await fetchData();
    } catch (e) {
      _addLog("Error syncing tickets: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyDynamicTickets(BuildContext context) async {
    if (selectedDynamicTask == null) return;
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to mark [$selectedDynamicTask] as Done for all ticket holders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Mark as Done'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    isLoading = true;
    notifyListeners();

    try {
      await _multiSheetSyncService.applyTickets(
        taskName: selectedDynamicTask!,
        gradesSheetName: selectedInstructor!,
      );
      _addLog("Dynamically applied tickets for $selectedDynamicTask");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated $selectedDynamicTask!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await fetchData();
    } catch (e) {
      _addLog("Failed to update dynamic tickets: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> excuseStudent(BuildContext context, Student s, List<String> assignmentsToExcuse) async {
    final reason = excuseReasonController.text.trim();
    if (reason.isEmpty || assignmentsToExcuse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select assignments and provide a reason.')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();
    
    // In actual implementation we'd need student's email.
    // If Student model doesn't have email, we could try to pass the first column (assuming it's email) or use name fallback.
    // Assuming Student model was updated or we pass an identifier:
    String identifier = s.email ?? s.name; // Use email if available

    try {
      await _multiSheetSyncService.addExcusedStatus(
        email: identifier, // This needs to match the Mail column in Sheets!
        assignments: assignmentsToExcuse,
        reason: reason,
        sheetName: selectedInstructor!,
      );
      _addLog("Excused $identifier for ${assignmentsToExcuse.join(', ')}");
      excuseReasonController.clear();
      await fetchData();
    } catch (e) {
      _addLog("Failed to excuse $identifier: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> noAnswerStudent(BuildContext context, Student s, List<String> assignmentsToMark) async {
    if (assignmentsToMark.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select assignments.')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();
    
    String identifier = s.email ?? s.name; // Use email if available

    try {
      await _multiSheetSyncService.addNoAnswerStatus(
        email: identifier,
        assignments: assignmentsToMark,
        sheetName: selectedInstructor!,
      );
      _addLog("Marked No Answer for $identifier on ${assignmentsToMark.join(', ')}");
      await fetchData();
    } catch (e) {
      _addLog("Failed to mark No Answer for $identifier: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncGradesToStatus(String task) async {
    isLoading = true;
    notifyListeners();
    try {
       int count = await _multiSheetSyncService.syncGradesToStatus(
         task,
         sheetName: selectedInstructor!,
       );
       _addLog("Synced grades to tracking status. Updated $count rows.");
    } catch(e) {
       _addLog("Error syncing grades to status: $e");
    } finally {
       isLoading = false;
       notifyListeners();
    }
  }

  /// Full sync: checks EVERY assignment column for every student.
  /// Writes "Submitted" if cell has data, "No Answer" if empty.
  Future<void> syncAllAssignments(BuildContext context) async {
    if (selectedInstructor == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final count = await _multiSheetSyncService.syncAllAssignmentsToFollowUp(
        sheetName: selectedInstructor!,
      );
      _addLog("Full sync complete: $count students written to Follow-up sheet.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Synced $count students to the Follow-up sheet!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _addLog("Error in full sync: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearLocalCache(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    sentPhones.clear();
    _savedMaleTemplates.clear();
    _savedFemaleTemplates.clear();
    selectedTemplate = null;
    _addLog("Local cache cleared.");
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Local cache cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
