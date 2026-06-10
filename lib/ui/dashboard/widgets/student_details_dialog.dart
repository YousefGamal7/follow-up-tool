import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../models/student.dart';
import '../../../theme/modern_styles.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'student_row_widget.dart';

class StudentDetailsDialog extends StatelessWidget {
  final Student student;

  const StudentDetailsDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final email = student.email ?? '${student.name.replaceAll(' ', '')}@gmail.com';
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: ModernStyles.glassPanel(context).copyWith(
              color: ModernStyles.getCardColor(context).withOpacity(0.9),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ModernStyles.getTextColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: ModernStyles.getTextColor(context)),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(context, LucideIcons.mail, 'Email', email),
                const SizedBox(height: 12),
                _buildInfoRow(context, LucideIcons.phone, 'Phone', student.phone),
                const SizedBox(height: 12),
                _buildInfoRow(context, LucideIcons.users, 'Group', student.group),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: ModernStyles.glowingContainer(context, glowColor: Colors.redAccent, opacity: 0.2),
                        child: Column(
                          children: [
                            const Text('Missed Tasks', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              '${student.missedCount}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: ModernStyles.glowingContainer(context, glowColor: ModernStyles.blueRouteBadgeCyan, opacity: 0.2),
                        child: Column(
                          children: [
                            const Text('Overall Grade', style: TextStyle(color: ModernStyles.blueRouteBadgeCyan, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              student.grade.isEmpty ? 'N/A' : student.grade,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ModernStyles.blueRouteBadgeCyan),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Recent Grades:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.black.withOpacity(0.2) 
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: student.allGrades.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final key = student.allGrades.keys.elementAt(index);
                      final val = student.allGrades[key];
                      final isMissed = val == null || val.trim().isEmpty;
                      return ListTile(
                        dense: true,
                        title: Text(key, style: TextStyle(color: ModernStyles.getTextColor(context))),
                        trailing: Text(
                          isMissed ? 'Missed' : val,
                          style: TextStyle(
                            color: isMissed ? Colors.redAccent : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(LucideIcons.xCircle, color: ModernStyles.getTextColor(context), size: 18),
                      label: Text('No Answer', style: TextStyle(color: ModernStyles.getTextColor(context))),
                      onPressed: () {
                        final provider = context.read<DashboardProvider>();
                        Navigator.pop(context); // Close the details dialog
                        showNoAnswerDialog(context, student, provider);
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: Icon(LucideIcons.minusCircle, color: ModernStyles.getTextColor(context), size: 18),
                      label: Text('Excuse', style: TextStyle(color: ModernStyles.getTextColor(context))),
                      onPressed: () {
                        final provider = context.read<DashboardProvider>();
                        Navigator.pop(context); // Close the details dialog
                        showExcuseDialog(context, student, provider);
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(LucideIcons.messageCircle, size: 18, color: Colors.white),
                      label: const Text('Message', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernStyles.blueRouteButton,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final provider = context.read<DashboardProvider>();
                        Navigator.pop(context); // Close the details dialog
                        showFollowUpDialog(context, student, provider);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ModernStyles.blueRouteSecondaryText),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: ModernStyles.blueRouteSecondaryText, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: ModernStyles.getTextColor(context), fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
