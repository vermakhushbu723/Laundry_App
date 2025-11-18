import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/new_order_screen.dart';
import 'screens/services/services_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Laundry App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isLoggedIn
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/new-order': (context) => const NewOrderScreen(),
          '/services': (context) => const ServicesScreen(),
          '/support': (context) =>
              const DashboardScreen(), // TODO: Create support screen
          '/profile': (context) =>
              const DashboardScreen(), // TODO: Create profile screen
        },
      ),
    );
  }
}
