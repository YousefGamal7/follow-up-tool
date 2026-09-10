import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: ObsidianTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('WORKSPACES', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
            const SizedBox(width: 8),
            const Text('FLUTTER COHORT 4', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 14, color: ObsidianTheme.textMuted),
            const SizedBox(width: 8),
            const Text('WORKSHOP TIMETABLE', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('Workshops & Sessions', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ObsidianTheme.surfaceRecessed,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ObsidianTheme.borderWhite),
                  ),
                  child: const Text('10 Total', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  color: ObsidianTheme.textSecondary,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.download, size: 16),
                  label: const Text('Export PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObsidianTheme.textPrimary,
                    side: const BorderSide(color: ObsidianTheme.borderWhite),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('New Workshop'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tabs
            Row(
              children: [
                _buildTab('Assignments', LucideIcons.fileText, false),
                _buildTab('Workshops', LucideIcons.monitorPlay, true),
                _buildTab('Attendance', LucideIcons.users, false),
                const Spacer(),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: ObsidianTheme.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Auto-synced with Google Calendar', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Divider(color: ObsidianTheme.borderWhite, height: 1),
            const SizedBox(height: 24),
            // Filters
            Row(
              children: [
                _buildGroupPill('Group 1', true),
                const SizedBox(width: 8),
                _buildGroupPill('Group 2', false),
                const SizedBox(width: 8),
                _buildGroupPill('Archived', false),
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search workshop by topic, mentor, or keyword...',
                        prefixIcon: const Icon(LucideIcons.search, size: 16),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: ObsidianTheme.surfaceRecessed,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ObsidianTheme.borderWhite),
                  ),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(LucideIcons.list, size: 16), color: ObsidianTheme.primary, onPressed: () {}),
                      IconButton(icon: const Icon(LucideIcons.grid, size: 16), color: ObsidianTheme.textMuted, onPressed: () {}),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.filter, size: 16),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObsidianTheme.textPrimary,
                    side: const BorderSide(color: ObsidianTheme.borderWhite),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: Text('SESSION TOPIC & TRACK', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  const Expanded(flex: 2, child: Text('SCHEDULE DATE', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  const Expanded(flex: 2, child: Text('TIME WINDOW', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  const SizedBox(width: 120, child: Text('ENROLLED', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                  const SizedBox(width: 100, child: Text('ACTIONS', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                ],
              ),
            ),
            // Workshop List Items
            _buildWorkshopRow(
              icon: LucideIcons.bellRing,
              title: 'FCM',
              isUpcoming: true,
              subtitle: 'Firebase Cloud Messaging & Background Services',
              date: '7/9/2026',
              day: 'Monday',
              time: '6:10 PM - 7:30 PM',
              duration: '80m',
              attendees: 1,
            ),
            const SizedBox(height: 12),
            _buildWorkshopRow(
              icon: LucideIcons.checkCircle2,
              title: 'EventlyTasks',
              subtitle: 'State Management & Bloc Architecture',
              date: '31/8/2026',
              day: 'Monday',
              time: '6:00 PM - 7:30 PM',
              duration: '90m',
              attendees: 2,
            ),
            const SizedBox(height: 12),
            _buildWorkshopRow(
              icon: LucideIcons.shieldCheck,
              title: 'Google login',
              subtitle: 'OAuth 2.0 Integration & Firebase Auth',
              date: '24/8/2026',
              day: 'Monday',
              time: '5:10 PM - 6:15 PM',
              duration: '65m',
              attendees: 3,
            ),
            const SizedBox(height: 12),
            _buildWorkshopRow(
              icon: LucideIcons.radio,
              title: 'Contact pt 2 &Islami',
              subtitle: 'Navigation Routes & Audio Streaming Module',
              date: '17/8/2026',
              day: 'Monday',
              time: '6:00 PM - 7:30 PM',
              duration: '90m',
              attendees: 2,
            ),
            const SizedBox(height: 24),
            // Bottom Panels
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildCohortEngagementMatrix()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildNextActiveSession()),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? ObsidianTheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? ObsidianTheme.primary : ObsidianTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? ObsidianTheme.primary : ObsidianTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupPill(String title, bool isSelected) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.surfaceHover : ObsidianTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ObsidianTheme.borderBlue.withOpacity(0.5) : ObsidianTheme.borderWhite,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? ObsidianTheme.textPrimary : ObsidianTheme.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopRow({
    required IconData icon,
    required String title,
    bool isUpcoming = false,
    required String subtitle,
    required String date,
    required String day,
    required String time,
    required String duration,
    required int attendees,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ObsidianTheme.cardDecoration,
      child: Row(
        children: [
          // Icon & Topic
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ObsidianTheme.surfaceRecessed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ObsidianTheme.borderWhite),
                  ),
                  child: Icon(icon, color: ObsidianTheme.textSecondary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                          if (isUpcoming) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ObsidianTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ObsidianTheme.primary.withOpacity(0.3)),
                              ),
                              child: const Text('Upcoming', style: TextStyle(color: ObsidianTheme.primaryHover, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Schedule Date
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(LucideIcons.calendar, size: 14, color: ObsidianTheme.textMuted),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Text(day, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          // Time Window
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: ObsidianTheme.textMuted),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Text(duration, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // Enrolled
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ObsidianTheme.surfaceRecessed,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ObsidianTheme.borderWhite),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.users, size: 14, color: ObsidianTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text('$attendees attendees', style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(icon: const Icon(LucideIcons.edit2, size: 16), color: ObsidianTheme.textSecondary, onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.moreVertical, size: 16), color: ObsidianTheme.textSecondary, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCohortEngagementMatrix() {
    return Container(
      decoration: ObsidianTheme.cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.barChart2, color: ObsidianTheme.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  const Text('Cohort Engagement Matrix', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ObsidianTheme.surfaceRecessed,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ObsidianTheme.borderWhite),
                ),
                child: const Text('Updated Today', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance Rate (Summer Term)', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
              const Text('92.4% Average', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceRecessed,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: 0.924,
              child: Container(
                decoration: BoxDecoration(
                  color: ObsidianTheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder for the legacy workshop log image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceRecessed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ObsidianTheme.borderWhite),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(LucideIcons.image, size: 48, color: ObsidianTheme.borderWhite),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Legacy Workshop Log', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const Text('Archived database view from Route Core v2.1', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ObsidianTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ObsidianTheme.borderWhite),
                    ),
                    child: const Text('Expand View', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextActiveSession() {
    return Container(
      decoration: ObsidianTheme.cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Next Active Session Room', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: ObsidianTheme.primary, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceRecessed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ObsidianTheme.borderWhite),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VIRTUAL ROOM', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const Text('G-MEET #841-392', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('FCM & Push Notifications', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Session starting in 4 days. 1 RSVP confirmed.', style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.copy, size: 16),
                  label: const Text('Copy Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObsidianTheme.textPrimary,
                    side: const BorderSide(color: ObsidianTheme.borderWhite),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.video, size: 16),
                  label: const Text('Launch Meet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
