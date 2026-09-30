import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/emergency_contact.dart';
import '../models/app_settings.dart';
import '../models/incident_log.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../services/motion_service.dart';
import '../services/alert_sound_service.dart';
import '../services/emergency_service.dart';
import '../services/background_service.dart';

class AppState extends ChangeNotifier {
  late StorageService _storageService;
  final MotionService _motionService = MotionService();
  final AlertSoundService _alertSoundService = AlertSoundService();
  late EmergencyService _emergencyService;

  UserProfile _userProfile = UserProfile();
  List<EmergencyContact> _contacts = [];
  AppSettings _settings = AppSettings();
  List<IncidentLog> _incidentLogs = [];
  PermissionStatusReport? _permissionReport;

  bool _isArmed = true;
  MotionDataPoint? _latestMotionPoint;
  bool _isCountdownActive = false;
  int _countdownRemaining = 7;
  Timer? _countdownTimer;
  String _activeTriggerType = 'Motion Detected';

  bool _isEmergencyActive = false;
  EmergencyExecutionStatus? _emergencyExecutionStatus;
  Timer? _autoDisarmTimer;
  DateTime? _armedExpirationTime;

  // Getters
  UserProfile get userProfile => _userProfile;
  List<EmergencyContact> get contacts => _contacts;
  AppSettings get settings => _settings;
  List<IncidentLog> get incidentLogs => _incidentLogs;
  PermissionStatusReport? get permissionReport => _permissionReport;

  bool get isArmed => _isArmed;
  MotionDataPoint? get latestMotionPoint => _latestMotionPoint;
  bool get isCountdownActive => _isCountdownActive;
  int get countdownRemaining => _countdownRemaining;
  bool get isEmergencyActive => _isEmergencyActive;
  EmergencyExecutionStatus? get emergencyExecutionStatus =>
      _emergencyExecutionStatus;
  DateTime? get armedExpirationTime => _armedExpirationTime;

  Future<void> initialize() async {
    _storageService = await StorageService.init();
    _emergencyService = EmergencyService(_storageService);

    _userProfile = _storageService.getProfile();
    _contacts = _storageService.getContacts();
    _settings = _storageService.getSettings();
    _incidentLogs = _storageService.getIncidentLogs();
    _isArmed = _settings.isArmed;

    _permissionReport = await PermissionService.checkHealth();

    // Listen to live motion updates for gauge
    _motionService.motionStream.listen((point) {
      _latestMotionPoint = point;
      notifyListeners();
    });

    if (_isArmed) {
      _startMotionMonitoring();
    }

    notifyListeners();
  }

  Future<void> refreshPermissions() async {
    _permissionReport = await PermissionService.checkHealth();
    notifyListeners();
  }

  // Profile Management
  Future<void> saveProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storageService.saveProfile(profile);
    notifyListeners();
  }

  // Contacts Management
  Future<void> saveContacts(List<EmergencyContact> newContacts) async {
    _contacts = newContacts;
    await _storageService.saveContacts(newContacts);
    notifyListeners();
  }

  // Settings Management
  Future<void> saveSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveSettings(newSettings);

    // Restart motion monitoring with updated sensitivity if armed
    if (_isArmed) {
      _startMotionMonitoring();
    }
    notifyListeners();
  }

  // Arming / Disarming
  void setArmed(bool armed) {
    _isArmed = armed;
    _settings = _settings.copyWith(isArmed: armed);
    _storageService.saveSettings(_settings);

    if (_isArmed) {
      _startMotionMonitoring();
      BackgroundServiceHelper.showArmedNotification();

      if (_settings.autoDisarmHours > 0) {
        _armedExpirationTime = DateTime.now().add(
          Duration(hours: _settings.autoDisarmHours),
        );
        _autoDisarmTimer?.cancel();
        _autoDisarmTimer = Timer(
          Duration(hours: _settings.autoDisarmHours),
          () {
            setArmed(false);
          },
        );
      } else {
        _armedExpirationTime = null;
      }
    } else {
      _stopMotionMonitoring();
      BackgroundServiceHelper.cancelArmedNotification();
      _autoDisarmTimer?.cancel();
      _armedExpirationTime = null;
    }
    notifyListeners();
  }

  void _startMotionMonitoring() {
    _motionService.startMonitoring(
      settings: _settings,
      onTrigger: () {
        if (!_isCountdownActive && !_isEmergencyActive) {
          triggerCountdown(triggerType: 'Motion Detected');
        }
      },
    );
  }

  void _stopMotionMonitoring() {
    _motionService.stopMonitoring();
  }

  // Emergency Alert Flow
  void triggerCountdown({String triggerType = 'Motion Detected'}) {
    _activeTriggerType = triggerType;
    _isCountdownActive = true;
    _countdownRemaining = _settings.countdownDurationSeconds;

    // Start Alarm sound + vibration if silent mode is OFF
    _alertSoundService.startAlarm(silentMode: _settings.silentSosMode);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownRemaining > 1) {
        _countdownRemaining--;
        if (!_settings.silentSosMode) {
          _alertSoundService.playBeep();
        }
        notifyListeners();
      } else {
        timer.cancel();
        _isCountdownActive = false;
        notifyListeners();
        executeEmergencySequence(triggerType: _activeTriggerType);
      }
    });

    notifyListeners();
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
    _isCountdownActive = false;
    _alertSoundService.stopAlarm();
    notifyListeners();
  }

  Future<void> executeEmergencySequence({
    required String triggerType,
    bool isTestMode = false,
  }) async {
    _alertSoundService.stopAlarm();
    _isEmergencyActive = true;
    notifyListeners();

    await _emergencyService.triggerEmergencySequence(
      triggerType: triggerType,
      isTestMode: isTestMode || _settings.testMode,
      onStatusUpdate: (status) {
        _emergencyExecutionStatus = status;
        notifyListeners();
      },
    );


    _incidentLogs = _storageService.getIncidentLogs();
    notifyListeners();
  }

  void dismissEmergencyState() {
    _isEmergencyActive = false;
    _emergencyExecutionStatus = null;
    notifyListeners();
  }

  Future<void> clearLogs() async {
    await _storageService.clearIncidentLogs();
    _incidentLogs = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _motionService.dispose();
    _alertSoundService.dispose();
    _countdownTimer?.cancel();
    _autoDisarmTimer?.cancel();
    super.dispose();
  }
}
