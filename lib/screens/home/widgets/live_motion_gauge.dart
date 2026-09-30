import 'package:flutter/material.dart';
import '../../../models/app_settings.dart';
import '../../../providers/app_state.dart';
import '../../../theme/app_theme.dart';

class LiveMotionGauge extends StatelessWidget {
  final AppState appState;

  const LiveMotionGauge({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final liveMotion = appState.latestMotionPoint?.combinedMotion ?? 0.0;
    final accel = appState.latestMotionPoint?.accelDelta ?? 0.0;
    final gyro = appState.latestMotionPoint?.gyroRotation ?? 0.0;
    final sensitivity = appState.settings.sensitivity;
    final threshold = sensitivity == MotionSensitivity.custom
        ? appState.settings.customThreshold
        : sensitivity.thresholdAcceleration;

    final isExceeding = liveMotion >= threshold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExceeding ? AppTheme.emergencyRed : AppTheme.surfaceGlass,
          width: isExceeding ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.sensors, color: AppTheme.amberWarning, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Real-Time Motion Monitor',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGlass,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sensitivity: ${sensitivity.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${liveMotion.toStringAsFixed(1)} m/s²',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isExceeding ? AppTheme.emergencyRed : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Accel: ${accel.toStringAsFixed(1)} | Gyro: ${gyro.toStringAsFixed(1)} rad/s',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Text(
                'Trigger at >= ${threshold.toStringAsFixed(1)} m/s²',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.amberWarning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (liveMotion / 30.0).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.black38,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExceeding ? AppTheme.emergencyRed : AppTheme.armedGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
