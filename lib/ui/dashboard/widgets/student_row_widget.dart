import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/obsidian_theme.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'screenshot_dialog.dart';
import 'student_details_dialog.dart';

DataRow buildStudentRow(
  BuildContext context,
  Student s,
  DashboardProvider provider,
) {
  final isSelected = provider.selectedStudents.contains(s);
  final alreadySent = provider.sentPhones.contains(s.phone);

  List<DataCell> rowCells = [
    DataCell(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => StudentDetailsDialog(student: s),
          );
        },
        child: Row(
          children: [
            Text(
              s.name,
              style: const TextStyle(
                color: ObsidianTheme.textPrimary,
                fontSize: 13,
              ),
            ),
            if (alreadySent)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  LucideIcons.checkCircle2,
                  color: ObsidianTheme.success,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    ),
    DataCell(
      Text(
        "${s.missedCount}",
        style: TextStyle(
          color: s.missedCount > 0 ? ObsidianTheme.warning : ObsidianTheme.textSecondary,
          fontWeight: s.missedCount > 0 ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    ),
    DataCell(
      OutlinedButton(
        onPressed: () => showFollowUpDialog(context, s, provider),
        style: OutlinedButton.styleFrom(
          foregroundColor: ObsidianTheme.warning,
          side: const BorderSide(color: ObsidianTheme.warning, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 32),
        ),
        child: const Text('Message', style: TextStyle(fontSize: 11)),
      ),
    ),
    DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.copy, color: ObsidianTheme.textMuted, size: 16),
            tooltip: 'Copy Email',
            onPressed: () {
              final email = s.email ?? '${s.name.replaceAll(' ', '')}@gmail.com';
              Clipboard.setData(ClipboardData(text: email));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email copied: $email')));
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.camera, color: ObsidianTheme.textMuted, size: 16),
            tooltip: 'Generate visual student report',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ScreenshotDialog(
                  student: s,
                  assignments: provider.assignments,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.minusSquare, color: ObsidianTheme.textMuted, size: 16),
            tooltip: 'Excuse from assignments',
            onPressed: () => showExcuseDialog(context, s, provider),
          ),
          IconButton(
            icon: const Icon(LucideIcons.xCircle, color: ObsidianTheme.textMuted, size: 16),
            tooltip: 'Mark No Answer',
            onPressed: () => showNoAnswerDialog(context, s, provider),
          ),
        ],
      ),
    ),
  ];

  for (String assignment in provider.assignments) {
    String cellGrade = s.allGrades[assignment] ?? "";
    bool isMissing = cellGrade.isEmpty;
    Color badgeColor;
    if (isMissing) {
      badgeColor = ObsidianTheme.surfaceRecessed;
    } else {
      double? val = double.tryParse(cellGrade);
      if (val != null && val >= 9) {
        badgeColor = ObsidianTheme.primary;
      } else {
        badgeColor = ObsidianTheme.primaryHover; // Slightly darker for lower grades
      }
    }

    rowCells.add(
      DataCell(
        Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              cellGrade,
              style: TextStyle(
                color: isMissing ? Colors.transparent : ObsidianTheme.background,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  return DataRow(
    selected: isSelected,
    cells: rowCells,
  );
}

void showExcuseDialog(BuildContext context, Student s, DashboardProvider provider) {
  List<String> selectedAssignments = [];
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Excuse ${s.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdaptiveTextField(
                    controller: provider.excuseReasonController,
                    placeholder: 'Reason for excuse',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  const Text('Select Assignments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: provider.assignments.map((assignment) {
                        return AdaptiveListTile(
                          title: Text(assignment),
                          trailing: AdaptiveCheckbox(
                            value: selectedAssignments.contains(assignment),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedAssignments.add(assignment);
                                } else {
                                  selectedAssignments.remove(assignment);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedAssignments.contains(assignment)) {
                                selectedAssignments.remove(assignment);
                              } else {
                                selectedAssignments.add(assignment);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AdaptiveButton(
                label: 'Cancel',
                style: AdaptiveButtonStyle.tinted,
                onPressed: () => Navigator.pop(context),
              ),
              AdaptiveButton(
                label: 'Apply Excuse',
                style: AdaptiveButtonStyle.filled,
                onPressed: () {
                  Navigator.pop(context);
                  provider.excuseStudent(context, s, selectedAssignments);
                },
              ),
            ],
          );
        }
      );
    },
  );
}

void showNoAnswerDialog(BuildContext context, Student s, DashboardProvider provider) {
  List<String> selectedAssignments = [];
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Mark No Answer for ${s.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Assignments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: provider.assignments.map((assignment) {
                        return AdaptiveListTile(
                          title: Text(assignment),
                          trailing: AdaptiveCheckbox(
                            value: selectedAssignments.contains(assignment),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedAssignments.add(assignment);
                                } else {
                                  selectedAssignments.remove(assignment);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedAssignments.contains(assignment)) {
                                selectedAssignments.remove(assignment);
                              } else {
                                selectedAssignments.add(assignment);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AdaptiveButton(
                label: 'Cancel',
                style: AdaptiveButtonStyle.tinted,
                onPressed: () => Navigator.pop(context),
              ),
              AdaptiveButton(
                label: 'Apply No Answer',
                style: AdaptiveButtonStyle.filled,
                onPressed: () {
                  Navigator.pop(context);
                  provider.noAnswerStudent(context, s, selectedAssignments);
                },
              ),
            ],
          );
        }
      );
    },
  );
}

void showFollowUpDialog(BuildContext context, Student s, DashboardProvider provider) {
  List<String> selectedAssignments = [];
  String generatedMessage = provider.generateMessage(s);
  String baseMessage = generatedMessage;
  TextEditingController messageController = TextEditingController(text: generatedMessage);

  void updateMessageWithAssignments() {
    if (selectedAssignments.isEmpty) {
      messageController.text = baseMessage;
    } else {
      final assignmentsList = selectedAssignments.join(', ');
      messageController.text = '$baseMessage\n\nAssignments: $assignmentsList';
    }
  }
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Follow Up: ${s.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdaptiveTextField(
                    controller: messageController,
                    placeholder: 'WhatsApp Message',
                    maxLines: 4,
                    minLines: 4,
                    onChanged: (value) {
                      if (selectedAssignments.isEmpty) {
                        baseMessage = value;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Select Assignments to Follow Up:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: provider.assignments.map((assignment) {
                        return AdaptiveListTile(
                          title: Text(assignment),
                          trailing: AdaptiveCheckbox(
                            value: selectedAssignments.contains(assignment),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedAssignments.add(assignment);
                                } else {
                                  selectedAssignments.remove(assignment);
                                }
                                updateMessageWithAssignments();
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedAssignments.contains(assignment)) {
                                selectedAssignments.remove(assignment);
                              } else {
                                selectedAssignments.add(assignment);
                              }
                              updateMessageWithAssignments();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AdaptiveButton(
                label: 'Cancel',
                style: AdaptiveButtonStyle.tinted,
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AdaptiveButton(
                    label: 'WhatsApp',
                    style: AdaptiveButtonStyle.filled,
                    onPressed: () {
                      Navigator.pop(context);
                      provider.launchWhatsAppWeb(s, context, selectedAssignments, messageController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                  AdaptiveButton(
                    label: 'Telegram',
                    style: AdaptiveButtonStyle.filled,
                    onPressed: () {
                      Navigator.pop(context);
                      provider.launchTelegramWeb(s, context, selectedAssignments, messageController.text);
                    },
                  ),
                ],
              ),
            ],
          );
        }
      );
    },
  );
}
