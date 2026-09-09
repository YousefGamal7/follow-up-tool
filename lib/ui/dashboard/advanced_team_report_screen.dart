import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_models.dart';
import '../../providers/report_provider.dart';
import '../../services/pdf_service.dart';
import '../../theme/modern_styles.dart';

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

class _AdvancedTeamReportView extends StatelessWidget {
  const _AdvancedTeamReportView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          title: 'Blue Route Assignment Reports',
          actions: [
            AdaptiveAppBarAction(
              icon: Icons.sync,
              iosSymbol: 'arrow.triangle.2.circlepath',
              onPressed: () {
                context.read<ReportProvider>().forceSyncWithFirestore(context);
              },
            ),
            AdaptiveAppBarAction(
              icon: Icons.delete_sweep,
              iosSymbol: 'trash',
              onPressed: () {
                context.read<ReportProvider>().clearLocalCache(context);
              },
            ),
            AdaptiveAppBarAction(
              icon: Icons.picture_as_pdf,
              iosSymbol: 'doc.text',
              onPressed: () async {
                    final provider = context.read<ReportProvider>();
                    final resultPath = await PdfService.generateAndShareTeamReport(
                      allGroupAssignments: provider.allActiveAssignments,
                      workshops: provider.workshops,
                      attendance: provider.attendanceRecords,
                    );

                    if (context.mounted) {
                      if (resultPath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF generation or save cancelled'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else if (resultPath == 'shared') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF shared successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PDF saved successfully to: $resultPath'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: ModernStyles.getCardColor(context),
              child:  TabBar(
                labelColor: ModernStyles.getTextColor(context),
                unselectedLabelColor: Colors.grey,
                indicatorColor: ModernStyles.getTextColor(context),
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(text: 'Assignments'),
                  Tab(text: 'Workshops'),
                  Tab(text: 'Attendance'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _AssignmentsTab(),
                  _WorkshopsTab(),
                  _AttendanceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final assignments = provider.activeAssignments;

    if (provider.isLoadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.assignmentsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${provider.assignmentsError}', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Column(
      children: [
        if (provider.availableGroups.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: provider.availableGroups.map((group) {
                  final isSelected = provider.selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        group.contains('Group 1') ? 'Group 1' : 
                        (group.contains('Group 2') ? 'Group 2' : group),
                        style: TextStyle(
                          color: isSelected ? Colors.white : ModernStyles.blueRouteBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.setGroup(group);
                        }
                      },
                      showCheckmark: false,
                      selectedColor: ModernStyles.blueRouteBackground,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: ModernStyles.blueRouteBackground),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        Expanded(
          child: assignments.isEmpty 
              ? const Center(child: Text('No active assignments.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final item = assignments[index];
        final total = item.submitted + item.missing;
        final progress = total > 0 ? (item.submitted / total) : 0.0;
        final percentage = (progress * 100).toStringAsFixed(1);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: ModernStyles.blueRouteDivider),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name, 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        children: [
                          TextSpan(text: '${item.submitted} Sub', style: const TextStyle(color: ModernStyles.blueRouteBackground)),
                          const TextSpan(text: ' / ', style: TextStyle(color: Colors.red)),
                          TextSpan(text: '${item.missing} Miss', style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: ModernStyles.blueRouteSecondaryText),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${item.deadline}',
                      style: const TextStyle(color: ModernStyles.blueRouteSecondaryText, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Status: $percentage%', 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ModernStyles.blueRouteSecondaryText,
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: ModernStyles.blueRouteBadgeGrey,
                    color: ModernStyles.blueRouteBackground,
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
        ),
      ],
    );
  }
}

class _WorkshopsTab extends StatelessWidget {
  const _WorkshopsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final workshops = provider.workshops;

    return Scaffold(
      backgroundColor: ModernStyles.getCardColor(context),
      body: workshops.isEmpty
          ? const Center(child: Text('No workshops recorded yet. Add one!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                final ws = workshops[index];
                
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: ModernStyles.blueRouteDivider),
                  ),
                  color: ModernStyles.getCardColor(context),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ws.topic, 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))
                            ),
                            Row(
                              children: [
                                const Icon(Icons.people, size: 18, color: ModernStyles.blueRouteBackground),
                                const SizedBox(width: 6),
                                Text(
                                  '${ws.attendance}', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ModernStyles.blueRouteBackground),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                  onPressed: () => _showAddWorkshopDialog(context, editSession: ws),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.event, size: 14, color: ModernStyles.blueRouteSecondaryText),
                            const SizedBox(width: 4),
                            Text(
                              ws.date,
                              style: const TextStyle(color: ModernStyles.blueRouteSecondaryText, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 14, color: ModernStyles.blueRouteSecondaryText),
                            const SizedBox(width: 4),
                            Text(
                              '${ws.startTime} - ${ws.endTime}',
                              style: const TextStyle(color: ModernStyles.blueRouteSecondaryText, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkshopDialog(context),
        backgroundColor: ModernStyles.blueRouteButton,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Workshop'),
      ),
    );
  }

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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ModernStyles.getCardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editSession != null ? 'Edit Workshop' : 'Add New Workshop', 
                      style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(ctx))
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: ModernStyles.getTextColor(ctx)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildModernTextField(
                  context: context,
                  controller: topicCtrl,
                  labelText: 'Topic',
                  icon: Icons.topic,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  context: context,
                  controller: dateCtrl,
                  labelText: 'Date (Select)',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        context: context,
                        controller: startCtrl,
                        labelText: 'Start Time',
                        icon: Icons.schedule,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) startCtrl.text = picked.format(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModernTextField(
                        context: context,
                        controller: endCtrl,
                        labelText: 'End Time',
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) endCtrl.text = picked.format(ctx);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  context: context,
                  controller: attendanceCtrl,
                  labelText: 'Attendance Count',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: ModernStyles.glowingContainer(context, opacity: 0.3, borderRadius: 12),
                  child: FilledButton(
                    onPressed: () {
                      final att = int.tryParse(attendanceCtrl.text) ?? 0;
                      if (topicCtrl.text.isNotEmpty && dateCtrl.text.isNotEmpty) {
                        final session = WorkshopSession(
                          topic: topicCtrl.text,
                          date: dateCtrl.text,
                          attendance: att,
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
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(editSession != null ? 'Update Workshop' : 'Save Workshop', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final attendanceRecords = provider.attendanceRecords;

    return Scaffold(
      backgroundColor: ModernStyles.getCardColor(context),
      body: attendanceRecords.isEmpty
          ? const Center(child: Text('No attendance records yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final att = attendanceRecords[index];
                
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: ModernStyles.blueRouteDivider),
                  ),
                  color: ModernStyles.getCardColor(context),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              att.week, 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ModernStyles.blueRouteBackground.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    att.branchName, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ModernStyles.blueRouteBackground),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                  onPressed: () => _showAddAttendanceDialog(context, editRecord: att),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: ModernStyles.blueRouteSecondaryText),
                            const SizedBox(width: 4),
                            Text(
                              '${att.day}, ${att.date}',
                              style: const TextStyle(color: ModernStyles.blueRouteSecondaryText, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 14, color: ModernStyles.blueRouteSecondaryText),
                            const SizedBox(width: 4),
                            Text(
                              'Arrive: ${att.arriveTime} | End: ${att.endTime}',
                              style: const TextStyle(color: ModernStyles.blueRouteSecondaryText, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAttendanceDialog(context),
        backgroundColor: ModernStyles.blueRouteButton,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Attendance'),
      ),
    );
  }

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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ModernStyles.getCardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editRecord != null ? 'Edit Branch Attendance' : 'Add Branch Attendance', 
                      style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(ctx))
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: ModernStyles.getTextColor(ctx)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildModernTextField(
                  context: context,
                  controller: weekCtrl,
                  labelText: 'Week (e.g. Week 1)',
                  icon: Icons.view_week,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  context: context,
                  controller: dateCtrl,
                  labelText: 'Date (Select)',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
                      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                      dayCtrl.text = days[picked.weekday - 1];
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  context: context,
                  controller: dayCtrl,
                  labelText: 'Day (e.g. Friday)',
                  icon: Icons.today,
                ),
                const SizedBox(height: 16),
                _buildModernTextField(
                  context: context,
                  controller: branchNameCtrl,
                  labelText: 'Branch Name',
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        context: context,
                        controller: arriveCtrl,
                        labelText: 'Arrive Time',
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) arriveCtrl.text = picked.format(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModernTextField(
                        context: context,
                        controller: endCtrl,
                        labelText: 'End Time',
                        icon: Icons.access_time_filled,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) endCtrl.text = picked.format(ctx);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: ModernStyles.glowingContainer(context, opacity: 0.3, borderRadius: 12),
                  child: FilledButton(
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
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(editRecord != null ? 'Update Attendance' : 'Save Attendance', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildModernTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  bool readOnly = false,
  VoidCallback? onTap,
  TextInputType? keyboardType,
}) {
  return AdaptiveTextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    keyboardType: keyboardType,
    placeholder: labelText,
    prefixIcon: Icon(icon, color: ModernStyles.getTextColor(context)),
  );
}
