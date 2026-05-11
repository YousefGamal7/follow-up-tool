import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
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

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: true,
              columns: tableColumns,
              rows: provider.filteredStudents
                  .map((s) => buildStudentRow(context, s, provider))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
