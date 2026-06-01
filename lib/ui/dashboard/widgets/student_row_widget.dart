import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/modern_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      ElevatedButton(
        onPressed: () => _showFollowUpDialog(context, s, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadySent
              ? Colors.green
              : ModernStyles.blueRouteButton,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        child: const Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
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
              _showExcuseDialog(context, s, provider);
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
              _showNoAnswerDialog(context, s, provider);
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

void _showExcuseDialog(BuildContext context, Student s, DashboardProvider provider) {
  List<String> selectedAssignments = [];
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ModernStyles.getCardColor(context),
            title: Text('Excuse ${s.name}', style: TextStyle(color: ModernStyles.getTextColor(context))),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: provider.excuseReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for excuse',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  const Text('Select Assignments:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: provider.assignments.map((assignment) {
                        return CheckboxListTile(
                          title: Text(assignment),
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
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  provider.excuseStudent(context, s, selectedAssignments);
                },
                child: const Text('Apply Excuse'),
              ),
            ],
          );
        }
      );
    },
  );
}

void _showNoAnswerDialog(BuildContext context, Student s, DashboardProvider provider) {
  List<String> selectedAssignments = [];
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ModernStyles.getCardColor(context),
            title: Text('Mark No Answer for ${s.name}', style: TextStyle(color: ModernStyles.getTextColor(context))),
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
                        return CheckboxListTile(
                          title: Text(assignment),
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
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  provider.noAnswerStudent(context, s, selectedAssignments);
                },
                child: const Text('Apply No Answer'),
              ),
            ],
          );
        }
      );
    },
  );
}

void _showFollowUpDialog(BuildContext context, Student s, DashboardProvider provider) {
  List<String> selectedAssignments = [];
  String generatedMessage = provider.generateMessage(s);
  TextEditingController messageController = TextEditingController(text: generatedMessage);
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ModernStyles.getCardColor(context),
            title: Text('Follow Up: ${s.name}', style: TextStyle(color: ModernStyles.getTextColor(context))),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 10),
                  const Text('Select Assignments to Follow Up (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: provider.assignments.map((assignment) {
                        return CheckboxListTile(
                          title: Text(assignment),
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
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  provider.launchWhatsAppWeb(s, context, selectedAssignments, messageController.text);
                },
                child: const Text('Send & Mark Followed Up'),
              ),
            ],
          );
        }
      );
    },
  );
}
