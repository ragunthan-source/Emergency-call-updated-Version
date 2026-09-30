import 'dart:convert';

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool callEnabled;
  final bool smsEnabled;
  final int priority;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = 'Family',
    this.callEnabled = true,
    this.smsEnabled = true,
    required this.priority,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? callEnabled,
    bool? smsEnabled,
    int? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      callEnabled: callEnabled ?? this.callEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'callEnabled': callEnabled,
      'smsEnabled': smsEnabled,
      'priority': priority,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      relationship: map['relationship'] ?? 'Family',
      callEnabled: map['callEnabled'] ?? true,
      smsEnabled: map['smsEnabled'] ?? true,
      priority: map['priority'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmergencyContact.fromJson(String source) =>
      EmergencyContact.fromMap(json.decode(source));
}
