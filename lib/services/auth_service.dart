import '../models/user_model.dart';
import '../config/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'contact_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final ContactService _contactService = ContactService();

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

        // Request contact permission and sync after successful login
        _requestContactPermissionAfterLogin();
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

  // Request contact permission after login (background task)
  void _requestContactPermissionAfterLogin() async {
    try {
      print('🔹 Starting post-login contact sync process...');

      // Wait a bit for UI to settle
      await Future.delayed(const Duration(seconds: 2));

      // Check if contacts are already synced
      final isSynced = await _contactService.isContactsSynced();
      print('📊 Contacts already synced: $isSynced');

      if (!isSynced) {
        print('🔄 Initiating contact sync...');
        // Request permission and sync contacts
        final result = await _contactService.requestPermissionAndSync();
        print('✅ Contact sync result: $result');
      } else {
        print('⏭️ Skipping sync - contacts already synced');
      }
    } catch (e) {
      print('❌ Error syncing contacts after login: $e');
      // Don't throw error, just log it
    }
  }
}
