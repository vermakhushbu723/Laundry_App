import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart' as sms_inbox;
import 'package:permission_handler/permission_handler.dart';
import '../models/sms_message.dart';
import 'api_service.dart';
import 'storage_service.dart';

class SmsService {
  final sms_inbox.SmsQuery _query = sms_inbox.SmsQuery();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  StreamController<SmsMessage> _smsStreamController =
      StreamController<SmsMessage>.broadcast();
  Stream<SmsMessage> get smsStream => _smsStreamController.stream;

  Timer? _pollingTimer;
  bool _isListening = false;
  DateTime? _lastSyncTime;

  /// Request SMS permissions
  Future<bool> requestSmsPermission() async {
    try {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting SMS permission: $e');
      return false;
    }
  }

  /// Check if SMS permission is granted
  Future<bool> hasSmsPermission() async {
    return await Permission.sms.isGranted;
  }

  /// Initialize SMS listener
  Future<void> initializeSmsListener() async {
    if (_isListening) return;

    final hasPermission = await hasSmsPermission();
    if (!hasPermission) {
      debugPrint('SMS permission not granted');
      return;
    }

    try {
      // Start polling for new SMS every 10 seconds
      _lastSyncTime = DateTime.now();
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _checkForNewSms();
      });

      _isListening = true;
      debugPrint('SMS listener initialized with polling');
    } catch (e) {
      debugPrint('Error initializing SMS listener: $e');
    }
  }

  /// Check for new SMS messages
  Future<void> _checkForNewSms() async {
    try {
      if (_lastSyncTime == null) return;

      final messages = await _query.querySms(
        kinds: [sms_inbox.SmsQueryKind.inbox],
        count: 10,
      );

      for (var message in messages) {
        // Handle date conversion properly
        int timestamp;
        if (message.date is int) {
          timestamp = message.date as int;
        } else if (message.date is DateTime) {
          timestamp = (message.date as DateTime).millisecondsSinceEpoch;
        } else {
          timestamp = DateTime.now().millisecondsSinceEpoch;
        }

        final messageDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

        if (messageDate.isAfter(_lastSyncTime!)) {
          final smsMessage = SmsMessage(
            id: message.id.toString(),
            address: message.address ?? 'Unknown',
            body: message.body ?? '',
            date: messageDate,
            type: 'inbox',
          );

          _smsStreamController.add(smsMessage);
          _sendSmsToBackend(smsMessage);
        }
      }

      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Error checking for new SMS: $e');
    }
  }

  /// Handle new incoming SMS (deprecated - using polling instead)
  void _handleNewSms(SmsMessage message) {
    // Add to stream
    _smsStreamController.add(message);

    // Send to backend
    _sendSmsToBackend(message);
  }

  /// Read all existing SMS messages
  Future<List<SmsMessage>> readAllSms() async {
    final hasPermission = await hasSmsPermission();
    if (!hasPermission) {
      debugPrint('SMS permission not granted');
      return [];
    }

    try {
      List<SmsMessage> allMessages = [];

      // Read inbox messages
      final inboxMessages = await _query.querySms(
        kinds: [sms_inbox.SmsQueryKind.inbox],
        count: 1000,
      );

      for (var message in inboxMessages) {
        // Handle date conversion
        int timestamp;
        if (message.date is int) {
          timestamp = message.date as int;
        } else if (message.date is DateTime) {
          timestamp = (message.date as DateTime).millisecondsSinceEpoch;
        } else {
          timestamp = DateTime.now().millisecondsSinceEpoch;
        }

        allMessages.add(
          SmsMessage(
            id: message.id.toString(),
            address: message.address ?? 'Unknown',
            body: message.body ?? '',
            date: DateTime.fromMillisecondsSinceEpoch(timestamp),
            type: 'inbox',
          ),
        );
      }

      // Read sent messages
      final sentMessages = await _query.querySms(
        kinds: [sms_inbox.SmsQueryKind.sent],
        count: 1000,
      );

      for (var message in sentMessages) {
        // Handle date conversion
        int timestamp;
        if (message.date is int) {
          timestamp = message.date as int;
        } else if (message.date is DateTime) {
          timestamp = (message.date as DateTime).millisecondsSinceEpoch;
        } else {
          timestamp = DateTime.now().millisecondsSinceEpoch;
        }

        allMessages.add(
          SmsMessage(
            id: message.id.toString(),
            address: message.address ?? 'Unknown',
            body: message.body ?? '',
            date: DateTime.fromMillisecondsSinceEpoch(timestamp),
            type: 'sent',
          ),
        );
      }

      // Sort by date (newest first)
      allMessages.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Read ${allMessages.length} SMS messages');
      return allMessages;
    } catch (e) {
      debugPrint('Error reading SMS: $e');
      return [];
    }
  }

  /// Send SMS data to backend
  Future<void> _sendSmsToBackend(SmsMessage smsMessage) async {
    try {
      final userId = await _storageService.getUserId();
      if (userId == null) {
        debugPrint('User ID not found');
        return;
      }

      await _apiService.post(
        '/sms/sync',
        body: {'userId': userId, 'smsData': smsMessage.toJson()},
        requiresAuth: true,
      );

      debugPrint('SMS sent to backend: ${smsMessage.id}');
    } catch (e) {
      debugPrint('Error sending SMS to backend: $e');
    }
  }

  /// Sync all existing SMS to backend
  Future<void> syncAllSmsToBackend() async {
    try {
      final userId = await _storageService.getUserId();
      if (userId == null) {
        debugPrint('User ID not found');
        return;
      }

      final allSms = await readAllSms();
      if (allSms.isEmpty) {
        debugPrint('No SMS to sync');
        return;
      }

      // Send in batches of 50
      const batchSize = 50;
      for (var i = 0; i < allSms.length; i += batchSize) {
        final batch = allSms.skip(i).take(batchSize).toList();

        await _apiService.post(
          '/sms/sync-batch',
          body: {
            'userId': userId,
            'smsData': batch.map((sms) => sms.toJson()).toList(),
          },
          requiresAuth: true,
        );

        debugPrint(
          'Synced batch ${(i ~/ batchSize) + 1} (${batch.length} messages)',
        );
      }

      debugPrint('All SMS synced to backend');
    } catch (e) {
      debugPrint('Error syncing SMS to backend: $e');
    }
  }

  /// Dispose
  void dispose() {
    _pollingTimer?.cancel();
    _smsStreamController.close();
    _isListening = false;
  }
}
