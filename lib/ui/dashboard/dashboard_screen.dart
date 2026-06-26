import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/modern_styles.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/filter_sidebar_widget.dart';
import 'widgets/students_table_widget.dart';
import 'widgets/student_search_bottom_sheet.dart';
import 'weekly_report_screen.dart';
import 'advanced_team_report_screen.dart';
import '../project_viewer/project_viewer_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return AdaptiveScaffold(
          appBar: AdaptiveAppBar(
            title: isDesktop ? 'Blue Route Student Dashboard' : 'Dashboard',
            actions: [
              AdaptiveAppBarAction(
                icon: LucideIcons.search,
                iosSymbol: 'magnifyingglass',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const StudentSearchBottomSheet(),
                  );
                },
              ),
              AdaptiveAppBarAction(
                icon: LucideIcons.barChart2,
                iosSymbol: 'chart.bar',
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
              AdaptiveAppBarAction(
                icon: LucideIcons.calendar,
                iosSymbol: 'calendar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeeklyReportScreen(),
                    ),
                  );
                },
              ),
              AdaptiveAppBarAction(
                icon: LucideIcons.folderInput,
                iosSymbol: 'folder.badge.plus',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProjectViewerScreen(),
                    ),
                  );
                },
              ),
              AdaptiveAppBarAction(
                onPressed: context.read<DashboardProvider>().clearSentHistory,
                icon: LucideIcons.refreshCcw,
                iosSymbol: 'arrow.clockwise',
              ),
              AdaptiveAppBarAction(
                onPressed: () => context.read<DashboardProvider>().clearLocalCache(context),
                icon: LucideIcons.trash2,
                iosSymbol: 'trash',
              ),
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
                    : Column(
                        children: [
                          const SizedBox(height: 200, child: FilterSidebarWidget()),
                          const Expanded(child: StudentsTableWidget()),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
