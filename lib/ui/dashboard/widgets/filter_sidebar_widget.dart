import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/obsidian_theme.dart';
import 'history_log_widget.dart';

class FilterSidebarWidget extends StatelessWidget {
  const FilterSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ObsidianTheme.background,
        border: Border(
          right: BorderSide(color: ObsidianTheme.borderWhite),
        ),
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
                      "Cycle",
                      provider.availableCycles,
                      provider.selectedCycle,
                      (val) {
                        if (val != null) {
                          provider.setCycle(val);
                          context.read<DashboardCubit>().setCycle(val);
                        }
                      },
                    ),
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
                    const Divider(height: 30, color: ObsidianTheme.borderWhite, thickness: 1),
                    Row(
                      children: const [
                        Icon(LucideIcons.mail, size: 16, color: ObsidianTheme.warning),
                        SizedBox(width: 8),
                        Text(
                          "Message Template",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ObsidianTheme.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Template ID: #04",
                          style: TextStyle(fontSize: 10, color: ObsidianTheme.textMuted),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            title: 'Male',
                            isSelected: provider.isMaleTemplate,
                            onTap: () => provider.toggleTemplateGender(true),
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            title: 'Female',
                            isSelected: !provider.isMaleTemplate,
                            onTap: () => provider.toggleTemplateGender(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (provider.savedTemplates.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ObsidianTheme.surfaceRecessed,
                          border: Border.all(color: ObsidianTheme.borderWhite),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: ObsidianTheme.surfaceCard,
                            iconEnabledColor: ObsidianTheme.textSecondary,
                            hint: const Text('Select a saved template...', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
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
                                    child: Text(e, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 12)),
                                  ),
                                )
                                .toList(),
                            onChanged: provider.selectTemplate,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: ObsidianTheme.surfaceRecessed,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ObsidianTheme.borderWhite),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: provider.templateController,
                        maxLines: 4,
                        minLines: 4,
                        style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 13),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Hey [Name], you missed [Missed] tasks",
                          hintStyle: TextStyle(color: ObsidianTheme.textMuted, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => provider.saveTemplate(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ObsidianTheme.warning,
                          side: const BorderSide(color: ObsidianTheme.borderWhite),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(LucideIcons.save, size: 16),
                        label: const Text('Save Template', style: TextStyle(fontSize: 13, color: ObsidianTheme.textSecondary)),
                      ),
                    ),
                    const Divider(height: 30, color: ObsidianTheme.borderWhite, thickness: 1),
                    Row(
                      children:  [
                        Icon(LucideIcons.ticket, size: 16, color: ObsidianTheme.warning),
                        SizedBox(width: 8),
                        Text(
                          "Dynamic Tickets & Sync",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ObsidianTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDrop(
                      context,
                      "Target Task",
                      provider.dynamicTasks,
                      provider.selectedDynamicTask,
                      provider.setDynamicTask,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : () {
                          if (provider.selectedDynamicTask != null) {
                            provider.syncGradesToStatus(provider.selectedDynamicTask!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ObsidianTheme.primary,
                          foregroundColor: ObsidianTheme.background,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: ObsidianTheme.primary.withValues(alpha: 0.5),
                        ),
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: const Text('Sync + Mark Submitted', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Icon(LucideIcons.fileText, size: 16, color: ObsidianTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          "Activity History",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ObsidianTheme.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Icon(LucideIcons.circle, size: 8, color: ObsidianTheme.success),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                  color: ObsidianTheme.background,
                  border: const Border(
                    top: BorderSide(color: ObsidianTheme.borderWhite),
                    right: BorderSide(color: ObsidianTheme.borderWhite),
                  ),
                ),
                child: Text(
                  "${provider.selectedStudents.length} Students Selected",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: ObsidianTheme.primary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ObsidianTheme.primary : ObsidianTheme.background,
          border: Border.all(color: ObsidianTheme.primary),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? ObsidianTheme.background : ObsidianTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
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
              color: ObsidianTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 38,
            decoration: BoxDecoration(
              color: ObsidianTheme.surfaceRecessed,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ObsidianTheme.borderWhite),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: ObsidianTheme.surfaceCard,
                iconEnabledColor: ObsidianTheme.textSecondary,
                value: (items.contains(val))
                    ? val
                    : (items.isNotEmpty ? items[0] : null),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: ObsidianTheme.textPrimary)),
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
