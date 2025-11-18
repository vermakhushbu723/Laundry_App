class BookingModel {
  final String? id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final String pickupDate;
  final String pickupTime;
  final double amount;
  final String? address;
  final String? notes;
  final String? customerName;
  final String? customerPhone;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.pickupDate,
    required this.pickupTime,
    required this.amount,
    this.address,
    this.notes,
    this.customerName,
    this.customerPhone,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      pickupDate: json['pickupDate'] ?? '',
      pickupTime: json['pickupTime'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      address: json['address'],
      notes: json['notes'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      status: json['status'] ?? 'pending',
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
      'pickupDate': pickupDate,
      'pickupTime': pickupTime,
      'amount': amount,
      'address': address,
      'notes': notes,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
