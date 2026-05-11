import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'ui/dashboard/dashboard_screen.dart';

void main() {
  runApp(const FinalWhatsAppApp());
}

class FinalWhatsAppApp extends StatelessWidget {
  const FinalWhatsAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DashboardProvider())],
      child: MaterialApp(
        title: 'Smart Student Tracking System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA31D22)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFA31D22),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: const DashboardScreen(),
      ),
    );
  }
}
