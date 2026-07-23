import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/modern_styles.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:send_message/ui/project_viewer/project_viewer_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'widgets/filter_sidebar_widget.dart';
import 'widgets/students_table_widget.dart';
import 'widgets/student_search_bottom_sheet.dart';
import 'weekly_report_screen.dart';
import 'advanced_team_report_screen.dart';

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
                  final dashboardCubit = context.read<DashboardCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final groups = dashboardCubit.state.groups.where((g) => g != 'All').toList();
                        return AdvancedTeamReportScreen(
                          instructor: dashboardCubit.state.selectedInstructor ?? 'Yousef Gamal',
                          cycleName: dashboardCubit.state.selectedCycle,
                          groups: groups.isNotEmpty ? groups : ['Group 1 : Friday 10Am ( Dokki )'],
                          initialGroup: dashboardCubit.state.selectedGroup == 'All' || dashboardCubit.state.selectedGroup == null
                              ? (groups.isNotEmpty ? groups.first : 'Group 1 : Friday 10Am ( Dokki )')
                              : dashboardCubit.state.selectedGroup!,
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
                onPressed: context.read<DashboardCubit>().clearSentHistory,
                icon: LucideIcons.refreshCcw,
                iosSymbol: 'arrow.clockwise',
              ),
              AdaptiveAppBarAction(
                onPressed: () => context.read<DashboardCubit>().clearLocalCache(),
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
