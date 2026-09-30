import 'dart:convert';

class UserProfile {
  final String name;
  final String bloodGroup;
  final String medicalNotes;
  final String emergencyMessageTemplate;
  final bool onboardingCompleted;

  UserProfile({
    this.name = '',
    this.bloodGroup = '',
    this.medicalNotes = '',
    this.emergencyMessageTemplate =
        "EMERGENCY ALERT: This is [NAME]. I need immediate assistance! My current location: [LOCATION_LINK]",
    this.onboardingCompleted = false,
  });

  UserProfile copyWith({
    String? name,
    String? bloodGroup,
    String? medicalNotes,
    String? emergencyMessageTemplate,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      emergencyMessageTemplate:
          emergencyMessageTemplate ?? this.emergencyMessageTemplate,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bloodGroup': bloodGroup,
      'medicalNotes': medicalNotes,
      'emergencyMessageTemplate': emergencyMessageTemplate,
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      medicalNotes: map['medicalNotes'] ?? '',
      emergencyMessageTemplate: map['emergencyMessageTemplate'] ??
          "EMERGENCY ALERT: This is [NAME]. I need immediate assistance! My current location: [LOCATION_LINK]",
      onboardingCompleted: map['onboardingCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
