class AppConstants {
  // API Configuration
  // For Android Emulator: Use 10.0.2.2 instead of localhost
  // For Physical Device: Use your computer's IP address (e.g., 192.168.x.x)
  // For Production: Use the deployed URL

  static const String baseUrl = 'https://laundry-backend-022k.onrender.com/api';
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl =
  //     'http://192.168.31.80:3000/api'; // Physical Device
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String resendOtpEndpoint = '/auth/resend-otp';
  static const String profileEndpoint = '/user/profile';
  static const String ordersEndpoint = '/orders';
  static const String servicesEndpoint = '/services';
  static const String bookingEndpoint = '/bookings';
  static const String notificationsEndpoint = '/notifications';

  // App Configuration
  static const String appName = 'DhobiGo';
  static const int otpLength = 6;
  static const int otpTimeout = 60; // seconds
  static const String staticOtp = '999000'; // Static OTP for development

  // Local Storage Keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userTokenKey = 'userToken';
  static const String userDataKey = 'userData';
  static const String fcmTokenKey = 'fcmToken';

  // Regex Patterns
  static const String phonePattern = r'^[0-9]{10}$';

  // Error Messages
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String invalidPhone =
      'Please enter valid 10 digit mobile number';
  static const String invalidOtp = 'Please enter valid OTP';
}
