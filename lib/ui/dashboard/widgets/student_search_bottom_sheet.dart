import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/student.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../theme/modern_styles.dart';
import 'student_details_dialog.dart';

class StudentSearchBottomSheet extends StatefulWidget {
  const StudentSearchBottomSheet({super.key});

  @override
  State<StudentSearchBottomSheet> createState() => _StudentSearchBottomSheetState();
}

class _StudentSearchBottomSheetState extends State<StudentSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Student> _searchResults = [];

  void _performSearch(String query, List<Student> allStudents) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    setState(() {
      _searchResults = allStudents.where((student) {
        final emailMatch = student.email?.toLowerCase().contains(lowerQuery) ?? false;
        final generatedEmailMatch = '${student.name.replaceAll(' ', '')}@gmail.com'.toLowerCase().contains(lowerQuery);
        final nameMatch = student.name.toLowerCase().contains(lowerQuery);
        return emailMatch || generatedEmailMatch || nameMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final allStudents = provider.allStudents;

    return Container(
      decoration: BoxDecoration(
        color: ModernStyles.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Student',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ModernStyles.getTextColor(context),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: ModernStyles.getTextColor(context)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            cursorColor: ModernStyles.getTextColor(context),
            decoration: InputDecoration(
              labelText: 'Enter Email or Name',
              labelStyle: TextStyle(color: ModernStyles.getTextColor(context)),
              prefixIcon: Icon(Icons.search, color: ModernStyles.getTextColor(context)),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ModernStyles.blueRouteDivider.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: ModernStyles.blueRouteButton, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (val) => _performSearch(val, allStudents),
          ),
          const SizedBox(height: 16),
          if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No students found.',
                  style: TextStyle(color: ModernStyles.blueRouteSecondaryText, fontSize: 16),
                ),
              ),
            ),
          if (_searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = _searchResults[index];
                  final email = student.email ?? '${student.name.replaceAll(' ', '')}@gmail.com';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    hoverColor: ModernStyles.blueRouteButton.withOpacity(0.05),
                    title: Text(
                      student.name,
                      style: TextStyle(fontWeight: FontWeight.bold, color: ModernStyles.getTextColor(context)),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(color: ModernStyles.blueRouteSecondaryText),
                    ),
                    trailing: Container(
                      decoration: ModernStyles.glowingContainer(context, opacity: 0.3, borderRadius: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: const Text('View', style: TextStyle(color: ModernStyles.blueRouteButton, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (ctx) => StudentDetailsDialog(student: student),
                      );
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
