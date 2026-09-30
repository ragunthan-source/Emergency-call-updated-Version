import 'package:flutter_test/flutter_test.dart';
import 'package:emergency_call_updated_version/models/user_profile.dart';
import 'package:emergency_call_updated_version/models/emergency_contact.dart';
import 'package:emergency_call_updated_version/models/app_settings.dart';
import 'package:emergency_call_updated_version/models/incident_log.dart';

void main() {
  group('Emergency App Models & Logic Tests', () {
    test('UserProfile serialization & SOS message placeholder replacement', () {
      final profile = UserProfile(
        name: 'Jane Doe',
        bloodGroup: 'O+',
        medicalNotes: 'Penicillin allergy',
        emergencyMessageTemplate:
            'ALERT: [NAME] requires assistance! Location: [LOCATION_LINK]',
      );

      final jsonStr = profile.toJson();
      final decoded = UserProfile.fromJson(jsonStr);

      expect(decoded.name, 'Jane Doe');
      expect(decoded.bloodGroup, 'O+');

      String formatted = decoded.emergencyMessageTemplate
          .replaceAll('[NAME]', decoded.name)
          .replaceAll('[LOCATION_LINK]', 'https://maps.google.com/?q=10,20');

      expect(
        formatted,
        'ALERT: Jane Doe requires assistance! Location: https://maps.google.com/?q=10,20',
      );
    });

    test('EmergencyContact priority and capability toggles', () {
      final contact1 = EmergencyContact(
        id: '1',
        name: 'Doctor John',
        phoneNumber: '112',
        relationship: 'Physician',
        priority: 1,
        callEnabled: true,
        smsEnabled: true,
      );

      final contact2 = EmergencyContact(
        id: '2',
        name: 'Sister Mary',
        phoneNumber: '911',
        relationship: 'Sibling',
        priority: 2,
        callEnabled: false,
        smsEnabled: true,
      );

      final contacts = [contact2, contact1]..sort((a, b) => a.priority.compareTo(b.priority));

      expect(contacts.first.name, 'Doctor John');
      expect(contacts.first.priority, 1);
      expect(contacts.last.callEnabled, false);
      expect(contacts.last.smsEnabled, true);
    });

    test('Motion Sensitivity thresholds and debouncing requirements', () {
      // Low sensitivity: higher acceleration threshold + higher consecutive samples
      expect(MotionSensitivity.low.thresholdAcceleration, 19.0);
      expect(MotionSensitivity.low.requiredConsecutiveSamples, 4);

      // Medium sensitivity: balanced threshold & samples
      expect(MotionSensitivity.medium.thresholdAcceleration, 14.5);
      expect(MotionSensitivity.medium.requiredConsecutiveSamples, 3);

      // High sensitivity: lower threshold + faster reaction
      expect(MotionSensitivity.high.thresholdAcceleration, 10.0);
      expect(MotionSensitivity.high.requiredConsecutiveSamples, 2);
    });

    test('IncidentLog serialization & event timeline persistence', () {
      final now = DateTime.now();
      final log = IncidentLog(
        id: 'inc-123',
        timestamp: now,
        triggerType: 'Motion Detected',
        latitude: 37.7749,
        longitude: -122.4194,
        mapsLink: 'https://maps.google.com/?q=37.7749,-122.4194',
        contactsNotifiedCount: 3,
        callsAttemptedCount: 2,
        status: 'Completed',
        eventTimeline: [
          '[12:00:01] Motion trigger activated',
          '[12:00:08] SMS sent to 3 contacts',
          '[12:00:10] Dialed Contact 1',
        ],
      );

      final jsonStr = log.toJson();
      final restored = IncidentLog.fromJson(jsonStr);

      expect(restored.id, 'inc-123');
      expect(restored.contactsNotifiedCount, 3);
      expect(restored.eventTimeline.length, 3);
      expect(restored.mapsLink, contains('37.7749'));
    });
  });
}
