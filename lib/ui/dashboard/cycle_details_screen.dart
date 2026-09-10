import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';
import '../../services/firestore_sync_service.dart';
import '../../services/google_sheets_service.dart';
import '../../models/report_models.dart';
import '../../models/student.dart';
import '../../core/config/cycle_config.dart';

class CycleDetailsScreen extends StatefulWidget {
  final String cycleName;
  final String instructorName;

  const CycleDetailsScreen({
    super.key,
    required this.cycleName,
    required this.instructorName,
  });

  @override
  State<CycleDetailsScreen> createState() => _CycleDetailsScreenState();
}

class _CycleDetailsScreenState extends State<CycleDetailsScreen> {
  late FirestoreSyncService _firestoreService;
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  int _selectedTabIndex = 1; // 0: Assignments, 1: Workshops, 2: Attendance, 3: Students

  List<WorkshopSession> _workshops = [];
  List<BranchAttendance> _attendance = [];
  List<ReportAssignment> _assignments = [];
  List<Student> _students = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreSyncService(cycleName: widget.cycleName.replaceAll(' ', '_'));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cycle = availableCycles.firstWhere(
        (c) => c.name.toLowerCase() == widget.cycleName.toLowerCase(),
        orElse: () => availableCycles.first,
      );
      _sheetsService.setSpreadsheetId(cycle.gradesSpreadsheetId);

      final workshops = await _firestoreService.fetchWorkshops();
      final attendance = await _firestoreService.fetchAttendance();
      // Fetch students from Google Sheets
      final sheetData = await _sheetsService.fetchInstructorData(widget.instructorName, null);
      List<Student> students = [];
      List<ReportAssignment> computedAssignments = [];

      if (sheetData != null && sheetData['students'] != null) {
        students = sheetData['students'] as List<Student>;
        
        // Compute assignment statistics from Google Docs data
        final List<String> assignmentNames = sheetData['assignments'] as List<String>? ?? [];
        final Map<String, String> assignmentDeadlines = sheetData['deadlines'] as Map<String, String>? ?? {};
        
        for (final assignmentName in assignmentNames) {
          int submitted = 0;
          int missing = 0;
          for (final s in students) {
            final grade = s.allGrades[assignmentName];
            if (grade == null || grade.trim().isEmpty) {
              missing++;
            } else {
              submitted++;
            }
          }
          computedAssignments.add(ReportAssignment(
            name: assignmentName,
            submitted: submitted,
            missing: missing,
            deadline: assignmentDeadlines[assignmentName] ?? 'N/A', 
          ));
        }
      }

      setState(() {
        _workshops = workshops;
        _attendance = attendance;
        _assignments = computedAssignments;
        _students = students;
      });
    } catch (e) {
      print('Error loading cycle data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: ObsidianTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('WORKSPACES', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
            const SizedBox(width: 8),
            Text(widget.cycleName.toUpperCase(), style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
            const SizedBox(width: 8),
            const Text('CYCLE DASHBOARD', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ObsidianTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text('${widget.cycleName} Dashboard', style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        color: ObsidianTheme.textSecondary,
                        onPressed: _loadData,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('New Session'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tabs
                  Row(
                    children: [
                      _buildTab('Assignments', LucideIcons.fileText, 0),
                      _buildTab('Workshops', LucideIcons.monitorPlay, 1),
                      _buildTab('Attendance', LucideIcons.users, 2),
                      _buildTab('Student Data', LucideIcons.database, 3),
                    ],
                  ),
                  const Divider(color: ObsidianTheme.borderWhite, height: 1),
                  const SizedBox(height: 24),
                  
                  // Tab Content
                  _buildTabContent(),
                ],
              ),
            ),
    );
  }

  Widget _buildTab(String title, IconData icon, int index) {
    final isActive = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? ObsidianTheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? ObsidianTheme.primary : ObsidianTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? ObsidianTheme.primary : ObsidianTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Assignments
        return _buildAssignmentsTab();
      case 1: // Workshops
        return _buildWorkshopsTab();
      case 2: // Attendance
        return _buildAttendanceTab();
      case 3: // Students
        return _buildStudentsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWorkshopsTab() {
    if (_workshops.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No workshops found in Firebase for this cycle.', style: TextStyle(color: ObsidianTheme.textMuted))));
    }
    return Column(
      children: _workshops.map((w) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: ObsidianTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ObsidianTheme.surfaceRecessed,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ObsidianTheme.borderWhite),
                ),
                child: const Icon(LucideIcons.monitorPlay, color: ObsidianTheme.textSecondary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.topic, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${w.date} • ${w.startTime} - ${w.endTime}', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ObsidianTheme.surfaceRecessed,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ObsidianTheme.borderWhite),
                ),
                child: Text('${w.attendance} attendees', style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssignmentsTab() {
    if (_assignments.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No assignments found in Firebase.', style: TextStyle(color: ObsidianTheme.textMuted))));
    }
    return Column(
      children: _assignments.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: ObsidianTheme.cardDecoration,
          child: Row(
            children: [
              const Icon(LucideIcons.fileText, color: ObsidianTheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    if (a.deadline != null)
                      Text('Deadline: ${a.deadline}', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Text('${a.submitted} Submitted / ${a.missing} Missing', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttendanceTab() {
    if (_attendance.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No attendance records found in Firebase.', style: TextStyle(color: ObsidianTheme.textMuted))));
    }
    return Column(
      children: _attendance.map((att) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: ObsidianTheme.cardDecoration,
          child: Row(
            children: [
              const Icon(LucideIcons.userCheck, color: ObsidianTheme.success),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Week ${att.week} - ${att.branchName}', style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${att.date} (${att.day})', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text('${att.arriveTime} - ${att.endTime}', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudentsTab() {
    if (_students.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No students found in Google Sheets.', style: TextStyle(color: ObsidianTheme.textMuted))));
    }
    return Column(
      children: _students.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: ObsidianTheme.cardDecoration,
          child: Row(
            children: [
              CircleAvatar(backgroundColor: ObsidianTheme.primary.withOpacity(0.2), child: Text(s.name.substring(0, 1), style: const TextStyle(color: ObsidianTheme.primary))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(s.group, style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.grade == 'At Risk' ? ObsidianTheme.warningBadgeBg : ObsidianTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(s.grade, style: TextStyle(color: s.grade == 'At Risk' ? ObsidianTheme.warningBadgeText : ObsidianTheme.success, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
