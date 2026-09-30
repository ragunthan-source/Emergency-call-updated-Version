import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/app_settings.dart';

class MotionDataPoint {
  final double combinedMotion;
  final double accelDelta;
  final double gyroRotation;
  final DateTime timestamp;

  MotionDataPoint({
    required this.combinedMotion,
    required this.accelDelta,
    required this.gyroRotation,
    required this.timestamp,
  });
}

class MotionService {
  StreamSubscription<UserAccelerometerEvent>? _userAccelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  final _motionStreamController = StreamController<MotionDataPoint>.broadcast();
  Stream<MotionDataPoint> get motionStream => _motionStreamController.stream;

  Function()? onTriggerCallback;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  double _latestGyroMagnitude = 0.0;
  int _consecutiveHighMotionCount = 0;
  DateTime? _lastTriggerTime;

  void startMonitoring({
    required AppSettings settings,
    required Function() onTrigger,
  }) {
    if (_isMonitoring) stopMonitoring();

    _isMonitoring = true;
    onTriggerCallback = onTrigger;
    _consecutiveHighMotionCount = 0;

    // Listen to Gyroscope stream for angular rotation speed
    _gyroSub = gyroscopeEventStream().listen((GyroscopeEvent event) {
      // Rotation magnitude in rad/s
      _latestGyroMagnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
    });

    // Listen to User Accelerometer stream (linear acceleration minus gravity)
    _userAccelSub = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!_isMonitoring) return;

      // Linear acceleration magnitude
      final accelMag = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Combined motion metric: accel delta + weighted rotational speed
      final combinedMotion = accelMag + (1.5 * _latestGyroMagnitude);

      final dataPoint = MotionDataPoint(
        combinedMotion: combinedMotion,
        accelDelta: accelMag,
        gyroRotation: _latestGyroMagnitude,
        timestamp: DateTime.now(),
      );

      _motionStreamController.add(dataPoint);

      // Check threshold and debounce count
      final double threshold = settings.sensitivity == MotionSensitivity.custom
          ? settings.customThreshold
          : settings.sensitivity.thresholdAcceleration;

      final int requiredSamples = settings.sensitivity.requiredConsecutiveSamples;

      if (combinedMotion >= threshold) {
        _consecutiveHighMotionCount++;

        // Require N consecutive high-motion samples to confirm trigger
        if (_consecutiveHighMotionCount >= requiredSamples) {
          final now = DateTime.now();
          // Prevent multiple triggers within 10 seconds cooldown window
          if (_lastTriggerTime == null ||
              now.difference(_lastTriggerTime!).inSeconds > 10) {
            _lastTriggerTime = now;
            _consecutiveHighMotionCount = 0;
            onTriggerCallback?.call();
          }
        }
      } else {
        // Reset counter if motion falls back below threshold
        _consecutiveHighMotionCount = max(0, _consecutiveHighMotionCount - 1);
      }
    });
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _userAccelSub?.cancel();
    _gyroSub?.cancel();
    _userAccelSub = null;
    _gyroSub = null;
    _consecutiveHighMotionCount = 0;
  }

  void dispose() {
    stopMonitoring();
    _motionStreamController.close();
  }
}
