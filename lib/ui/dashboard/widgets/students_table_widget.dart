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
          DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))),
          ),
          DataColumn(
            label: Text('Missed', style: TextStyle(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))),
          ),
          DataColumn(
            label: Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))),
          ),
          DataColumn(
            label: Text('Report', style: TextStyle(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context))),
          ),
        ];

        for (String assignment in provider.assignments) {
          tableColumns.add(
            DataColumn(
              label: Text(
                assignment,
                style: TextStyle(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context)),
              ),
            ),
          );
        }

        return Container(
          color: ModernStyles.getCardColor(context),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(ModernStyles.getCardColor(context)),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return ModernStyles.blueRouteButton.withOpacity(0.05);
                    }
                    return null;
                  },
                ),
                showCheckboxColumn: false,
                columns: tableColumns,
                rows: provider.filteredStudents
                    .map((s) => buildStudentRow(context, s, provider))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
