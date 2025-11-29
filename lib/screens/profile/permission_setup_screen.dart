import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../home/dashboard_screen.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _smsPermissionGranted = false;
  bool _contactPermissionGranted = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Automatically request permissions when screen opens
    _requestAllPermissions();
  }

  Future<void> _checkPermissions() async {
    final smsStatus = await Permission.sms.status;
    final contactStatus = await Permission.contacts.status;

    setState(() {
      _smsPermissionGranted = smsStatus.isGranted;
      _contactPermissionGranted = contactStatus.isGranted;
    });
  }

  Future<void> _requestAllPermissions() async {
    // Wait a bit for UI to render
    await Future.delayed(const Duration(milliseconds: 300));

    // Request SMS permission first
    if (!_smsPermissionGranted) {
      await _requestSmsPermission();
      // Wait a bit before requesting next permission
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Request Contact permission after SMS
    if (!_contactPermissionGranted && mounted) {
      await _requestContactPermission();
      // Wait a bit before continuing
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // If both permissions are requested (granted or denied), navigate to app
    if (mounted) {
      _continueToApp();
    }
  }

  Future<void> _requestSmsPermission() async {
    try {
      final status = await Permission.sms.request();

      if (mounted) {
        setState(() {
          _smsPermissionGranted = status.isGranted;
        });
      }

      if (status.isGranted) {
        await _updatePermissionInBackend();
      }
    } catch (e) {
      debugPrint('Error requesting SMS permission: $e');
    }
  }

  Future<void> _requestContactPermission() async {
    try {
      final status = await Permission.contacts.request();

      if (mounted) {
        setState(() {
          _contactPermissionGranted = status.isGranted;
        });
      }

      if (status.isGranted) {
        await _updatePermissionInBackend();
      }
    } catch (e) {
      debugPrint('Error requesting Contact permission: $e');
    }
  }

  Future<void> _updatePermissionInBackend() async {
    try {
      final response = await _userService.updateProfile(
        smsPermission: _smsPermissionGranted,
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
    // Save permissions to backend before continuing
    if (_smsPermissionGranted || _contactPermissionGranted) {
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

            const Text(
              'Setting up permissions...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please allow the requested permissions',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
