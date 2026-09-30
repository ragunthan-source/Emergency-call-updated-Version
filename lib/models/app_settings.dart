import 'dart:convert';

enum MotionSensitivity { low, medium, high, custom }

extension MotionSensitivityExtension on MotionSensitivity {
  String get displayName {
    switch (this) {
      case MotionSensitivity.low:
        return 'Low (Strong False-Positive Protection)';
      case MotionSensitivity.medium:
        return 'Medium (Balanced Handling & Motion)';
      case MotionSensitivity.high:
        return 'High (Sensitive - Slight Movements)';
      case MotionSensitivity.custom:
        return 'Custom Calibration';
    }
  }

  // Threshold in m/s² total motion vector change |a - g| + gyro weight
  double get thresholdAcceleration {
    switch (this) {
      case MotionSensitivity.low:
        return 19.0;
      case MotionSensitivity.medium:
        return 14.5;
      case MotionSensitivity.high:
        return 10.0;
      case MotionSensitivity.custom:
        return 14.5;
    }
  }

  int get requiredConsecutiveSamples {
    switch (this) {
      case MotionSensitivity.low:
        return 4; // requires 4 consecutive high-motion samples (~400ms sustained)
      case MotionSensitivity.medium:
        return 3; // 3 samples (~300ms sustained)
      case MotionSensitivity.high:
        return 2; // 2 samples (~200ms)
      case MotionSensitivity.custom:
        return 3;
    }
  }
}

class AppSettings {
  final MotionSensitivity sensitivity;
  final double customThreshold;
  final int countdownDurationSeconds;
  final bool silentSosMode;
  final bool startOnBoot;
  final int autoDisarmHours; // 0 = Never auto-disarm
  final int liveLocationIntervalMinutes;
  final int callTimeoutSeconds;
  final String languageCode;
  final bool testMode;
  final bool isArmed;

  AppSettings({
    this.sensitivity = MotionSensitivity.medium,
    this.customThreshold = 14.5,
    this.countdownDurationSeconds = 7,
    this.silentSosMode = false,
    this.startOnBoot = true,
    this.autoDisarmHours = 0,
    this.liveLocationIntervalMinutes = 3,
    this.callTimeoutSeconds = 15,
    this.languageCode = 'en',
    this.testMode = false,
    this.isArmed = true, // Default armed when app opens as per requirement #6
  });

  AppSettings copyWith({
    MotionSensitivity? sensitivity,
    double? customThreshold,
    int? countdownDurationSeconds,
    bool? silentSosMode,
    bool? startOnBoot,
    int? autoDisarmHours,
    int? liveLocationIntervalMinutes,
    int? callTimeoutSeconds,
    String? languageCode,
    bool? testMode,
    bool? isArmed,
  }) {
    return AppSettings(
      sensitivity: sensitivity ?? this.sensitivity,
      customThreshold: customThreshold ?? this.customThreshold,
      countdownDurationSeconds:
          countdownDurationSeconds ?? this.countdownDurationSeconds,
      silentSosMode: silentSosMode ?? this.silentSosMode,
      startOnBoot: startOnBoot ?? this.startOnBoot,
      autoDisarmHours: autoDisarmHours ?? this.autoDisarmHours,
      liveLocationIntervalMinutes:
          liveLocationIntervalMinutes ?? this.liveLocationIntervalMinutes,
      callTimeoutSeconds: callTimeoutSeconds ?? this.callTimeoutSeconds,
      languageCode: languageCode ?? this.languageCode,
      testMode: testMode ?? this.testMode,
      isArmed: isArmed ?? this.isArmed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sensitivity': sensitivity.index,
      'customThreshold': customThreshold,
      'countdownDurationSeconds': countdownDurationSeconds,
      'silentSosMode': silentSosMode,
      'startOnBoot': startOnBoot,
      'autoDisarmHours': autoDisarmHours,
      'liveLocationIntervalMinutes': liveLocationIntervalMinutes,
      'callTimeoutSeconds': callTimeoutSeconds,
      'languageCode': languageCode,
      'testMode': testMode,
      'isArmed': isArmed,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      sensitivity: MotionSensitivity.values[map['sensitivity'] ?? 1],
      customThreshold: (map['customThreshold'] ?? 14.5).toDouble(),
      countdownDurationSeconds: map['countdownDurationSeconds'] ?? 7,
      silentSosMode: map['silentSosMode'] ?? false,
      startOnBoot: map['startOnBoot'] ?? true,
      autoDisarmHours: map['autoDisarmHours'] ?? 0,
      liveLocationIntervalMinutes: map['liveLocationIntervalMinutes'] ?? 3,
      callTimeoutSeconds: map['callTimeoutSeconds'] ?? 15,
      languageCode: map['languageCode'] ?? 'en',
      testMode: map['testMode'] ?? false,
      isArmed: map['isArmed'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(json.decode(source));
}
