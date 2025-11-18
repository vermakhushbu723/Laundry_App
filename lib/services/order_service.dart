import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/order_model.dart';
import 'storage_service.dart';

class OrderService {
  final _storage = StorageService();

  Future<String?> _getToken() async {
    return _storage.getToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create new order
  Future<OrderModel> createOrder({
    required String serviceId,
    required String serviceName,
    required DateTime pickupDate,
    required String pickupTime,
    required String address,
    String? notes,
    double? amount,
  }) async {
    try {
      print('🔹 Creating order...');
      final headers = await _getHeaders();
      final url = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}',
      );

      final body = jsonEncode({
        'serviceId': serviceId,
        'serviceName': serviceName,
        'pickupDate': pickupDate.toIso8601String(),
        'pickupTime': pickupTime,
        'address': address,
        'notes': notes,
        'amount': amount,
      });

      print('Request URL: $url');
      print('Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Order created successfully');
        return OrderModel.fromJson(data['order'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  // Get all orders for current user
  Future<List<OrderModel>> getOrders({String? status}) async {
    try {
      print('🔹 Fetching orders...');
      final headers = await _getHeaders();
      var url = '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}';

      if (status != null) {
        url += '?status=$status';
      }

      print('Request URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ordersList = data['orders'] ?? data;

        if (ordersList is List) {
          final orders = ordersList
              .map((json) => OrderModel.fromJson(json))
              .toList();
          print('✅ Fetched ${orders.length} orders');
          return orders;
        }
        return [];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      print('❌ Error fetching orders: $e');
      rethrow;
    }
  }

  // Get single order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      print('🔹 Fetching order: $orderId');
      final headers = await _getHeaders();
      final url =
          '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderId';

      print('Request URL: $url');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Order fetched successfully');
        return OrderModel.fromJson(data['order'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch order');
      }
    } catch (e) {
      print('❌ Error fetching order: $e');
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      print('🔹 Cancelling order: $orderId');
      final headers = await _getHeaders();
      final url =
          '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderId/cancel';

      print('Request URL: $url');

      final response = await http.patch(Uri.parse(url), headers: headers);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Order cancelled successfully');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      print('❌ Error cancelling order: $e');
      rethrow;
    }
  }

  // Update order status (for admin/delivery)
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      print('🔹 Updating order status: $orderId to $status');
      final headers = await _getHeaders();
      final url =
          '${AppConstants.baseUrl}${AppConstants.ordersEndpoint}/$orderId/status';

      final body = jsonEncode({'status': status});

      print('Request URL: $url');
      print('Request Body: $body');

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Order status updated successfully');
        return OrderModel.fromJson(data['order'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
      rethrow;
    }
  }
}
