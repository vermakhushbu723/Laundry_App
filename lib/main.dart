import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/new_order_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/support/support_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_setup_screen.dart';

void main() async {
  // Catch all errors and log them
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Catch errors outside of Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 Platform Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  try {
    debugPrint('✅ App starting...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ Flutter binding initialized');

    // Initialize storage
    debugPrint('🔄 Initializing storage...');
    await StorageService().init();
    debugPrint('✅ Storage initialized');

    debugPrint('🚀 Running app...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('🔴 Error in main: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 Building MyApp...');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            debugPrint('🔄 Creating AuthProvider...');
            return AuthProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'DhobiGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Global error builder
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            debugPrint('🔴 Widget Error: ${errorDetails.exception}');
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Something went wrong!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kDebugMode
                            ? '${errorDetails.exception}'
                            : 'Please restart the app',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return widget!;
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            debugPrint(
              '🔍 Auth Status - isLoggedIn: ${authProvider.isLoggedIn}',
            );

            if (!authProvider.isLoggedIn) {
              debugPrint('➡️ Navigating to LoginScreen');
              return const LoginScreen();
            }

            final user = authProvider.user;
            debugPrint(
              '👤 User: ${user?.name ?? "No name"}, Phone: ${user?.phoneNumber ?? "No phone"}',
            );

            final bool isProfileComplete =
                user?.name != null &&
                user!.name!.isNotEmpty &&
                user.address != null &&
                user.address!.isNotEmpty;

            debugPrint('✔️ Profile Complete: $isProfileComplete');

            if (!isProfileComplete) {
              debugPrint('➡️ Navigating to ProfileSetupScreen');
              return const ProfileSetupScreen();
            }

            debugPrint('➡️ Navigating to DashboardScreen');
            return const DashboardScreen();
          },
        ),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/new-order': (context) => const NewOrderScreen(),
          '/services': (context) => const ServicesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/support': (context) => const SupportScreen(),
          '/help': (context) => const SupportScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}
