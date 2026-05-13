import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/modern_styles.dart';
import 'student_row_widget.dart';

class StudentsTableWidget extends StatelessWidget {
  const StudentsTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DataColumn> tableColumns = [
          const DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const DataColumn(
            label: Text('Missed', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const DataColumn(
            label: Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const DataColumn(
            label: Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ];

        for (String assignment in provider.assignments) {
          tableColumns.add(
            DataColumn(
              label: Text(
                assignment,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: ModernStyles.glassPanel(context),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return Theme.of(context).colorScheme.primary.withOpacity(0.05);
                          }
                          return null;
                        },
                      ),
                      showCheckboxColumn: true,
                      columns: tableColumns,
                      rows: provider.filteredStudents
                          .map((s) => buildStudentRow(context, s, provider))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
