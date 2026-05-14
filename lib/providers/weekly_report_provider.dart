import 'package:flutter/material.dart';
import '../models/assignment.dart';

class WeeklyReportProvider extends ChangeNotifier {
  final List<Assignment> _assignments = [
    // Group 1
    Assignment(title: 'Assignment 1', deadline: '5/8', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Assignment 2', deadline: '5/12', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Assignment 3', deadline: '5/18', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'OOP1', deadline: '5/20', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'OOP2', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Watsapp', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Facebook', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Space', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Contacts', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Islami', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Evently', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'News', deadline: '', groupName: 'Group 1 (Friday 10Am)'),
    Assignment(title: 'Movie', deadline: '', groupName: 'Group 1 (Friday 10Am)'),

    // Group 2
    Assignment(title: 'Assignment 1', deadline: '5/9', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Assignment 2', deadline: '5/17', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Assignment 3', deadline: '5/22', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'OOP1', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'OOP2', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Watsapp', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Facebook', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Space', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Contacts', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Islami', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Evently', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'News', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
    Assignment(title: 'Movie', deadline: '', groupName: 'Group 2 (Saturday 10Am)'),
  ];

  String _selectedGroup = 'Group 1 (Friday 10Am)';

  String get selectedGroup => _selectedGroup;

  List<String> get availableGroups => [
        'Group 1 (Friday 10Am)',
        'Group 2 (Saturday 10Am)',
      ];

  List<Assignment> get filteredAssignments {
    return _assignments
        .where((assignment) => 
            assignment.groupName == _selectedGroup && 
            assignment.deadline.isNotEmpty)
        .toList();
  }

  void selectGroup(String groupName) {
    if (_selectedGroup != groupName) {
      _selectedGroup = groupName;
      notifyListeners();
    }
  }
}
