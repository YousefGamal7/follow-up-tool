import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';
import 'group_details_screen.dart';

class MyGroupsScreen extends StatelessWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by shell
      appBar: AppBar(
        title: const Text('My Groups', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are assigned to 4 active groups this cycle.',
              style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildGroupCard(context, 'Group 1', 'Friday 10:00 AM', 32, 'Flutter Cohort 4'),
                  _buildGroupCard(context, 'Group 2', 'Saturday 10:00 AM', 28, 'Flutter Cohort 4'),
                  _buildGroupCard(context, 'Group 3', 'Monday 6:00 PM', 30, 'Flutter Cohort 4'),
                  _buildGroupCard(context, 'Group 4', 'Wednesday 6:00 PM', 25, 'Flutter Cohort 4'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, String title, String schedule, int students, String cohort) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GroupDetailsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ObsidianTheme.cardHoverDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ObsidianTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ObsidianTheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(cohort, style: const TextStyle(color: ObsidianTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Icon(LucideIcons.arrowRight, size: 16, color: ObsidianTheme.textSecondary),
              ],
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.calendar, size: 14, color: ObsidianTheme.textMuted),
                const SizedBox(width: 6),
                Text(schedule, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.users, size: 14, color: ObsidianTheme.textMuted),
                const SizedBox(width: 6),
                Text('$students Students', style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
