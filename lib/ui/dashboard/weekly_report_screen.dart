import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../providers/weekly_report_provider.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeeklyReportProvider(),
      child: const _WeeklyReportView(),
    );
  }
}

class _WeeklyReportView extends StatelessWidget {
  const _WeeklyReportView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeeklyReportProvider>();

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Weekly Assignments Report',
      ),
      body: Column(
        children: [
          _buildFilterSection(provider),
          Expanded(
            child: _buildAssignmentsList(provider.filteredAssignments),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(WeeklyReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        runSpacing: 8.0,
        children: provider.availableGroups.map((group) {
          final isSelected = provider.selectedGroup == group;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(
                group == 'Group 1' ? 'Group 1 (Friday 10Am)' : 'Group 2 (Saturday 10Am)',
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.selectGroup(group);
                }
              },
              showCheckmark: false,
              selectedColor: Colors.blueAccent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignmentsList(List<Assignment> assignments) {
    if (assignments.isEmpty) {
      return const Center(
        child: Text('No assignments found for this group.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _AssignmentCard(assignment: assignment);
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AdaptiveCard(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
                size: 28.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.0,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Deadline: ${assignment.deadline}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
