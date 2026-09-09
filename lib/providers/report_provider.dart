import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_models.dart';
import '../services/multi_sheet_sync_service.dart';
import '../services/firestore_sync_service.dart';
import '../core/config/cycle_config.dart' as config;

class ReportProvider extends ChangeNotifier {
  final String instructor;
  final String cycleName;
  List<String> availableGroups;
  String selectedGroup;

  Map<String, List<ReportAssignment>> _allAssignments = {};
  List<WorkshopSession> _workshops = [];
  List<BranchAttendance> _attendanceRecords = [];
  
  bool isLoadingAssignments = true;
  String? assignmentsError;

  ReportProvider({
    required this.instructor, 
    required this.cycleName,
    required List<String> groups, 
    required String initialGroup
  }) : availableGroups = groups,
       selectedGroup = initialGroup {
    if (!availableGroups.contains(selectedGroup) && availableGroups.isNotEmpty) {
      selectedGroup = availableGroups[0];
    }
    _loadData();
    _fetchAssignmentsFromGSheets();
  }

  void setGroup(String newGroup) {
    if (selectedGroup != newGroup) {
      selectedGroup = newGroup;
      notifyListeners();
    }
  }

  Future<void> _fetchAssignmentsFromGSheets() async {
    try {
      isLoadingAssignments = true;
      assignmentsError = null;
      notifyListeners();

      final cycle = config.availableCycles.firstWhere(
        (c) => c.name == cycleName,
        orElse: () => config.availableCycles.first,
      );

      final syncService = MultiSheetSyncService();
      syncService.setSpreadsheetIds(cycle.gradesSpreadsheetId, cycle.followUpSpreadsheetId);
      
      _allAssignments = await syncService.getAllGroupAssignmentsReport(instructor, availableGroups);
      
      isLoadingAssignments = false;
      notifyListeners();
    } catch (e) {
      isLoadingAssignments = false;
      assignmentsError = e.toString();
      notifyListeners();
    }
  }

  List<ReportAssignment> get activeAssignments {
    return (_allAssignments[selectedGroup] ?? [])
        .where((a) => a.deadline != null && a.deadline!.trim().isNotEmpty)
        .toList();
  }

  Map<String, List<ReportAssignment>> get allActiveAssignments {
    Map<String, List<ReportAssignment>> result = {};
    _allAssignments.forEach((group, assignments) {
      final active = assignments.where((a) => a.deadline != null && a.deadline!.trim().isNotEmpty).toList();
      if (active.isNotEmpty) {
        result[group] = active;
      }
    });
    return result;
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}
    return DateTime.now();
  }

  List<WorkshopSession> get workshops {
    final sorted = List<WorkshopSession>.from(_workshops);
    sorted.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
    return sorted;
  }

  List<BranchAttendance> get attendanceRecords {
    final sorted = List<BranchAttendance>.from(_attendanceRecords);
    sorted.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
    return sorted;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final workshopsString = prefs.getString('workshops_data_$cycleName');
    if (workshopsString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(workshopsString);
        _workshops = decoded.map((e) => WorkshopSession.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error decoding workshops: $e');
      }
    }

    final attendanceString = prefs.getString('attendance_data_$cycleName');
    if (attendanceString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(attendanceString);
        _attendanceRecords = decoded
            .map((e) => BranchAttendance.fromJson(e))
            .toList();
      } catch (e) {
        debugPrint('Error decoding attendance: $e');
      }
    }

    notifyListeners();

    // Sync with Firestore
    _syncWithFirestore();
  }

  Future<void> _syncWithFirestore() async {
    final firestoreSync = FirestoreSyncService(cycleName: cycleName);
    
    // Fetch from Firestore
    final firestoreWorkshops = await firestoreSync.fetchWorkshops();
    final firestoreAttendance = await firestoreSync.fetchAttendance();

    // Combine local and Firestore data, removing duplicates based on unique identifiers
    final Map<String, WorkshopSession> mergedWorkshops = {};
    for (var w in firestoreWorkshops) {
      final key = '${w.topic}_${w.date}_${w.startTime}';
      mergedWorkshops[key] = w;
    }
    for (var w in _workshops) {
      final key = '${w.topic}_${w.date}_${w.startTime}';
      if (!mergedWorkshops.containsKey(key)) {
        mergedWorkshops[key] = w;
        // Push local only to Firestore
        firestoreSync.syncWorkshop(w);
      }
    }
    _workshops = mergedWorkshops.values.toList();

    final Map<String, BranchAttendance> mergedAttendance = {};
    for (var a in firestoreAttendance) {
      final key = '${a.branchName}_${a.week}_${a.date}';
      mergedAttendance[key] = a;
    }
    for (var a in _attendanceRecords) {
      final key = '${a.branchName}_${a.week}_${a.date}';
      if (!mergedAttendance.containsKey(key)) {
        mergedAttendance[key] = a;
        // Push local only to Firestore
        firestoreSync.syncAttendanceRecord(a);
      }
    }
    _attendanceRecords = mergedAttendance.values.toList();

    notifyListeners();

    // Update local storage with merged data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workshops_data_$cycleName', jsonEncode(_workshops.map((e) => e.toJson()).toList()));
    await prefs.setString('attendance_data_$cycleName', jsonEncode(_attendanceRecords.map((e) => e.toJson()).toList()));
  }

  Future<void> forceSyncWithFirestore(BuildContext context) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Syncing with Firebase...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      
      await _syncWithFirestore();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Synced with Firebase successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error syncing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> addWorkshop(WorkshopSession session) async {
    _workshops.add(session);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _workshops.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('workshops_data_$cycleName', encoded);

    final firestoreSync = FirestoreSyncService(cycleName: cycleName);
    await firestoreSync.syncWorkshop(session);
  }

  Future<void> addAttendance(BranchAttendance record) async {
    _attendanceRecords.add(record);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _attendanceRecords.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('attendance_data_$cycleName', encoded);

    final firestoreSync = FirestoreSyncService(cycleName: cycleName);
    await firestoreSync.syncAttendanceRecord(record);
  }

  Future<void> updateWorkshop(WorkshopSession oldSession, WorkshopSession newSession) async {
    final index = _workshops.indexOf(oldSession);
    if (index != -1) {
      _workshops[index] = newSession;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workshops_data_$cycleName', jsonEncode(_workshops.map((e) => e.toJson()).toList()));

      final firestoreSync = FirestoreSyncService(cycleName: cycleName);
      await firestoreSync.syncWorkshop(newSession);
    }
  }

  Future<void> updateAttendance(BranchAttendance oldRecord, BranchAttendance newRecord) async {
    final index = _attendanceRecords.indexOf(oldRecord);
    if (index != -1) {
      _attendanceRecords[index] = newRecord;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('attendance_data_$cycleName', jsonEncode(_attendanceRecords.map((e) => e.toJson()).toList()));

      final firestoreSync = FirestoreSyncService(cycleName: cycleName);
      await firestoreSync.syncAttendanceRecord(newRecord);
    }
  }

  Future<void> clearLocalCache(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workshops_data_$cycleName');
    await prefs.remove('attendance_data_$cycleName');
    
    _workshops.clear();
    _attendanceRecords.clear();
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Local cache for Workshops & Attendance cleared!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
