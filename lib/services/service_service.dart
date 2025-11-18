import '../models/service_model.dart';
import '../models/booking_model.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService _apiService = ApiService();

  // Get all services
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _apiService.get('/services');

      if (response['success'] == true) {
        final List<dynamic> servicesData = response['services'] ?? [];
        return servicesData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch services');
      }
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  // Get service by ID
  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await _apiService.get('/services/$id');

      if (response['success'] == true) {
        return ServiceModel.fromJson(response['service']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch service');
      }
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }

  // Create booking
  Future<BookingModel> createBooking({
    required String serviceId,
    required String pickupDate,
    required String pickupTime,
    String? address,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/bookings',
        body: {
          'serviceId': serviceId,
          'pickupDate': pickupDate,
          'pickupTime': pickupTime,
          if (address != null) 'address': address,
          if (notes != null) 'notes': notes,
        },
        requiresAuth: true,
      );

      if (response['success'] == true) {
        return BookingModel.fromJson(response['order']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get user bookings
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final response = await _apiService.get(
        '/bookings/user',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final List<dynamic> bookingsData = response['orders'] ?? [];
        return bookingsData.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch bookings');
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }
}
