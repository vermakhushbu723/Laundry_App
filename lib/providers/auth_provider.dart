import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _isLoggedIn = _authService.isLoggedIn();
    if (_isLoggedIn) {
      _user = _authService.getCurrentUser();
    }
    notifyListeners();
  }

  // Send OTP
  Future<bool> sendOtp(String phoneNumber) async {
    print('🔹 AuthProvider: Send OTP started');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📞 AuthProvider: Calling auth service...');
      await _authService.sendOtp(phoneNumber);
      _isLoading = false;
      notifyListeners();
      print('✅ AuthProvider: OTP sent successfully');
      return true;
    } catch (e) {
      print('❌ AuthProvider: Error - $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    print('🔹 AuthProvider: Verify OTP started');
    print('📱 Phone: $phoneNumber, OTP: $otp');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 AuthProvider: Calling verify service...');
      final response = await _authService.verifyOtp(phoneNumber, otp);
      print('📊 AuthProvider: Response received');

      if (response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        _isLoggedIn = true;
        print('✅ AuthProvider: User logged in');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ AuthProvider: Verify Error - $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resendOtp(phoneNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Update user data
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
