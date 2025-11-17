enum OrderStatus { pending, picked, inProcess, delivered, cancelled }

class OrderModel {
  final String? id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime pickupDate;
  final String pickupTime;
  final OrderStatus status;
  final double? amount;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.pickupDate,
    required this.pickupTime,
    required this.status,
    this.amount,
    this.address,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      pickupDate: DateTime.parse(json['pickupDate']),
      pickupTime: json['pickupTime'] ?? '',
      status: _parseStatus(json['status']),
      amount: json['amount']?.toDouble(),
      address: json['address'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'pickupDate': pickupDate.toIso8601String(),
      'pickupTime': pickupTime,
      'status': status.name,
      'amount': amount,
      'address': address,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'picked':
        return OrderStatus.picked;
      case 'in-process':
      case 'inprocess':
        return OrderStatus.inProcess;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.picked:
        return 'Picked Up';
      case OrderStatus.inProcess:
        return 'In Process';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
