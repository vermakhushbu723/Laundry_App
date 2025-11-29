import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:workmanager/workmanager.dart';  // Temporarily disabled
import 'sms_service.dart';

// Background task callback
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       debugPrint('Background task started: $task');

//       final smsService = SmsService();

//       // Sync SMS periodically
//       await smsService.syncAllSmsToBackend();

//       return Future.value(true);
//     } catch (e) {
//       debugPrint('Background task error: $e');
//       return Future.value(false);
//     }
//   });
// }

// Foreground task handler
@pragma('vm:entry-point')
class SmsTaskHandler extends TaskHandler {
  final SmsService _smsService = SmsService();
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('Foreground service started');

    // Initialize SMS listener
    await _smsService.initializeSmsListener();

    // Sync SMS every 30 minutes
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _smsService.syncAllSmsToBackend();
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called every interval set in notification settings
    FlutterForegroundTask.updateService(
      notificationTitle: 'DhobiGo Running',
      notificationText: 'SMS monitoring active',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('Foreground service stopped');
    _timer?.cancel();
  }

  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('Notification button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}

class BackgroundSmsService {
  static final BackgroundSmsService _instance =
      BackgroundSmsService._internal();
  factory BackgroundSmsService() => _instance;
  BackgroundSmsService._internal();

  /// Initialize background service
  Future<void> initialize() async {
    try {
      // Initialize WorkManager for periodic tasks (temporarily disabled)
      // await Workmanager().initialize(
      //   callbackDispatcher,
      //   isInDebugMode: kDebugMode,
      // );

      // Initialize Foreground Task
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'dhobigo_sms_service',
          channelName: 'DhobiGo SMS Service',
          channelDescription: 'SMS monitoring service for DhobiGo',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000),
          autoRunOnBoot: true,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );

      debugPrint('Background service initialized');
    } catch (e) {
      debugPrint('Error initializing background service: $e');
    }
  }

  /// Start foreground service
  Future<bool> startForegroundService() async {
    try {
      // Request notification permission
      if (await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Start foreground service
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'DhobiGo Running',
        notificationText: 'SMS monitoring active',
        callback: startCallback,
      );

      debugPrint('Foreground service started successfully');
      return true;
    } catch (e) {
      debugPrint('Error starting foreground service: $e');
      return false;
    }
  }

  /// Stop foreground service
  Future<bool> stopForegroundService() async {
    try {
      await FlutterForegroundTask.stopService();
      return true;
    } catch (e) {
      debugPrint('Error stopping foreground service: $e');
      return false;
    }
  }

  /// Register periodic background task (temporarily disabled)
  Future<void> registerPeriodicTask() async {
    try {
      // await Workmanager().registerPeriodicTask(
      //   'sms-sync-task',
      //   'smsSyncTask',
      //   frequency: const Duration(minutes: 15),
      //   constraints: Constraints(networkType: NetworkType.connected),
      //   existingWorkPolicy: ExistingWorkPolicy.replace,
      // );

      debugPrint('Periodic task registration skipped (workmanager disabled)');
    } catch (e) {
      debugPrint('Error registering periodic task: $e');
    }
  }

  /// Cancel all background tasks (temporarily disabled)
  Future<void> cancelAllTasks() async {
    try {
      // await Workmanager().cancelAll();
      debugPrint('Cancel tasks skipped (workmanager disabled)');
    } catch (e) {
      debugPrint('Error cancelling tasks: $e');
    }
  }

  /// Check if foreground service is running
  Future<bool> isServiceRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }
}

// Callback function for foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SmsTaskHandler());
}
