class ServiceModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String? icon;
  final String? image;
  final bool isActive;
  final int? estimatedDays;
  final int durationHours;
  final String category;

  ServiceModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.icon,
    this.image,
    this.isActive = true,
    this.estimatedDays,
    this.durationHours = 24,
    this.category = 'General',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      icon: json['icon'],
      image: json['image'],
      isActive: json['isActive'] ?? true,
      estimatedDays: json['estimatedDays'],
      durationHours: json['durationHours'] ?? 24,
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'icon': icon,
      'image': image,
      'isActive': isActive,
      'estimatedDays': estimatedDays,
      'durationHours': durationHours,
      'category': category,
    };
  }
}
