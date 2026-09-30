import 'package:permission_handler/permission_handler.dart';

class PermissionStatusReport {
  final bool locationGranted;
  final bool locationAlwaysGranted;
  final bool smsGranted;
  final bool phoneGranted;
  final bool sensorsGranted;
  final bool contactsGranted;

  PermissionStatusReport({
    required this.locationGranted,
    required this.locationAlwaysGranted,
    required this.smsGranted,
    required this.phoneGranted,
    required this.sensorsGranted,
    required this.contactsGranted,
  });

  bool get isFullyConfigured =>
      locationGranted && smsGranted && phoneGranted && sensorsGranted;
}

class PermissionService {
  static Future<PermissionStatusReport> checkHealth() async {
    final location = await Permission.locationWhenInUse.status;
    final locationAlways = await Permission.locationAlways.status;
    final sms = await Permission.sms.status;
    final phone = await Permission.phone.status;
    final sensors = await Permission.sensors.status;
    final contacts = await Permission.contacts.status;

    return PermissionStatusReport(
      locationGranted: location.isGranted || locationAlways.isGranted,
      locationAlwaysGranted: locationAlways.isGranted,
      smsGranted: sms.isGranted,
      phoneGranted: phone.isGranted,
      sensorsGranted: sensors.isGranted || sensors.isLimited,
      contactsGranted: contacts.isGranted,
    );
  }

  static Future<PermissionStatusReport> requestAllPermissions() async {
    // Request core permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.sms,
      Permission.phone,
      Permission.sensors,
      Permission.activityRecognition,
      Permission.contacts,
    ].request();

    // Optionally request location always if foreground is granted
    if (statuses[Permission.locationWhenInUse]?.isGranted ?? false) {
      await Permission.locationAlways.request();
    }

    return await checkHealth();
  }

  static Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await Permission.locationAlways.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.request();
    return status.isGranted;
  }

  static Future<bool> requestPhonePermission() async {
    var status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<bool> openAppSettingsScreen() async {
    return await openAppSettings();
  }
}
