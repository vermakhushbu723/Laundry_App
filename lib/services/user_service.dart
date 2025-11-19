import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get(
        '/user/profile',
        requiresAuth: true,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? address,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (address != null) body['address'] = address;

      final response = await _apiService.put(
        '/user/profile',
        body: body,
        requiresAuth: true,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get dashboard data (stats + recent orders)
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiService.get(
        '/user/dashboard',
        requiresAuth: true,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get dashboard data: $e');
    }
  }
}
