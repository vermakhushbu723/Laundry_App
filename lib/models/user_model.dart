class UserModel {
  final String? id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final bool? smsPermission;
  final bool? contactPermission;
  final bool? isProfileComplete;

  UserModel({
    this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.address,
    this.createdAt,
    this.smsPermission,
    this.contactPermission,
    this.isProfileComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'],
      email: json['email'],
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      smsPermission: json['smsPermission'],
      contactPermission: json['contactPermission'],
      isProfileComplete: json['isProfileComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'smsPermission': smsPermission,
      'contactPermission': contactPermission,
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? address,
    DateTime? createdAt,
    bool? smsPermission,
    bool? contactPermission,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      smsPermission: smsPermission ?? this.smsPermission,
      contactPermission: contactPermission ?? this.contactPermission,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
