import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  /// Request contact permission from user
  Future<bool> requestContactPermission() async {
    try {
      // Check if permission is already granted
      PermissionStatus status = await Permission.contacts.status;

      if (status.isGranted) {
        return true;
      }

      // Request permission
      status = await Permission.contacts.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Open app settings if permanently denied
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      print('Error requesting contact permission: $e');
      return false;
    }
  }

  /// Fetch all contacts from the device
  Future<List<Map<String, dynamic>>> fetchDeviceContacts() async {
    try {
      print('🔹 Fetching device contacts...');

      // Request permission first
      print('🔐 Requesting FlutterContacts permission...');
      final permissionGranted = await FlutterContacts.requestPermission();
      print('📱 Permission granted: $permissionGranted');

      if (!permissionGranted) {
        print('❌ Contact permission denied by FlutterContacts');
        throw Exception('Contact permission denied');
      }

      // Fetch contacts with properties
      print('📥 Fetching contacts with properties...');
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      print('📊 Raw contacts fetched: ${contacts.length}');

      // Convert to API-friendly format
      List<Map<String, dynamic>> contactList = [];

      for (var contact in contacts) {
        // Get primary phone number
        if (contact.phones.isNotEmpty) {
          final phone = contact.phones.first.number
              .replaceAll(' ', '')
              .replaceAll('-', '')
              .replaceAll('(', '')
              .replaceAll(')', '');

          contactList.add({
            'name': contact.displayName.isNotEmpty
                ? contact.displayName
                : 'Unknown',
            'phoneNumber': phone,
            'email': contact.emails.isNotEmpty
                ? contact.emails.first.address
                : null,
          });
        }
      }

      print('✅ Processed ${contactList.length} contacts with phone numbers');
      return contactList;
    } catch (e) {
      print('❌ Error fetching device contacts: $e');
      rethrow;
    }
  }

  /// Sync contacts to backend
  Future<Map<String, dynamic>> syncContactsToBackend() async {
    try {
      print('\n======================================');
      print('🔹 Starting contact sync to backend...');
      print('======================================');

      // Check if user is logged in
      final token = _storage.getToken();
      if (token == null) {
        print('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      print('✅ User authenticated');
      print('🔑 Token length: ${token.length}');

      // Get user's own phone number
      final currentUser = _storage.getUser();
      final userPhoneNumber = currentUser?.phoneNumber ?? '';
      print('👤 User ID: ${currentUser?.id}');
      print('👤 User Name: ${currentUser?.name}');
      print('📱 User Phone: $userPhoneNumber');

      // Fetch contacts from device
      print('\n📱 Fetching contacts from device...');
      final contacts = await fetchDeviceContacts();

      print('📞 Total contacts found: ${contacts.length}');

      if (contacts.isEmpty) {
        print('⚠️ No contacts found on device');
        return {'success': false, 'message': 'No contacts found on device'};
      }

      // Show first 3 contacts
      print('\n📋 Sample contacts (first 3):');
      for (var i = 0; i < (contacts.length > 3 ? 3 : contacts.length); i++) {
        print(
          '   ${i + 1}. ${contacts[i]['name']} - ${contacts[i]['phoneNumber']}',
        );
      }

      // Send to backend with user's phone number
      final requestBody = {
        'contacts': contacts,
        'userPhoneNumber': userPhoneNumber,
      };

      print('\n🚀 Sending ${contacts.length} contacts to backend...');
      print('🌐 API URL: ${AppConstants.baseUrl}/contacts/sync');
      print('📦 Request body size: ${jsonEncode(requestBody).length} bytes');

      final response = await _api.post(
        '/contacts/sync',
        body: requestBody,
        requiresAuth: true,
      );

      print('\n✅ Backend response received:');
      print('📊 Response: ${jsonEncode(response)}');

      // Don't save to local storage - rely only on backend
      if (response['success'] == true) {
        print('\n✅ Contact sync completed successfully!');
        print('💾 Contacts stored in backend database');

        if (response['data'] != null) {
          print('📊 Database stats:');
          print('   - Inserted: ${response['data']['inserted']}');
          print('   - Updated: ${response['data']['updated']}');
          print('   - Total: ${response['data']['total']}');
          print('   - Total in DB: ${response['data']['totalInDb']}');
        }
      } else {
        print('⚠️ Backend returned success=false');
      }
      print('======================================\n');

      return response;
    } catch (e, stackTrace) {
      print('\n❌ Error syncing contacts: $e');
      print('📍 Stack trace: $stackTrace');
      print('======================================\n');
      return {'success': false, 'message': 'Failed to sync contacts: $e'};
    }
  }

  /// Request permission and sync contacts
  Future<Map<String, dynamic>> requestPermissionAndSync() async {
    try {
      print('🔹 Requesting contact permission...');

      // Request permission
      final hasPermission = await requestContactPermission();

      if (!hasPermission) {
        print('❌ Contact permission denied');
        return {'success': false, 'message': 'Contact permission denied'};
      }

      // Sync contacts
      print('✅ Permission granted, starting sync...');
      return await syncContactsToBackend();
    } catch (e) {
      print('❌ Error in requestPermissionAndSync: $e');
      return {'success': false, 'message': 'Failed to sync contacts: $e'};
    }
  }

  /// Get contacts from backend
  Future<Map<String, dynamic>> getMyContacts({
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    try {
      String endpoint = '/contacts/my-contacts?page=$page&limit=$limit';
      if (search.isNotEmpty) {
        endpoint += '&search=$search';
      }

      final response = await _api.get(endpoint, requiresAuth: true);
      return response;
    } catch (e) {
      print('Error getting contacts: $e');
      throw Exception('Failed to get contacts: $e');
    }
  }

  /// Delete all synced contacts
  Future<Map<String, dynamic>> deleteMyContacts() async {
    try {
      final response = await _api.delete(
        '/contacts/my-contacts',
        requiresAuth: true,
      );

      // Don't update local storage - backend will handle contactPermission
      return response;
    } catch (e) {
      print('Error deleting contacts: $e');
      throw Exception('Failed to delete contacts: $e');
    }
  }

  /// Check if contacts are synced - fetch from backend
  Future<bool> isContactsSynced() async {
    try {
      // Get user from storage to check backend contactPermission
      final user = _storage.getUser();
      return user?.contactPermission ?? false;
    } catch (e) {
      print('Error checking contact sync status: $e');
      return false;
    }
  }

  /// Get last sync time - fetch from backend
  Future<String?> getLastSyncTime() async {
    try {
      // This should be fetched from backend API if needed
      // For now, return null as we're relying on backend
      return null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }
}
