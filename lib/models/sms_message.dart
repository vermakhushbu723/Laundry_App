class SmsMessage {
  final String id;
  final String address;
  final String body;
  final DateTime date;
  final String type; // 'inbox' or 'sent'

  SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'body': body,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory SmsMessage.fromJson(Map<String, dynamic> json) {
    return SmsMessage(
      id: json['id'],
      address: json['address'],
      body: json['body'],
      date: DateTime.parse(json['date']),
      type: json['type'],
    );
  }
}
