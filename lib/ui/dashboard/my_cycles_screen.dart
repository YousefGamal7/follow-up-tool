import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:send_message/theme/obsidian_theme.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_state.dart';
import 'cycle_details_screen.dart';

class MyCyclesScreen extends StatelessWidget {
  const MyCyclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final activeCycles = state.availableCycles;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by shell
      appBar: AppBar(
        title: const Text('My Cycles', style: TextStyle(color: ObsidianTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are assigned to ${activeCycles.length} active cycles.',
              style: const TextStyle(color: ObsidianTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: activeCycles.length,
                itemBuilder: (context, index) {
                  return _buildCycleCard(context, activeCycles[index], state);
                },
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildCycleCard(BuildContext context, String cycleName, DashboardState state) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CycleDetailsScreen(
              cycleName: cycleName,
              instructorName: state.selectedInstructor ?? 'Yousef Gamal', 
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ObsidianTheme.cardHoverDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ObsidianTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ObsidianTheme.primary.withOpacity(0.3)),
                  ),
                  child: const Text('Active', style: TextStyle(color: ObsidianTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Icon(LucideIcons.arrowRight, size: 16, color: ObsidianTheme.textSecondary),
              ],
            ),
            const Spacer(),
            Text(cycleName, style: const TextStyle(color: ObsidianTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.calendar, size: 14, color: ObsidianTheme.textMuted),
                const SizedBox(width: 6),
                Text('Mon / Wed Schedule', style: const TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)), // Placeholder
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.users, size: 14, color: ObsidianTheme.textMuted),
                const SizedBox(width: 6),
                const Text('Data syncing...', style: TextStyle(color: ObsidianTheme.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
