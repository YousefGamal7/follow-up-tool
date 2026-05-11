import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/filter_sidebar_widget.dart';
import 'widgets/students_table_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Student Tracking System'),
        actions: [
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.clearSentHistory,
                icon: const Icon(Icons.refresh),
                tooltip: "Reset Sent History",
              );
            },
          ),
        ],
      ),
      body: Row(
        children: const [
          FilterSidebarWidget(),
          Expanded(
            child: StudentsTableWidget(),
          ),
        ],
      ),
    );
  }
}
