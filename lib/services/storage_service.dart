import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      debugPrint('🔄 StorageService: Initializing SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      debugPrint(
        '✅ StorageService: SharedPreferences initialized successfully',
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 StorageService: Failed to initialize - $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // User Token
  Future<void> saveToken(String token) async {
    try {
      debugPrint('🔄 StorageService: Saving token...');
      await _prefs?.setString(AppConstants.userTokenKey, token);
      debugPrint('✅ StorageService: Token saved');
    } catch (e) {
      debugPrint('🔴 StorageService: Error saving token - $e');
      rethrow;
    }
  }

  String? getToken() {
    try {
      final token = _prefs?.getString(AppConstants.userTokenKey);
      debugPrint(
        '🔍 StorageService: Getting token - ${token != null ? "Found" : "Not found"}',
      );
      return token;
    } catch (e) {
      debugPrint('🔴 StorageService: Error getting token - $e');
      return null;
    }
  }

  Future<void> removeToken() async {
    try {
      debugPrint('🔄 StorageService: Removing token...');
      await _prefs?.remove(AppConstants.userTokenKey);
      debugPrint('✅ StorageService: Token removed');
    } catch (e) {
      debugPrint('🔴 StorageService: Error removing token - $e');
    }
  }

  // User Data
  Future<void> saveUser(UserModel user) async {
    try {
      debugPrint('🔄 StorageService: Saving user data...');
      await _prefs?.setString(
        AppConstants.userDataKey,
        jsonEncode(user.toJson()),
      );
      debugPrint('✅ StorageService: User data saved');
    } catch (e) {
      debugPrint('🔴 StorageService: Error saving user - $e');
      rethrow;
    }
  }

  UserModel? getUser() {
    try {
      final userString = _prefs?.getString(AppConstants.userDataKey);
      if (userString != null) {
        debugPrint('🔍 StorageService: User data found');
        return UserModel.fromJson(jsonDecode(userString));
      }
      debugPrint('🔍 StorageService: No user data found');
      return null;
    } catch (e) {
      debugPrint('🔴 StorageService: Error getting user - $e');
      return null;
    }
  }

  Future<void> removeUser() async {
    try {
      debugPrint('🔄 StorageService: Removing user data...');
      await _prefs?.remove(AppConstants.userDataKey);
      debugPrint('✅ StorageService: User data removed');
    } catch (e) {
      debugPrint('🔴 StorageService: Error removing user - $e');
    }
  }

  // Login Status
  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(AppConstants.isLoggedInKey, value);
  }

  bool isLoggedIn() {
    return _prefs?.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // FCM Token
  Future<void> saveFcmToken(String token) async {
    await _prefs?.setString(AppConstants.fcmTokenKey, token);
  }

  String? getFcmToken() {
    return _prefs?.getString(AppConstants.fcmTokenKey);
  }

  // Contact Permission
  Future<void> setContactPermission(bool value) async {
    await _prefs?.setBool('contactPermission', value);
  }

  bool getContactPermission() {
    return _prefs?.getBool('contactPermission') ?? false;
  }

  // Last Contact Sync
  Future<void> setLastContactSync(String dateTime) async {
    await _prefs?.setString('lastContactSync', dateTime);
  }

  String? getLastContactSync() {
    return _prefs?.getString('lastContactSync');
  }

  // Get User ID
  String? getUserId() {
    final user = getUser();
    return user?.id;
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
