import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:send_message/services/multi_sheet_sync_service.dart';

class NotificationService with TrayListener, WindowListener {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? _backgroundTimer;

  // Initialize both Notifications and Window/Tray management
  Future<void> init() async {
    // 1. Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: null,
      macOS: null,
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // 2. Initialize Tray Manager
    await trayManager.setIcon('windows/runner/resources/app_icon.ico');
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'restore_app',
          label: 'Restore App',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
    trayManager.addListener(this);

    // 3. Initialize Window Manager
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    // Prevent the default close behavior
    await windowManager.setPreventClose(true);

    // 4. Start the background checker
    _startBackgroundChecker();
  }

  void _startBackgroundChecker() {
    // Check immediately on startup
    _checkDeadlines();
    // Then check periodically (e.g. every 2 hours)
    _backgroundTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      _checkDeadlines();
    });
  }

  Future<void> _checkDeadlines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncService = MultiSheetSyncService();
      
      // Defaulting to Yousef Gamal as per DashboardProvider. Ideally this should be saved in prefs.
      final instructor = prefs.getString('saved_instructor') ?? 'Yousef Gamal';
      
      // Fetch assignments report (omitting group name fetches first group or all general ones)
      final assignments = await syncService.getAssignmentsReport(instructor);
      
      final now = DateTime.now();
      
      for (var assignment in assignments) {
        if (assignment.deadline == null || assignment.deadline!.isEmpty) continue;
        
        // Deadline is usually in format "day/month" e.g. "5/8" or "20/5"
        final parts = assignment.deadline!.split('/');
        if (parts.length == 2) {
          int? day = int.tryParse(parts[0]);
          int? month = int.tryParse(parts[1]);
          
          if (day != null && month != null) {
            // Check if deadline is today or tomorrow
            bool isToday = (now.day == day && now.month == month);
            bool isTomorrow = (now.add(const Duration(days: 1)).day == day && now.add(const Duration(days: 1)).month == month);
            
            if (isToday || isTomorrow) {
              String key = 'notified_${assignment.name}_${assignment.deadline}';
              bool alreadyNotified = prefs.getBool(key) ?? false;
              
              if (!alreadyNotified) {
                String when = isToday ? "Today" : "Tomorrow";
                await showNotification(
                  'Deadline Approaching!', 
                  'Assignment ${assignment.name} is due $when (${assignment.deadline}).'
                );
                await prefs.setBool(key, true);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking deadlines in background: $e");
    }
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'deadline_channel_id',
      'Deadline Notifications',
      channelDescription: 'Notifications for assignment deadlines',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  // --- WindowListener Methods ---
  @override
  void onWindowClose() async {
    // Hide the window instead of closing it
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      windowManager.hide();
    }
  }

  // --- TrayListener Methods ---
  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'restore_app') {
      windowManager.show();
    } else if (menuItem.key == 'exit_app') {
      windowManager.setPreventClose(false);
      windowManager.close(); // Actually exit the app
    }
  }

  void dispose() {
    _backgroundTimer?.cancel();
    windowManager.removeListener(this);
    trayManager.removeListener(this);
  }
}
