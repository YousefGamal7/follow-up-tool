import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_models.dart';

class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cycleName;

  FirestoreSyncService({required this.cycleName});

  // Collection References
  CollectionReference get _workshopsRef => _firestore.collection('workshops_$cycleName');
  CollectionReference get _attendanceRef => _firestore.collection('attendance_$cycleName');
  CollectionReference get _assignmentsRef => _firestore.collection('assignments_$cycleName');

  // Generate a unique ID for a WorkshopSession
  String _generateWorkshopId(WorkshopSession session) {
    return '${session.topic}_${session.date}_${session.startTime}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  // Generate a unique ID for a BranchAttendance
  String _generateAttendanceId(BranchAttendance record) {
    return '${record.branchName}_${record.week}_${record.date}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  // Sync a single workshop to Firestore
  Future<void> syncWorkshop(WorkshopSession session) async {
    try {
      final docId = _generateWorkshopId(session);
      await _workshopsRef.doc(docId).set(session.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error syncing workshop: $e');
    }
  }

  // Sync a single attendance record to Firestore
  Future<void> syncAttendanceRecord(BranchAttendance record) async {
    try {
      final docId = _generateAttendanceId(record);
      await _attendanceRef.doc(docId).set(record.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error syncing attendance: $e');
    }
  }

  // Fetch all workshops from Firestore
  Future<List<WorkshopSession>> fetchWorkshops() async {
    try {
      final snapshot = await _workshopsRef.get();
      return snapshot.docs.map((doc) => WorkshopSession.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching workshops: $e');
      return [];
    }
  }

  // Fetch all attendance records from Firestore
  Future<List<BranchAttendance>> fetchAttendance() async {
    try {
      final snapshot = await _attendanceRef.get();
      return snapshot.docs.map((doc) => BranchAttendance.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  // Fetch all assignments from Firestore
  Future<List<ReportAssignment>> fetchAssignments() async {
    try {
      final snapshot = await _assignmentsRef.get();
      return snapshot.docs.map((doc) => ReportAssignment(
        name: doc['name'] ?? '',
        submitted: doc['submitted'] ?? 0,
        missing: doc['missing'] ?? 0,
        deadline: doc['deadline'],
      )).toList();
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }
}
