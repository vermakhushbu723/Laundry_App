import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

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
      print('🔹 Starting contact sync to backend...');

      // Check if user is logged in
      final token = _storage.getToken();
      if (token == null) {
        print('❌ User not authenticated');
        throw Exception('User not authenticated');
      }

      print('✅ User authenticated');

      // Get user's own phone number
      final currentUser = _storage.getUser();
      final userPhoneNumber = currentUser?.phoneNumber ?? '';
      print('📱 Current user phone: $userPhoneNumber');

      // Fetch contacts from device
      print('📱 Fetching contacts from device...');
      final contacts = await fetchDeviceContacts();

      print('📞 Found ${contacts.length} contacts on device');

      if (contacts.isEmpty) {
        print('⚠️ No contacts found on device');
        return {'success': false, 'message': 'No contacts found on device'};
      }

      // Send to backend with user's phone number
      print('🚀 Sending ${contacts.length} contacts to backend...');
      final response = await _api.post(
        '/contacts/sync',
        body: {'contacts': contacts, 'userPhoneNumber': userPhoneNumber},
        requiresAuth: true,
      );

      print('✅ Backend response: $response');

      // Save sync status locally
      if (response['success'] == true) {
        await _storage.setContactPermission(true);
        await _storage.setLastContactSync(DateTime.now().toIso8601String());
        print('✅ Contact sync completed successfully');
      }

      return response;
    } catch (e) {
      print('❌ Error syncing contacts: $e');
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

      if (response['success'] == true) {
        await _storage.setContactPermission(false);
        await _storage.setLastContactSync('');
      }

      return response;
    } catch (e) {
      print('Error deleting contacts: $e');
      throw Exception('Failed to delete contacts: $e');
    }
  }

  /// Check if contacts are synced
  Future<bool> isContactsSynced() async {
    final lastSync = _storage.getLastContactSync();
    return lastSync != null && lastSync.isNotEmpty;
  }

  /// Get last sync time
  Future<String?> getLastSyncTime() async {
    return _storage.getLastContactSync();
  }
}
