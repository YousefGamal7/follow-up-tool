import 'package:equatable/equatable.dart';
import '../../domain/entities/student_entity.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final String? error;
  
  final String selectedCycle;
  final String? selectedInstructor;
  final String? selectedGroup;
  final String? selectedAssignment;
  final String? selectedFilter;
  final String? selectedDynamicTask;

  final List<String> dynamicTasks;
  final List<String> availableCycles;
  final List<String> instructors;
  final List<String> groups;
  final List<String> assignments;
  final List<String> filters;

  final List<StudentEntity> allStudents;
  final List<StudentEntity> filteredStudents;
  final List<StudentEntity> selectedStudents;
  final List<String> sentPhones;

  final List<String> savedMaleTemplates;
  final List<String> savedFemaleTemplates;
  final bool isMaleTemplate;
  final String? selectedTemplate;

  final List<String> actionLogs;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.selectedCycle = 'C19',
    this.selectedInstructor = 'Yousef Gamal',
    this.selectedGroup = 'All',
    this.selectedAssignment,
    this.selectedFilter = 'All',
    this.selectedDynamicTask = 'Assignment 1',
    this.dynamicTasks = const [
      'Assignment 1', 'Assignment 2', 'Assignment 3', 
      'OOP1', 'OOP2', 'Whatsapp', 'Facebook', 'Space', 
      'Contacts', 'Islami', 'Evently', 'News', 'Movie'
    ],
    this.availableCycles = const ['C19', 'C20'],
    this.instructors = const [
      'Yousef Gamal',
      'Mahmoud Ibrahim',
      'Abdelrahman Youssef',
      'Rana Osama',
      'Ali Mohamed',
    ],
    this.groups = const ['All'],
    this.assignments = const [],
    this.filters = const [
      'All',
      'Late only (late)',
      'Not submitted (empty)',
      'Grades under 10',
      'Warned (Missed 6+)',
    ],
    this.allStudents = const [],
    this.filteredStudents = const [],
    this.selectedStudents = const [],
    this.sentPhones = const [],
    this.savedMaleTemplates = const [],
    this.savedFemaleTemplates = const [],
    this.isMaleTemplate = true,
    this.selectedTemplate,
    this.actionLogs = const [],
  });

  List<String> get savedTemplates => isMaleTemplate ? savedMaleTemplates : savedFemaleTemplates;

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    String? selectedCycle,
    String? selectedInstructor,
    String? selectedGroup,
    String? selectedAssignment,
    String? selectedFilter,
    String? selectedDynamicTask,
    List<String>? dynamicTasks,
    List<String>? availableCycles,
    List<String>? instructors,
    List<String>? groups,
    List<String>? assignments,
    List<String>? filters,
    List<StudentEntity>? allStudents,
    List<StudentEntity>? filteredStudents,
    List<StudentEntity>? selectedStudents,
    List<String>? sentPhones,
    List<String>? savedMaleTemplates,
    List<String>? savedFemaleTemplates,
    bool? isMaleTemplate,
    String? selectedTemplate,
    List<String>? actionLogs,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Clear error if not provided
      selectedCycle: selectedCycle ?? this.selectedCycle,
      selectedInstructor: selectedInstructor ?? this.selectedInstructor,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      selectedAssignment: selectedAssignment ?? this.selectedAssignment,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedDynamicTask: selectedDynamicTask ?? this.selectedDynamicTask,
      dynamicTasks: dynamicTasks ?? this.dynamicTasks,
      availableCycles: availableCycles ?? this.availableCycles,
      instructors: instructors ?? this.instructors,
      groups: groups ?? this.groups,
      assignments: assignments ?? this.assignments,
      filters: filters ?? this.filters,
      allStudents: allStudents ?? this.allStudents,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      selectedStudents: selectedStudents ?? this.selectedStudents,
      sentPhones: sentPhones ?? this.sentPhones,
      savedMaleTemplates: savedMaleTemplates ?? this.savedMaleTemplates,
      savedFemaleTemplates: savedFemaleTemplates ?? this.savedFemaleTemplates,
      isMaleTemplate: isMaleTemplate ?? this.isMaleTemplate,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      actionLogs: actionLogs ?? this.actionLogs,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, error, selectedCycle, selectedInstructor, selectedGroup, selectedAssignment,
    selectedFilter, selectedDynamicTask, dynamicTasks, availableCycles, instructors, groups,
    assignments, filters, allStudents, filteredStudents, selectedStudents,
    sentPhones, savedMaleTemplates, savedFemaleTemplates, isMaleTemplate,
    selectedTemplate, actionLogs
  ];
}
