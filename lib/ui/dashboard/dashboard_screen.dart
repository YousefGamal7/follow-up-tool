import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import 'widgets/filter_sidebar_widget.dart';
import 'widgets/students_table_widget.dart';

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
