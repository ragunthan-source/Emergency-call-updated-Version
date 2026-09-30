import 'dart:convert';

class IncidentLog {
  final String id;
  final DateTime timestamp;
  final String triggerType; // 'Motion Detected', 'Manual SOS', 'Test Mode'
  final double? latitude;
  final double? longitude;
  final String? mapsLink;
  final int contactsNotifiedCount;
  final int callsAttemptedCount;
  final String status; // 'Completed', 'Cancelled', 'Test Passed'
  final List<String> eventTimeline;

  IncidentLog({
    required this.id,
    required this.timestamp,
    required this.triggerType,
    this.latitude,
    this.longitude,
    this.mapsLink,
    required this.contactsNotifiedCount,
    required this.callsAttemptedCount,
    required this.status,
    required this.eventTimeline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'triggerType': triggerType,
      'latitude': latitude,
      'longitude': longitude,
      'mapsLink': mapsLink,
      'contactsNotifiedCount': contactsNotifiedCount,
      'callsAttemptedCount': callsAttemptedCount,
      'status': status,
      'eventTimeline': eventTimeline,
    };
  }

  factory IncidentLog.fromMap(Map<String, dynamic> map) {
    return IncidentLog(
      id: map['id'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      triggerType: map['triggerType'] ?? 'Unknown',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      mapsLink: map['mapsLink'],
      contactsNotifiedCount: map['contactsNotifiedCount'] ?? 0,
      callsAttemptedCount: map['callsAttemptedCount'] ?? 0,
      status: map['status'] ?? 'Completed',
      eventTimeline: List<String>.from(map['eventTimeline'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory IncidentLog.fromJson(String source) =>
      IncidentLog.fromMap(json.decode(source));
}
