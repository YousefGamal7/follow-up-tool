import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../providers/dashboard_provider.dart';
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
            ),
          ),
          if (alreadySent)
            const Icon(
              Icons.check_circle,
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
          color: isWarning ? Theme.of(context).colorScheme.error : null,
        ),
      ),
    ),
    DataCell(
      ElevatedButton(
        onPressed: () => _showFollowUpDialog(context, s, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadySent
              ? Colors.green.withOpacity(0.2)
              : (isWarning ? Colors.red : Colors.blue),
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
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.purple,
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
            icon: const Icon(
              Icons.healing,
              color: Colors.orange,
            ),
            tooltip: 'Excuse from assignments',
            onPressed: () {
              _showExcuseDialog(context, s, provider);
            },
          ),
        ],
      ),
    ),
  ];

  for (String assignment in provider.assignments) {
    String cellGrade = s.allGrades[assignment] ?? "";
    bool isMissing = cellGrade.isEmpty;
    rowCells.add(
      DataCell(
        Text(
          cellGrade,
          style: TextStyle(
            color: isMissing
                ? Colors.red
                : (cellGrade.contains('late') ? Colors.orange : Colors.green),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  return DataRow(
    selected: isSelected,
    color: isWarning ? WidgetStateProperty.all(Theme.of(context).colorScheme.errorContainer.withOpacity(0.5)) : null,
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
            title: Text('Excuse ${s.name}'),
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
            title: Text('Message & Follow up ${s.name}'),
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
