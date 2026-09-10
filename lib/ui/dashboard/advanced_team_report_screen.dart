import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';
import '../../models/report_models.dart';
import '../../providers/report_provider.dart';
import '../../services/pdf_service.dart';
import '../../core/config/cycle_config.dart' as config;

class AdvancedTeamReportScreen extends StatelessWidget {
  final String instructor;
  final String cycleName;
  final List<String> groups;
  final String initialGroup;

  const AdvancedTeamReportScreen({
    super.key,
    required this.instructor,
    required this.cycleName,
    required this.groups,
    required this.initialGroup,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportProvider(
        instructor: instructor,
        cycleName: cycleName,
        groups: groups,
        initialGroup: initialGroup,
      ),
      child: const _AdvancedTeamReportView(),
    );
  }
}

class _AdvancedTeamReportView extends StatefulWidget {
  const _AdvancedTeamReportView();

  @override
  State<_AdvancedTeamReportView> createState() => _AdvancedTeamReportViewState();
}

class _AdvancedTeamReportViewState extends State<_AdvancedTeamReportView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ObsidianTheme.borderWhite),
            ),
            clipBehavior: Clip.antiAlias,
            child: isDesktop
                ? Row(
                    children: [
                      // Sidebar
                      SizedBox(width: 280, child: _buildSidebar(context)),
                      const VerticalDivider(width: 1, color: ObsidianTheme.borderWhite),
                      // Main Area
                      Expanded(child: _buildMainArea(context)),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: 250, child: _buildSidebar(context)),
                      const Divider(height: 1, color: ObsidianTheme.borderWhite),
                      Expanded(child: _buildMainArea(context)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    return Container(
      color: ObsidianTheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Advanced Report', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Cycle
            _buildLabel('Cycle'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: provider.cycleName,
              items: config.availableCycles.map((e) => e.name).toList(),
              onChanged: (v) {
                if (v != null) provider.setCycle(v);
              },
            ),
            const SizedBox(height: 16),
            
            // Group
            _buildLabel('Group'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: provider.selectedGroup,
              items: provider.availableGroups,
              onChanged: (v) {
                if (v != null) provider.setGroup(v);
              },
            ),
            const SizedBox(height: 32),

            // Generate PDF
            ElevatedButton.icon(
              onPressed: () async {
                final resultPath = await PdfService.generateAndShareTeamReport(
                  allGroupAssignments: provider.allActiveAssignments,
                  workshops: provider.workshops,
                  attendance: provider.attendanceRecords,
                );
                if (context.mounted && resultPath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report generated: $resultPath'), backgroundColor: ObsidianTheme.success),
                  );
                }
              },
              icon: const Icon(LucideIcons.fileText, size: 16),
              label: const Text('Generate PDF', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ObsidianTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Clear Cache
            OutlinedButton.icon(
              onPressed: () => provider.clearLocalCache(context),
              icon: const Icon(LucideIcons.trash2, size: 16),
              label: const Text('Clear Local Cache'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ObsidianTheme.warningBadgeText,
                side: const BorderSide(color: ObsidianTheme.warningBadgeBg),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Force Sync
            OutlinedButton.icon(
              onPressed: () => provider.forceSyncWithFirestore(context),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Force Firebase Sync'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ObsidianTheme.textSecondary,
                side: const BorderSide(color: ObsidianTheme.borderWhite),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold));
  }

  Widget _buildDropdown({required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceRecessed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ObsidianTheme.borderWhite),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: ObsidianTheme.surfaceRecessed,
          style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 14),
          icon: const Icon(LucideIcons.chevronDown, color: ObsidianTheme.textSecondary, size: 16),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMainArea(BuildContext context) {
    return Column(
      children: [
        Container(
          color: ObsidianTheme.background,
          child: TabBar(
            controller: _tabController,
            labelColor: ObsidianTheme.primary,
            unselectedLabelColor: ObsidianTheme.textSecondary,
            indicatorColor: ObsidianTheme.primary,
            tabs: const [
              Tab(text: 'Assignments'),
              Tab(text: 'Workshops'),
              Tab(text: 'Attendance'),
            ],
          ),
        ),
        const Divider(height: 1, color: ObsidianTheme.borderWhite),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _AssignmentsTab(),
              _WorkshopsTab(),
              _AttendanceTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------
// ASSIGNMENTS TAB
// ---------------------------------------------------------
class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    if (provider.isLoadingAssignments) {
      return const Center(child: CircularProgressIndicator(color: ObsidianTheme.primary));
    }
    if (provider.assignmentsError != null) {
      return Center(child: Text('Error: ${provider.assignmentsError}', style: const TextStyle(color: ObsidianTheme.warningBadgeText)));
    }
    
    final assignments = provider.activeAssignments;
    if (assignments.isEmpty) {
      return const Center(child: Text('No assignments found.', style: TextStyle(color: ObsidianTheme.textMuted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final a = assignments[index];
        final total = a.submitted + a.missing;
        final progress = total > 0 ? (a.submitted / total) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: ObsidianTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: ObsidianTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.fileText, color: ObsidianTheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Deadline: ${a.deadline}', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${a.submitted} Submitted / ${a.missing} Missing', style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: ObsidianTheme.surfaceRecessed,
                      valueColor: const AlwaysStoppedAnimation<Color>(ObsidianTheme.success),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// WORKSHOPS TAB
// ---------------------------------------------------------
class _WorkshopsTab extends StatelessWidget {
  const _WorkshopsTab();

  void _showAddWorkshopDialog(BuildContext context, {WorkshopSession? editSession}) {
    final topicCtrl = TextEditingController(text: editSession?.topic ?? '');
    final dateCtrl = TextEditingController(text: editSession?.date ?? '');
    final attendanceCtrl = TextEditingController(text: editSession?.attendance.toString() ?? '');
    final startCtrl = TextEditingController(text: editSession?.startTime ?? '');
    final endCtrl = TextEditingController(text: editSession?.endTime ?? '');
    final provider = context.read<ReportProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ObsidianTheme.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editSession != null ? 'Edit Workshop' : 'Add New Workshop',
                      style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: ObsidianTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildObsidianTextField(controller: topicCtrl, label: 'Topic (e.g. Dart OOP)', icon: LucideIcons.bookOpen),
                const SizedBox(height: 16),
                _buildObsidianTextField(controller: dateCtrl, label: 'Date (DD/MM/YYYY)', icon: LucideIcons.calendar),
                const SizedBox(height: 16),
                _buildObsidianTextField(controller: attendanceCtrl, label: 'Attendance Count', icon: LucideIcons.users, isNumber: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildObsidianTextField(controller: startCtrl, label: 'Start (10:00 AM)', icon: LucideIcons.clock)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildObsidianTextField(controller: endCtrl, label: 'End (02:00 PM)', icon: LucideIcons.clock)),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (topicCtrl.text.isNotEmpty && dateCtrl.text.isNotEmpty) {
                      final session = WorkshopSession(
                        topic: topicCtrl.text,
                        date: dateCtrl.text,
                        attendance: int.tryParse(attendanceCtrl.text) ?? 0,
                        startTime: startCtrl.text,
                        endTime: endCtrl.text,
                      );
                      if (editSession != null) {
                        provider.updateWorkshop(editSession, session);
                      } else {
                        provider.addWorkshop(session);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(editSession != null ? 'Update Workshop' : 'Save Workshop', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    return Stack(
      children: [
        provider.workshops.isEmpty
            ? const Center(child: Text('No workshops recorded yet.', style: TextStyle(color: ObsidianTheme.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: provider.workshops.length,
                itemBuilder: (context, index) {
                  final ws = provider.workshops[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: ObsidianTheme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: ObsidianTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.monitorPlay, color: ObsidianTheme.secondary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ws.topic, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${ws.date} • ${ws.startTime} - ${ws.endTime}', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text('${ws.attendance} attendees', style: const TextStyle(color: ObsidianTheme.textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(LucideIcons.edit2, size: 16, color: ObsidianTheme.textSecondary),
                          onPressed: () => _showAddWorkshopDialog(context, editSession: ws),
                        ),
                      ],
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: ObsidianTheme.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showAddWorkshopDialog(context),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------
// ATTENDANCE TAB
// ---------------------------------------------------------
class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  void _showAddAttendanceDialog(BuildContext context, {BranchAttendance? editRecord}) {
    final weekCtrl = TextEditingController(text: editRecord?.week ?? '');
    final dateCtrl = TextEditingController(text: editRecord?.date ?? '');
    final dayCtrl = TextEditingController(text: editRecord?.day ?? '');
    final arriveCtrl = TextEditingController(text: editRecord?.arriveTime ?? '');
    final endCtrl = TextEditingController(text: editRecord?.endTime ?? '');
    final branchNameCtrl = TextEditingController(text: editRecord?.branchName ?? 'Dokki');
    final provider = context.read<ReportProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ObsidianTheme.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editRecord != null ? 'Edit Branch Attendance' : 'Add Branch Attendance',
                      style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: ObsidianTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildObsidianTextField(controller: branchNameCtrl, label: 'Branch (e.g. Dokki, Nasr City)', icon: LucideIcons.mapPin),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildObsidianTextField(controller: weekCtrl, label: 'Week (e.g. W14)', icon: LucideIcons.hash)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildObsidianTextField(controller: dayCtrl, label: 'Day (e.g. Fri)', icon: LucideIcons.sun)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildObsidianTextField(controller: dateCtrl, label: 'Date (DD/MM/YYYY)', icon: LucideIcons.calendar),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildObsidianTextField(controller: arriveCtrl, label: 'Arrive (12:00 PM)', icon: LucideIcons.logIn)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildObsidianTextField(controller: endCtrl, label: 'End (04:00 PM)', icon: LucideIcons.logOut)),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (weekCtrl.text.isNotEmpty && dateCtrl.text.isNotEmpty) {
                      final record = BranchAttendance(
                        week: weekCtrl.text,
                        date: dateCtrl.text,
                        day: dayCtrl.text,
                        arriveTime: arriveCtrl.text,
                        endTime: endCtrl.text,
                        branchName: branchNameCtrl.text,
                      );
                      if (editRecord != null) {
                        provider.updateAttendance(editRecord, record);
                      } else {
                        provider.addAttendance(record);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(editRecord != null ? 'Update Attendance' : 'Save Attendance', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    return Stack(
      children: [
        provider.attendanceRecords.isEmpty
            ? const Center(child: Text('No attendance recorded yet.', style: TextStyle(color: ObsidianTheme.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: provider.attendanceRecords.length,
                itemBuilder: (context, index) {
                  final att = provider.attendanceRecords[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: ObsidianTheme.cardDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: ObsidianTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.userCheck, color: ObsidianTheme.success, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${att.week} - ${att.branchName}', style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${att.date} (${att.day})', style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text('${att.arriveTime} - ${att.endTime}', style: const TextStyle(color: ObsidianTheme.textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(LucideIcons.edit2, size: 16, color: ObsidianTheme.textSecondary),
                          onPressed: () => _showAddAttendanceDialog(context, editRecord: att),
                        ),
                      ],
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: ObsidianTheme.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showAddAttendanceDialog(context),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------
// HELPER WIDGETS
// ---------------------------------------------------------
Widget _buildObsidianTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isNumber = false,
}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: ObsidianTheme.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ObsidianTheme.textMuted),
      prefixIcon: Icon(icon, color: ObsidianTheme.textSecondary, size: 18),
      filled: true,
      fillColor: ObsidianTheme.surfaceRecessed,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ObsidianTheme.borderWhite),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ObsidianTheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
