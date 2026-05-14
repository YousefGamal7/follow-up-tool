import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import 'widgets/filter_sidebar_widget.dart';
import 'widgets/students_table_widget.dart';
import 'weekly_report_screen.dart';
import 'advanced_team_report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Smart Student Tracking System'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.barChart2),
            tooltip: 'Advanced Report',
            onPressed: () {
              final dashboardProvider = context.read<DashboardProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    final groups = dashboardProvider.groups.where((g) => g != 'All').toList();
                    return AdvancedTeamReportScreen(
                      instructor: dashboardProvider.selectedInstructor ?? 'Yousef Gamal',
                      groups: groups.isNotEmpty ? groups : ['Group 1 : Friday 10Am ( Dokki )'],
                      initialGroup: dashboardProvider.selectedGroup == 'All' || dashboardProvider.selectedGroup == null
                          ? (groups.isNotEmpty ? groups.first : 'Group 1 : Friday 10Am ( Dokki )')
                          : dashboardProvider.selectedGroup!,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.calendar),
            tooltip: 'Weekly Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyReportScreen(),
                ),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                ),
                tooltip: 'Toggle Theme',
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.clearSentHistory,
                icon: const Icon(LucideIcons.refreshCcw),
                tooltip: "Reset Sent History",
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1E1114), const Color(0xFF0F1115), const Color(0xFF181014)]
              : [const Color(0xFFFFF5F5), const Color(0xFFF8F9FA), const Color(0xFFFEF0F0)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: const [
              FilterSidebarWidget(),
              Expanded(
                child: StudentsTableWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
