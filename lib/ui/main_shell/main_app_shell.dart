import 'package:flutter/material.dart';
import 'package:send_message/theme/obsidian_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/ui/dashboard/mentor_dashboard_screen.dart';
import 'package:send_message/ui/dashboard/my_cycles_screen.dart';
import 'package:send_message/ui/dashboard/advanced_team_report_screen.dart';
import '../dashboard/dashboard_screen.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0; // Default to Mentor Dashboard for now
  bool _isSidebarExpanded = true;

  final List<Widget> _screens = [
    const MentorDashboardScreen(),
    const DashboardScreen(), // Student Dashboard Matrix
    const MyCyclesScreen(),
    const AdvancedTeamReportScreen(
      instructor: 'Yousef Gamal',
      cycleName: 'C19',
      groups: ['All'],
      initialGroup: 'All',
    ),
    const Center(child: Text('History')),
    const Center(child: Text('Exception Sessions')),
    const Center(child: Text('Assignments')),
    const Center(child: Text('Assignment Gradebook')),
    const Center(child: Text('Follow-ups')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      body: Row(
        children: [
          // Left Persistent Sidebar
          _buildSidebar(),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Global Utility Header
                _buildTopHeader(),
                // Screen Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                    child: Container(
                      color: ObsidianTheme.surfaceRecessed,
                      child: _screens[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 260 : 80,
      color: ObsidianTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(LucideIcons.hexagon, color: ObsidianTheme.primary, size: 28),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Route',
                      style: TextStyle(
                        color: ObsidianTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(_isSidebarExpanded ? LucideIcons.chevronsLeft : LucideIcons.chevronsRight),
                  color: ObsidianTheme.textSecondary,
                  onPressed: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(color: ObsidianTheme.borderWhite),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                if (_isSidebarExpanded) _buildSectionHeader('MAIN'),
                _buildNavItem(0, 'Dashboard', LucideIcons.layoutGrid),
                
                if (_isSidebarExpanded) _buildSectionHeader('STUDENTS'),
                _buildNavItem(1, 'Student Dashboard', LucideIcons.users),
                
                if (_isSidebarExpanded) _buildSectionHeader('GROUPS & SESSIONS'),
                _buildNavItem(2, 'My Cycles', LucideIcons.folder),
                _buildNavItem(3, 'Advanced Report', LucideIcons.barChart),
                _buildNavItem(4, 'History', LucideIcons.history),
                
                if (_isSidebarExpanded) _buildSectionHeader('ACTIONS'),
                _buildNavItem(5, 'Exception Sessions', LucideIcons.alertCircle),
                _buildNavItem(6, 'Assignments', LucideIcons.fileText),
                _buildNavItem(7, 'Assignment Gradebook', LucideIcons.bookOpen),
                _buildNavItem(8, 'Follow-ups', LucideIcons.messageCircle),
              ],
            ),
          ),
          
          // Footer
          if (_isSidebarExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: ObsidianTheme.borderWhite)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ObsidianTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Route Core ID: #4092',
                    style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: ObsidianTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.surfaceHover : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: ObsidianTheme.borderBlue.withOpacity(0.3))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? ObsidianTheme.primary : ObsidianTheme.textSecondary,
            ),
            if (_isSidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? ObsidianTheme.primaryHover : ObsidianTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: ObsidianTheme.background,
      child: Row(
        children: [
          // Global Search
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ObsidianTheme.surfaceRecessed,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ObsidianTheme.borderWhite),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(LucideIcons.search, size: 18, color: ObsidianTheme.textMuted),
                  const SizedBox(width: 8),
                  const Text(
                    '⌘K Search batches, sessions, or students...',
                    style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Actions
          IconButton(
            icon: const Icon(LucideIcons.barChart2, size: 20),
            color: ObsidianTheme.textSecondary,
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.calendar, size: 20),
            color: ObsidianTheme.textSecondary,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.moon, size: 20), // Theme toggle
            color: ObsidianTheme.textSecondary,
            onPressed: () {},
          ),
          TextButton(
            onPressed: () {},
            child: const Text('EN', style: TextStyle(color: ObsidianTheme.textSecondary)),
          ),
          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, size: 20),
                color: ObsidianTheme.textSecondary,
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: ObsidianTheme.warning,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '13',
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Mentor Profile Chip
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ObsidianTheme.borderWhite),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: ObsidianTheme.primary,
                  child: Text('YG', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Yousef Gamal', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Lead Flutter Mentor', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronDown, size: 16, color: ObsidianTheme.textSecondary),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
