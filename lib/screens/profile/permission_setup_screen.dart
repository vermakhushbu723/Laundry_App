import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/contact_service.dart';
import '../../models/user_model.dart';
import '../home/dashboard_screen.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _contactPermissionGranted = false;
  bool _isSyncing = false;
  final UserService _userService = UserService();
  final ContactService _contactService = ContactService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Automatically request contact permission for new users only
    _requestContactPermissionForNewUser();
  }

  Future<void> _checkPermissions() async {
    final contactStatus = await Permission.contacts.status;

    setState(() {
      _contactPermissionGranted = contactStatus.isGranted;
    });
  }

  Future<void> _requestContactPermissionForNewUser() async {
    // Wait a bit for UI to render
    await Future.delayed(const Duration(milliseconds: 500));

    // Request Contact permission only for new users
    if (!_contactPermissionGranted && mounted) {
      await _requestContactPermission();
      // Wait for user to respond to Contact permission dialog
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    // Navigate to app after contact permission is handled
    if (mounted) {
      _continueToApp();
    }
  }

  Future<void> _requestContactPermission() async {
    try {
      debugPrint('Requesting Contact permission...');
      final status = await Permission.contacts.request();
      debugPrint('Contact permission status: ${status.toString()}');

      if (mounted) {
        setState(() {
          _contactPermissionGranted = status.isGranted;
        });
      }

      if (status.isGranted) {
        // First sync contacts to backend
        await _syncContactsToBackend();
        // Then update permission status in backend
        await _updatePermissionInBackend();
      }
    } catch (e) {
      debugPrint('Error requesting Contact permission: $e');
    }
  }

  Future<void> _syncContactsToBackend() async {
    try {
      setState(() {
        _isSyncing = true;
      });

      debugPrint('🔄 Syncing contacts to backend...');
      final result = await _contactService.syncContactsToBackend();

      debugPrint('✅ Contact sync result: $result');

      if (result['success'] == true) {
        debugPrint('✅ Contacts synced successfully to database');
      } else {
        debugPrint('⚠️ Contact sync failed: ${result['message']}');
      }
    } catch (e) {
      debugPrint('❌ Error syncing contacts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _updatePermissionInBackend() async {
    try {
      final response = await _userService.updateProfile(
        contactPermission: _contactPermissionGranted,
      );

      if (response['success'] == true && mounted) {
        // Update local user data
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (response['user'] != null) {
          final updatedUser = UserModel.fromJson(response['user']);
          authProvider.updateUser(updatedUser);
        }
      }
    } catch (e) {
      debugPrint('Error updating permissions: $e');
    }
  }

  void _continueToApp() async {
    // Save contact permission to backend before continuing
    if (_contactPermissionGranted) {
      // Contacts already synced in _requestContactPermission
      // Just update permission if not already done
      await _updatePermissionInBackend();
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Permission Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.security, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 40),

            const CircularProgressIndicator(),

            const SizedBox(height: 24),

            Text(
              _isSyncing
                  ? 'Aapka din busy ho sakta hai… par aapke kapde hamesha fresh rahenge.'
                  : 'Ab laundry ka jhanjhat nahi — bas tap karo, ho gaya!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _isSyncing
                    ? 'Bas kuch hi seconds… aur aapka laundry ka kaam ho jayega smart!'
                    : 'Ek baar permission de dijiye, phir kabhi tension nahi!',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
