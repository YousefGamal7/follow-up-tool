import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/obsidian_theme.dart';

class HistoryLogWidget extends StatelessWidget {
  const HistoryLogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ObsidianTheme.surfaceRecessed,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ObsidianTheme.borderWhite),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.terminal, size: 14, color: ObsidianTheme.warning),
                  SizedBox(width: 6),
                  Text(
                    "Live Console",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: ObsidianTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: provider.actionLogs.isEmpty
                    ? const Center(
                        child: Text(
                          "No recent activity.",
                          style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.actionLogs.length,
                        itemBuilder: (context, index) {
                          // Try to colorize based on content (e.g. success vs error)
                          final text = provider.actionLogs[index];
                          Color textColor = ObsidianTheme.primary; // Cyan by default
                          if (text.toLowerCase().contains("error") || text.toLowerCase().contains("failed")) {
                            textColor = ObsidianTheme.warning;
                          } else if (text.toLowerCase().contains("fetched") || text.toLowerCase().contains("loaded")) {
                            textColor = ObsidianTheme.primary;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor,
                                fontFamily: 'Consolas', // monospace fallback if Consolas is unavailable
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
