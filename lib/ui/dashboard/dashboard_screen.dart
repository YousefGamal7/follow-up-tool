import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';
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
        return Container(
          color: ObsidianTheme.background,
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    // Secondary Left Control Panel (280px)
                    SizedBox(
                      width: 280,
                      child: FilterSidebarWidget(),
                    ),
                    // Main High-Density Roster Matrix
                    Expanded(
                      child: StudentsTableWidget(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(height: 200, child: FilterSidebarWidget()),
                    const Divider(height: 1, color: ObsidianTheme.borderWhite),
                    const Expanded(child: StudentsTableWidget()),
                  ],
                ),
        );
      },
    );
  }
}
