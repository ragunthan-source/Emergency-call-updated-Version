import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/emergency_contact.dart';
import '../models/app_settings.dart';
import '../models/incident_log.dart';

class StorageService {
  static const String _keyProfile = 'user_profile';
  static const String _keyContacts = 'emergency_contacts';
  static const String _keySettings = 'app_settings';
  static const String _keyLogs = 'incident_logs';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // User Profile
  UserProfile getProfile() {
    final rawJson = _prefs.getString(_keyProfile);
    if (rawJson == null) return UserProfile();
    try {
      return UserProfile.fromJson(rawJson);
    } catch (_) {
      return UserProfile();
    }
  }

  Future<bool> saveProfile(UserProfile profile) async {
    return await _prefs.setString(_keyProfile, profile.toJson());
  }

  // Emergency Contacts
  List<EmergencyContact> getContacts() {
    final rawJsonList = _prefs.getStringList(_keyContacts);
    if (rawJsonList == null || rawJsonList.isEmpty) {
      // Default sample contact for first launch demo
      return [
        EmergencyContact(
          id: 'contact_1',
          name: 'Primary Family Contact',
          phoneNumber: '911',
          relationship: 'Family',
          priority: 1,
          callEnabled: true,
          smsEnabled: true,
        ),
      ];
    }
    try {
      return rawJsonList
          .map((item) => EmergencyContact.fromJson(item))
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveContacts(List<EmergencyContact> contacts) async {
    final jsonList = contacts.map((c) => c.toJson()).toList();
    return await _prefs.setStringList(_keyContacts, jsonList);
  }

  // App Settings
  AppSettings getSettings() {
    final rawJson = _prefs.getString(_keySettings);
    if (rawJson == null) return AppSettings();
    try {
      return AppSettings.fromJson(rawJson);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<bool> saveSettings(AppSettings settings) async {
    return await _prefs.setString(_keySettings, settings.toJson());
  }

  // Incident Logs
  List<IncidentLog> getIncidentLogs() {
    final rawJsonList = _prefs.getStringList(_keyLogs);
    if (rawJsonList == null) return [];
    try {
      return rawJsonList.map((item) => IncidentLog.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> addIncidentLog(IncidentLog log) async {
    final logs = getIncidentLogs();
    logs.insert(0, log); // Add newest first
    final jsonList = logs.map((l) => l.toJson()).toList();
    return await _prefs.setStringList(_keyLogs, jsonList);
  }

  Future<bool> clearIncidentLogs() async {
    return await _prefs.remove(_keyLogs);
  }
}
