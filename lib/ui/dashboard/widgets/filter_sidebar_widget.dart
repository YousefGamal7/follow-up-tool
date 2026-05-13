import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/modern_styles.dart';
import 'history_log_widget.dart';

class FilterSidebarWidget extends StatelessWidget {
  const FilterSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 320,
          margin: const EdgeInsets.all(16),
          decoration: ModernStyles.glassPanel(context),
          child: Column(
            children: [
              Expanded(
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildDrop(
                          context,
                          "Instructor",
                          provider.instructors,
                          provider.selectedInstructor,
                          provider.setInstructor,
                        ),
                        _buildDrop(
                          context,
                          "Group",
                          provider.groups,
                          provider.selectedGroup,
                          provider.setGroup,
                        ),
                        _buildDrop(
                          context,
                          "Task Filter",
                          provider.assignments,
                          provider.selectedAssignment,
                          provider.setAssignment,
                        ),
                        _buildDrop(
                          context,
                          "Filter Status",
                          provider.filters,
                          provider.selectedFilter,
                          provider.setFilter,
                        ),
                        const Divider(height: 30, thickness: 2),
                        Text(
                          "📝 Message Template",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (provider.savedTemplates.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                              color: Theme.of(context).cardColor.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text('Select a saved template...'),
                                value:
                                    provider.savedTemplates.contains(
                                      provider.selectedTemplate,
                                    )
                                    ? provider.selectedTemplate
                                    : null,
                                items: provider.savedTemplates
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: provider.selectTemplate,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: provider.templateController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Hey [Name], you missed [Missed] tasks",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Theme.of(context).cardColor.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => provider.saveTemplate(context),
                          icon: const Icon(LucideIcons.save),
                          label: const Text('Save Template'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const Divider(height: 30, thickness: 2),
                        Text(
                          "🎟️ Dynamic Tickets & Sync",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDrop(
                          context,
                          "Target Task",
                          provider.dynamicTasks,
                          provider.selectedDynamicTask,
                          provider.setDynamicTask,
                        ),
                        Container(
                          decoration: ModernStyles.glowingContainer(context, glowColor: const Color(0xFF2ECC71)),
                          child: ElevatedButton.icon(
                            onPressed: provider.isLoading ? null : () {
                              if (provider.selectedDynamicTask != null) {
                                provider.syncGradesToStatus(provider.selectedDynamicTask!);
                              }
                            },
                            icon: const Icon(LucideIcons.checkCheck),
                            label: const Text('Sync → Mark Submitted'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: const Color(0xFF2ECC71),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 200, child: HistoryLogWidget()),
                      ],
                    );
                  },
                ),
              ),
              Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    child: Text(
                      "${provider.selectedStudents.length} Students Selected",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrop(
    BuildContext context,
    String label,
    List<String> items,
    String? val,
    Function(String?) onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: (items.contains(val))
                  ? val
                  : (items.isNotEmpty ? items[0] : null),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChange,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
