import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_models.dart';

class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _workshopsRef => _firestore.collection('workshops');
  CollectionReference get _attendanceRef => _firestore.collection('attendance');

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

  // Sync a list of workshops to Firestore
  Future<void> syncWorkshopsList(List<WorkshopSession> sessions) async {
    for (final session in sessions) {
      await syncWorkshop(session);
    }
  }

  // Sync a list of attendance records to Firestore
  Future<void> syncAttendanceList(List<BranchAttendance> records) async {
    for (final record in records) {
      await syncAttendanceRecord(record);
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
}
