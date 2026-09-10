import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Welcome Banner
          _buildHeroBanner(),
          const SizedBox(height: 24),
          // Top Metric Cards Grid
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          // Main Section (Two Columns on Desktop)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildMonthlyWorkshops()),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: _buildOfficeHours()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildMonthlyWorkshops(),
                  const SizedBox(height: 24),
                  _buildOfficeHours(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ObsidianTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ObsidianTheme.borderBlue.withOpacity(0.5)),
        gradient: LinearGradient(
          colors: [
            ObsidianTheme.primary.withOpacity(0.1),
            ObsidianTheme.surfaceRecessed,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Welcome Back, Yousef Gamal 👋',
                    style: TextStyle(
                      color: ObsidianTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ObsidianTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ObsidianTheme.secondary.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Active Term: C19',
                      style: TextStyle(color: ObsidianTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Here is what is happening with your students today.',
                style: TextStyle(color: ObsidianTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Refresh Feed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ObsidianTheme.surfaceHover,
              foregroundColor: ObsidianTheme.textPrimary,
              side: const BorderSide(color: ObsidianTheme.borderWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth >= 800 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildMetricCard('My Groups', '4', 'Active', LucideIcons.users, ObsidianTheme.primary),
            _buildMetricCard('Live Workshops', '0', 'Ongoing', LucideIcons.video, ObsidianTheme.warning),
            _buildMetricCard("Today's Groups", '1', 'Tonight', LucideIcons.calendarCheck, ObsidianTheme.success),
            _buildMetricCard('Monthly Workshops', '2/mo', 'Target', LucideIcons.target, ObsidianTheme.secondary),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ObsidianTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyWorkshops() {
    return Container(
      decoration: ObsidianTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Workshops', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('New Workshop'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Empty State
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.calendarX, size: 48, color: ObsidianTheme.textMuted.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('No workshops scheduled for this month.', style: TextStyle(color: ObsidianTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeHours() {
    return Container(
      decoration: ObsidianTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Office Hours', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.surfaceHover,
                    foregroundColor: ObsidianTheme.primary,
                    side: const BorderSide(color: ObsidianTheme.borderWhite),
                  ),
                  child: const Text('Exception Time'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.warningBadgeBg,
                    foregroundColor: ObsidianTheme.warningBadgeText,
                  ),
                  child: const Text('Request Cancel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildScheduleItem('Monday', 'Google Meet', '8:00 PM - 10:00 PM'),
          const Divider(color: ObsidianTheme.borderWhite, height: 24),
          _buildScheduleItem('Wednesday', 'Dokki Branch', '6:00 PM - 9:00 PM'),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String location, String time) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceRecessed,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ObsidianTheme.borderWhite),
          ),
          alignment: Alignment.center,
          child: Text(day.substring(0, 3), style: const TextStyle(color: ObsidianTheme.primary, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location, style: const TextStyle(color: ObsidianTheme.textPrimary, fontWeight: FontWeight.w600)),
              Text(time, style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.arrowRight, size: 20),
          color: ObsidianTheme.textSecondary,
          onPressed: () {},
        ),
      ],
    );
  }
}
