import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/modern_styles.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'screenshot_dialog.dart';

DataRow buildStudentRow(
  BuildContext context,
  Student s,
  DashboardProvider provider,
) {
  final isSelected = provider.selectedStudents.contains(s);
  final isWarning = s.missedCount >= 6;
  final alreadySent = provider.sentPhones.contains(s.phone);

  List<DataCell> rowCells = [
    DataCell(
      Row(
        children: [
          Text(
            s.name,
            style: TextStyle(
              fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
              color: ModernStyles.getTextColor(context),
            ),
          ),
          if (alreadySent)
            const Icon(
              LucideIcons.checkCircle2,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    ),
    DataCell(
      Text(
        "${s.missedCount}",
        style: TextStyle(
          color: isWarning ? Colors.red : ModernStyles.getTextColor(context),
          fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
    DataCell(
      AdaptiveButton(
        onPressed: () => showFollowUpDialog(context, s, provider),
        style: alreadySent ? AdaptiveButtonStyle.filled : AdaptiveButtonStyle.tinted,
        label: 'Message',
      ),
    ),
    DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon:  Icon(
              LucideIcons.camera,
              color: ModernStyles.getTextColor(context),
              size: 18,
            ),
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
            icon:  Icon(
              LucideIcons.minusCircle,
              color: ModernStyles.getTextColor(context),
              size: 18,
            ),
            tooltip: 'Excuse from assignments',
            onPressed: () {
              showExcuseDialog(context, s, provider);
            },
          ),
          IconButton(
            icon:  Icon(
              LucideIcons.xCircle,
              color: ModernStyles.getTextColor(context),
              size: 18,
            ),
            tooltip: 'Mark No Answer',
            onPressed: () {
              showNoAnswerDialog(context, s, provider);
            },
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
      badgeColor = ModernStyles.blueRouteBadgeGrey;
    } else {
      double? val = double.tryParse(cellGrade);
      if (val != null && val >= 9) {
        badgeColor = ModernStyles.blueRouteBadgeCyan;
      } else {
        badgeColor = ModernStyles.blueRouteBadgeBlue;
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
                color: isMissing ? Colors.transparent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  return DataRow(
    selected: isSelected,
    onSelectChanged: (v) {
      provider.toggleStudentSelection(s, v == true);
    },
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
