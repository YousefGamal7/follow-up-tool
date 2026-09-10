import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/obsidian_theme.dart';
import 'student_row_widget.dart';

class StudentsTableWidget extends StatelessWidget {
  const StudentsTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: ObsidianTheme.primary));
        }

        List<DataColumn> tableColumns = [
          const DataColumn(
            label: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: ObsidianTheme.textSecondary)),
          ),
          const DataColumn(
            label: Text('MISSED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: ObsidianTheme.textSecondary)),
          ),
          const DataColumn(
            label: Text('WHATSAPP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: ObsidianTheme.textSecondary)),
          ),
          const DataColumn(
            label: Text('REPORT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: ObsidianTheme.textSecondary)),
          ),
        ];

        for (String assignment in provider.assignments) {
          final deadline = provider.deadlines[assignment];
          final labelText = deadline != null && deadline.isNotEmpty ? '${assignment.toUpperCase()}\n($deadline)' : assignment.toUpperCase();
          
          tableColumns.add(
            DataColumn(
              label: Text(
                labelText,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: ObsidianTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Container(
          color: ObsidianTheme.background,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: ObsidianTheme.borderWhite,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(ObsidianTheme.surfaceRecessed),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return ObsidianTheme.surfaceHover;
                      }
                      return ObsidianTheme.background;
                    },
                  ),
                  showCheckboxColumn: false,
                  headingRowHeight: 48,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 56,
                  columns: tableColumns,
                  rows: provider.filteredStudents
                      .map((s) => buildStudentRow(context, s, provider))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
