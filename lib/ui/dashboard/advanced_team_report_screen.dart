import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_models.dart';
import '../../providers/report_provider.dart';
import '../../services/pdf_service.dart';

class AdvancedTeamReportScreen extends StatelessWidget {
  final String instructor;
  final List<String> groups;
  final String initialGroup;

  const AdvancedTeamReportScreen({
    super.key, 
    required this.instructor, 
    required this.groups,
    required this.initialGroup,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportProvider(
        instructor: instructor, 
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Team Report'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Generate & Share PDF',
                  onPressed: () {
                    final provider = context.read<ReportProvider>();
                    PdfService.generateAndShareTeamReport(
                      allGroupAssignments: provider.allActiveAssignments,
                      workshops: provider.workshops,
                      attendance: provider.attendanceRecords,
                    );
                  },
                );
              }
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Assignments', icon: Icon(Icons.assignment)),
              Tab(text: 'Workshops', icon: Icon(Icons.group_work)),
              Tab(text: 'Attendance', icon: Icon(Icons.co_present)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AssignmentsTab(),
            _WorkshopsTab(),
            _AttendanceTab(),
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
                children: provider.availableGroups.map((group) {
                  final isSelected = provider.selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        group.contains('Group 1') ? 'Group 1' : 
                        (group.contains('Group 2') ? 'Group 2' : group),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          provider.setGroup(group);
                        }
                      },
                      showCheckmark: false,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
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

        final theme = Theme.of(context);
        final statusColor = progress >= 0.8 
            ? Colors.green 
            : (progress >= 0.5 ? Colors.orange : Colors.red);

        return Card(
          elevation: 3,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name, 
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Deadline: ${item.deadline}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: $percentage%', 
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      )
                    ),
                    Text(
                      '${item.submitted} Sub / ${item.missing} Miss',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: statusColor,
                    minHeight: 10,
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
      body: workshops.isEmpty
          ? const Center(child: Text('No workshops recorded yet. Add one!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                final ws = workshops[index];
                final theme = Theme.of(context);
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.science, color: theme.colorScheme.primary),
                    ),
                    title: Text(ws.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event, size: 14),
                              const SizedBox(width: 4),
                              Text(ws.date),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text('${ws.startTime} - ${ws.endTime}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 24, color: theme.colorScheme.secondary),
                        const SizedBox(height: 4),
                        Text(
                          '${ws.attendance}', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkshopDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Workshop'),
      ),
    );
  }

  void _showAddWorkshopDialog(BuildContext context) {
    final topicCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final attendanceCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final provider = context.read<ReportProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
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
                Text(
                  'Add New Workshop', 
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: topicCtrl, 
                  decoration: InputDecoration(
                    labelText: 'Topic', 
                    prefixIcon: const Icon(Icons.topic),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateCtrl, 
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
                  decoration: InputDecoration(
                    labelText: 'Date (Select)', 
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl, 
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) {
                            startCtrl.text = picked.format(ctx);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Start Time', 
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        )
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: endCtrl, 
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) {
                            endCtrl.text = picked.format(ctx);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'End Time', 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        )
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: attendanceCtrl, 
                  keyboardType: TextInputType.number, 
                  decoration: InputDecoration(
                    labelText: 'Attendance Count', 
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 32),
                FilledButton(
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
                      provider.addWorkshop(session);
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Workshop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      body: attendanceRecords.isEmpty
          ? const Center(child: Text('No attendance records yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final att = attendanceRecords[index];
                final theme = Theme.of(context);
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.tertiaryContainer,
                      child: Icon(Icons.storefront, color: theme.colorScheme.tertiary),
                    ),
                    title: Text(att.week, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 14),
                              const SizedBox(width: 4),
                              Text('${att.day}, ${att.date}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text('Branch: ${att.branchName}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text('Arrive: ${att.arriveTime} | End: ${att.endTime}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAttendanceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Attendance'),
      ),
    );
  }

  void _showAddAttendanceDialog(BuildContext context) {
    final weekCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final dayCtrl = TextEditingController();
    final arriveCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final branchNameCtrl = TextEditingController(text: 'Dokki');
    final provider = context.read<ReportProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
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
                Text(
                  'Add Branch Attendance', 
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: weekCtrl, 
                  decoration: InputDecoration(
                    labelText: 'Week (e.g. Week 1)', 
                    prefixIcon: const Icon(Icons.view_week),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateCtrl, 
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
                  decoration: InputDecoration(
                    labelText: 'Date (Select)', 
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dayCtrl, 
                  decoration: InputDecoration(
                    labelText: 'Day (e.g. Friday)', 
                    prefixIcon: const Icon(Icons.today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: branchNameCtrl, 
                  decoration: InputDecoration(
                    labelText: 'Branch Name', 
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: arriveCtrl, 
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) {
                            arriveCtrl.text = picked.format(ctx);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Arrive Time', 
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        )
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: endCtrl, 
                        readOnly: true,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (!ctx.mounted) return;
                          if (picked != null) {
                            endCtrl.text = picked.format(ctx);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'End Time', 
                          prefixIcon: const Icon(Icons.access_time_filled),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton(
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
                      provider.addAttendance(record);
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
