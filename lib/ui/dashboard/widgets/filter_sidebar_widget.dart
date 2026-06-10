import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/modern_styles.dart';
import 'history_log_widget.dart';

class FilterSidebarWidget extends StatelessWidget {
  const FilterSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ModernStyles.blueRouteSidebar,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDrop(
                      context,
                      "Mentor",
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
                    const Divider(height: 30, color: Colors.white24, thickness: 1),
                    const Text(
                      "📝 Message Template",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (provider.savedTemplates.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: ModernStyles.blueRouteBackground,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: ModernStyles.blueRouteSidebar,
                            iconEnabledColor: Colors.white,
                            hint: const Text('Select a saved template...', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                                    child: Text(e, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Hey [Name], you missed [Missed] tasks",
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: ModernStyles.blueRouteBackground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => provider.saveTemplate(context),
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: const Text('Save Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                    const Divider(height: 30, color: Colors.white24, thickness: 1),
                    const Text(
                      "🎟️ Dynamic Tickets & Sync",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
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
                    ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : () {
                        if (provider.selectedDynamicTask != null) {
                          provider.syncGradesToStatus(provider.selectedDynamicTask!);
                        }
                      },
                      icon: const Icon(LucideIcons.checkCheck, size: 16),
                      label: const Text('Sync + Mark Submitted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernStyles.blueRouteButton,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "📄 Activity History",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white24)),
                ),
                child: Text(
                  "${provider.selectedStudents.length} Students Selected",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: Colors.white,
                iconEnabledColor: ModernStyles.blueRouteSidebar,
                value: (items.contains(val))
                    ? val
                    : (items.isNotEmpty ? items[0] : null),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 12, color: ModernStyles.blueRouteDarkText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
