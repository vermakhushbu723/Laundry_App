import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Token
  Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.userTokenKey, token);
  }

  String? getToken() {
    return _prefs?.getString(AppConstants.userTokenKey);
  }

  Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.userTokenKey);
  }

  // User Data
  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(
      AppConstants.userDataKey,
      jsonEncode(user.toJson()),
    );
  }

  UserModel? getUser() {
    final userString = _prefs?.getString(AppConstants.userDataKey);
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs?.remove(AppConstants.userDataKey);
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

  // Clear All Data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
