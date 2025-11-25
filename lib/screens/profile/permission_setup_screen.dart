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
  bool _isLoading = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final smsStatus = await Permission.sms.status;
    final contactStatus = await Permission.contacts.status;

    setState(() {
      _smsPermissionGranted = smsStatus.isGranted;
      _contactPermissionGranted = contactStatus.isGranted;
    });
  }

  Future<void> _requestSmsPermission() async {
    setState(() => _isLoading = true);

    final status = await Permission.sms.request();

    setState(() {
      _smsPermissionGranted = status.isGranted;
      _isLoading = false;
    });

    if (status.isGranted) {
      // Update backend
      await _updatePermissionInBackend();
    } else if (mounted) {
      _showPermissionDialog(
        'SMS Permission',
        'SMS permission is required to sync your messages automatically.',
      );
    }
  }

  Future<void> _requestContactPermission() async {
    setState(() => _isLoading = true);

    final status = await Permission.contacts.request();

    setState(() {
      _contactPermissionGranted = status.isGranted;
      _isLoading = false;
    });

    if (status.isGranted) {
      // Update backend
      await _updatePermissionInBackend();
    } else if (mounted) {
      _showPermissionDialog(
        'Contact Permission',
        'Contact permission helps you manage laundry orders easily.',
      );
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

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

              // Header
              const Text(
                'Grant Permissions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'We need some permissions to provide you the best experience',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Permission Icon
              Center(
                child: Container(
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
                  child: const Icon(
                    Icons.security,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // SMS Permission Card
              _buildPermissionCard(
                icon: Icons.message,
                title: 'SMS Permission',
                description: 'Read SMS for automatic order updates',
                isGranted: _smsPermissionGranted,
                onTap: _smsPermissionGranted ? null : _requestSmsPermission,
              ),
              const SizedBox(height: 16),

              // Contact Permission Card
              _buildPermissionCard(
                icon: Icons.contacts,
                title: 'Contact Permission',
                description: 'Easily manage your orders',
                isGranted: _contactPermissionGranted,
                onTap: _contactPermissionGranted
                    ? null
                    : _requestContactPermission,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // Skip Button
              if (!_smsPermissionGranted || !_contactPermissionGranted)
                TextButton(
                  onPressed: _continueToApp,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              // Continue Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _smsPermissionGranted && _contactPermissionGranted
                        ? [AppColors.primary, AppColors.accent]
                        : [Colors.grey[400]!, Colors.grey[500]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (_smsPermissionGranted && _contactPermissionGranted)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_smsPermissionGranted && _contactPermissionGranted
                            ? _continueToApp
                            : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                ),
              ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? AppColors.success : Colors.grey[300]!,
          width: isGranted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isGranted
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isGranted ? AppColors.success : AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isGranted)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Allow',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
