import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PermissionService {
  // Request SMS Permission
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  // Request Contacts Permission
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Fetch Contacts (after permission granted)
  Future<List<Map<String, String>>> fetchContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        return contacts.map((contact) {
          final phoneNumber = contact.phones.isNotEmpty
              ? contact.phones.first.number
              : '';
          return {'name': contact.displayName, 'phoneNumber': phoneNumber};
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Request Notification Permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Check SMS Permission
  Future<bool> checkSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  // Check Contacts Permission
  Future<bool> checkContactsPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  // Check Notification Permission
  Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
