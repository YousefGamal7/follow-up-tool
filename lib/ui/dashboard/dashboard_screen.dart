import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:send_message/theme/modern_styles.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return Scaffold(
          extendBodyBehindAppBar: false,
          backgroundColor: ModernStyles.blueRouteBackground,
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: ModernStyles.blueRouteSidebar,
                  child: const SafeArea(child: FilterSidebarWidget()),
                ),
          appBar: AppBar(
            backgroundColor: ModernStyles.blueRouteBackground,
            elevation: 0,
            title: Row(
              children: [
                Image.asset('assets/images/route.png', height: 48, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white)),
                const SizedBox(width: 12),
                Text(
                  isDesktop ? 'Blue Route Student Dashboard' : 'Dashboard',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
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
              Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    onPressed: provider.clearSentHistory,
                    icon: const Icon(LucideIcons.refreshCcw),
                    tooltip: "Reset Sent History",
                  );
                },
              ),
              Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    onPressed: () => provider.clearLocalCache(context),
                    icon: const Icon(LucideIcons.trash2),
                    tooltip: "Clear Local Cache",
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: ModernStyles.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: isDesktop
                    ? Row(
                        children: const [
                          SizedBox(width: 300, child: FilterSidebarWidget()),
                          Expanded(
                            child: StudentsTableWidget(),
                          ),
                        ],
                      )
                    : const StudentsTableWidget(),
              ),
            ),
          ),
        );
      },
    );
  }
}
