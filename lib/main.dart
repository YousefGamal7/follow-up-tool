import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/dashboard_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/obsidian_theme.dart';
import 'ui/main_shell/main_app_shell.dart';
import 'injection_container.dart' as di;
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

import 'dart:io';
import 'package:video_player_win/video_player_win.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _migrateOldDataToC19() async {
  final prefs = await SharedPreferences.getInstance();
  
  final c19Workshops = prefs.getString('workshops_data_C19');
  if (prefs.containsKey('workshops_data') && (c19Workshops == null || c19Workshops == '[]')) {
    final oldData = prefs.getString('workshops_data');
    if (oldData != null && oldData != '[]') {
      await prefs.setString('workshops_data_C19', oldData);
    }
  }

  final c19Attendance = prefs.getString('attendance_data_C19');
  if (prefs.containsKey('attendance_data') && (c19Attendance == null || c19Attendance == '[]')) {
    final oldData = prefs.getString('attendance_data');
    if (oldData != null && oldData != '[]') {
      await prefs.setString('attendance_data_C19', oldData);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _migrateOldDataToC19();
  await di.init();
  runApp(const FinalWhatsAppApp());
}

class FinalWhatsAppApp extends StatelessWidget {
  const FinalWhatsAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: BlocProvider(
        create: (_) => di.sl<DashboardCubit>(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Route Mentor Portal',
              debugShowCheckedModeBanner: false,
              theme: ObsidianTheme.themeData, // Enforcing Obsidian Sapphire Dark Theme
              themeMode: ThemeMode.dark, // Always dark mode for this portal
              home: const MainAppShell(),
            );
          },
        ),
      ),
    );
  }
}
