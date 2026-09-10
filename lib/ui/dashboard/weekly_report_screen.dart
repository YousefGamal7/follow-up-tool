import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          _buildTabBar(),
          const SizedBox(height: 24),
          // Group selector & Search
          _buildFilters(),
          const SizedBox(height: 24),
          // Workshop List
          Expanded(
            child: ListView(
              children: [
                _buildWorkshopItem('FCM - Firebase Cloud Messaging', 'Push notifications integration', 'Oct 12, 2026', '80m', 24),
                const SizedBox(height: 12),
                _buildWorkshopItem('EventlyTasks - Bloc Architecture', 'Advanced state management', 'Oct 15, 2026', '90m', 18),
                const SizedBox(height: 12),
                _buildWorkshopItem('Animations & Micro-interactions', 'Implicit and explicit animations', 'Oct 18, 2026', '60m', 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        _buildTab('Assignments', false),
        _buildTab('Workshops (Active)', true),
        _buildTab('Attendance', false),
      ],
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? ObsidianTheme.primary.withOpacity(0.15) : ObsidianTheme.surfaceRecessed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? ObsidianTheme.primary.withOpacity(0.5) : ObsidianTheme.borderWhite,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? ObsidianTheme.primary : ObsidianTheme.textSecondary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Group pills
        _buildGroupPill('Group 1', true),
        const SizedBox(width: 8),
        _buildGroupPill('Group 2', false),
        const SizedBox(width: 8),
        _buildGroupPill('Archived', false),
        const Spacer(),
        // Search bar
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search workshops...',
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('New Workshop'),
        ),
      ],
    );
  }

  Widget _buildGroupPill(String title, bool isSelected) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.surfaceHover : ObsidianTheme.surfaceCard,
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

  Widget _buildWorkshopItem(String title, String subtitle, String date, String duration, int attendees) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ObsidianTheme.cardDecoration,
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObsidianTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.monitorPlay, color: ObsidianTheme.primary, size: 24),
          ),
          const SizedBox(width: 20),
          // Title Track
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          // Schedule & Duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: const TextStyle(color: ObsidianTheme.textPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ObsidianTheme.surfaceRecessed,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ObsidianTheme.borderWhite),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 12, color: ObsidianTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(duration, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Attendees Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ObsidianTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ObsidianTheme.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.users, size: 14, color: ObsidianTheme.success),
                const SizedBox(width: 6),
                Text('$attendees', style: const TextStyle(color: ObsidianTheme.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Actions
          IconButton(
            icon: const Icon(LucideIcons.edit2, size: 18),
            color: ObsidianTheme.textSecondary,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.moreVertical, size: 18),
            color: ObsidianTheme.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
