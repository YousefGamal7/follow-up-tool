import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_models.dart';
import '../services/multi_sheet_sync_service.dart';
import '../services/firestore_sync_service.dart';

class ReportProvider extends ChangeNotifier {
  final String instructor;
  List<String> availableGroups;
  String selectedGroup;

  Map<String, List<ReportAssignment>> _allAssignments = {};
  List<WorkshopSession> _workshops = [];
  List<BranchAttendance> _attendanceRecords = [];
  
  bool isLoadingAssignments = true;
  String? assignmentsError;

  ReportProvider({
    required this.instructor, 
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

      final syncService = MultiSheetSyncService();
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

  List<WorkshopSession> get workshops => _workshops;
  List<BranchAttendance> get attendanceRecords => _attendanceRecords;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final workshopsString = prefs.getString('workshops_data');
    if (workshopsString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(workshopsString);
        _workshops = decoded.map((e) => WorkshopSession.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error decoding workshops: $e');
      }
    }

    final attendanceString = prefs.getString('attendance_data');
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
    final firestoreSync = FirestoreSyncService();
    
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
    await prefs.setString('workshops_data', jsonEncode(_workshops.map((e) => e.toJson()).toList()));
    await prefs.setString('attendance_data', jsonEncode(_attendanceRecords.map((e) => e.toJson()).toList()));
  }

  Future<void> addWorkshop(WorkshopSession session) async {
    _workshops.add(session);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _workshops.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('workshops_data', encoded);

    final firestoreSync = FirestoreSyncService();
    await firestoreSync.syncWorkshop(session);
  }

  Future<void> addAttendance(BranchAttendance record) async {
    _attendanceRecords.add(record);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _attendanceRecords.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('attendance_data', encoded);

    final firestoreSync = FirestoreSyncService();
    await firestoreSync.syncAttendanceRecord(record);
  }
}
