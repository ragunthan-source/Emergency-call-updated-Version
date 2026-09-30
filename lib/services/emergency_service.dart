import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/incident_log.dart';
import 'location_service.dart';
import 'storage_service.dart';


class EmergencyExecutionStatus {
  final String currentAction;
  final String? activeContactName;
  final int contactsNotified;
  final int callsAttempted;
  final List<String> timeline;
  final bool isCompleted;
  final bool isExhausted;

  EmergencyExecutionStatus({
    required this.currentAction,
    this.activeContactName,
    required this.contactsNotified,
    required this.callsAttempted,
    required this.timeline,
    this.isCompleted = false,
    this.isExhausted = false,
  });
}

class EmergencyService {
  final StorageService _storageService;

  EmergencyService(this._storageService);

  Future<IncidentLog> triggerEmergencySequence({
    required String triggerType,
    required Function(EmergencyExecutionStatus status) onStatusUpdate,
    bool isTestMode = false,
  }) async {
    final userProfile = _storageService.getProfile();
    final contacts = _storageService.getContacts();
    final settings = _storageService.getSettings();

    final List<String> timeline = [];
    int smsSentCount = 0;
    int callAttemptCount = 0;

    void logEvent(String msg) {
      final timeStr = DateTime.now().toString().substring(11, 19);
      timeline.add('[$timeStr] $msg');
      onStatusUpdate(
        EmergencyExecutionStatus(
          currentAction: msg,
          contactsNotified: smsSentCount,
          callsAttempted: callAttemptCount,
          timeline: timeline,
        ),
      );
    }

    logEvent('Emergency Sequence Initialized ($triggerType)');

    if (isTestMode || settings.testMode) {
      logEvent('TEST MODE ACTIVE: Simulating emergency alert flow...');
      await Future.delayed(const Duration(seconds: 1));
      logEvent('Fetching GPS location...');
      final loc = await LocationService.getCurrentLocation();
      final mapsUrl = loc?.mapsUrl ?? 'https://maps.google.com/?q=0,0';
      logEvent('Location retrieved: ${loc?.latitude}, ${loc?.longitude}');
      logEvent('Simulating SMS dispatch to ${contacts.length} contact(s)');
      smsSentCount = contacts.length;

      for (var contact in contacts) {
        logEvent('Simulated Call Attempt 1 to ${contact.name} (${contact.phoneNumber})');
        await Future.delayed(const Duration(seconds: 2));
        callAttemptCount++;
      }

      logEvent('TEST MODE: All simulated calls completed successfully.');

      final log = IncidentLog(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        triggerType: '$triggerType (Test Simulation)',
        latitude: loc?.latitude,
        longitude: loc?.longitude,
        mapsLink: mapsUrl,
        contactsNotifiedCount: smsSentCount,
        callsAttemptedCount: callAttemptCount,
        status: 'Test Passed',
        eventTimeline: timeline,
      );

      await _storageService.addIncidentLog(log);
      return log;
    }

    // REAL EMERGENCY EXECUTION
    // Step 1: Fetch current location
    logEvent('Fetching high-precision GPS position...');
    final location = await LocationService.getCurrentLocation();
    final mapsUrl = location != null
        ? location.mapsUrl
        : 'https://maps.google.com/?q=0,0 (Location Unavailable)';

    logEvent('GPS Position acquired: ${location?.latitude ?? "N/A"}, ${location?.longitude ?? "N/A"}');

    // Step 2: Build SOS message from template
    String sosMessage = userProfile.emergencyMessageTemplate;
    sosMessage = sosMessage.replaceAll('[NAME]', userProfile.name.isEmpty ? 'Me' : userProfile.name);
    sosMessage = sosMessage.replaceAll('[LOCATION_LINK]', mapsUrl);

    if (userProfile.bloodGroup.isNotEmpty) {
      sosMessage += '\nBlood Group: ${userProfile.bloodGroup}';
    }
    if (userProfile.medicalNotes.isNotEmpty) {
      sosMessage += '\nMedical Info: ${userProfile.medicalNotes}';
    }

    // Step 3: Send SMS to all SMS-enabled contacts simultaneously
    final smsContacts = contacts.where((c) => c.smsEnabled).toList();
    logEvent('Sending emergency SMS broadcast to ${smsContacts.length} recipient(s)...');

    for (var contact in smsContacts) {
      try {
        final smsUri = Uri(
          scheme: 'sms',
          path: contact.phoneNumber,
          queryParameters: {'body': sosMessage},
        );
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          smsSentCount++;
          logEvent('SMS launched for ${contact.name} (${contact.phoneNumber})');
        } else {
          logEvent('Failed to launch SMS for ${contact.name}');
        }
      } catch (e) {
        logEvent('Error sending SMS to ${contact.name}: $e');
      }
    }

    // Step 4: Priority Call Sequence
    final callContacts = contacts.where((c) => c.callEnabled).toList();
    logEvent('Starting priority phone call sequence (${callContacts.length} contacts)...');

    bool callAnswered = false;

    // Outer loop allows retry loop once if all contacts exhausted
    for (int loop = 1; loop <= 2 && !callAnswered; loop++) {
      if (loop == 2) {
        logEvent('Loop 1 exhausted. Retrying priority contact call list (Loop 2)...');
      }

      for (var contact in callContacts) {
        callAttemptCount++;
        logEvent('Priority #${contact.priority}: Auto-dialing ${contact.name} (${contact.phoneNumber})...');

        onStatusUpdate(
          EmergencyExecutionStatus(
            currentAction: 'Calling ${contact.name}...',
            activeContactName: contact.name,
            contactsNotified: smsSentCount,
            callsAttempted: callAttemptCount,
            timeline: timeline,
          ),
        );

        final telUri = Uri(scheme: 'tel', path: contact.phoneNumber);
        try {
          if (await canLaunchUrl(telUri)) {
            await launchUrl(telUri);
            logEvent('Dialer initiated for ${contact.name}');
          } else {
            logEvent('Unable to place phone call to ${contact.phoneNumber}');
          }
        } catch (e) {
          logEvent('Call error for ${contact.name}: $e');
        }

        // Wait configured timeout before attempting next priority contact
        final timeout = settings.callTimeoutSeconds;
        logEvent('Waiting $timeout seconds for call response from ${contact.name}...');
        await Future.delayed(Duration(seconds: timeout));
      }
    }

    logEvent('Priority contact list call cycle completed.');

    final incidentLog = IncidentLog(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      triggerType: triggerType,
      latitude: location?.latitude,
      longitude: location?.longitude,
      mapsLink: mapsUrl,
      contactsNotifiedCount: smsSentCount,
      callsAttemptedCount: callAttemptCount,
      status: 'Emergency Alert Completed',
      eventTimeline: timeline,
    );

    await _storageService.addIncidentLog(incidentLog);

    onStatusUpdate(
      EmergencyExecutionStatus(
        currentAction: 'Emergency Sequence Finished',
        contactsNotified: smsSentCount,
        callsAttempted: callAttemptCount,
        timeline: timeline,
        isCompleted: true,
        isExhausted: true,
      ),
    );

    return incidentLog;
  }

  static Future<void> launchDirectCall(String phoneNumber) async {
    final telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    }
  }
}
