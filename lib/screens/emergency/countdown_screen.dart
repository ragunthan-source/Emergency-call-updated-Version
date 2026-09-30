import 'package:flutter/material.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class CountdownScreen extends StatelessWidget {
  final AppState appState;

  const CountdownScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final remaining = appState.countdownRemaining;
    final total = appState.settings.countdownDurationSeconds;
    final isSilent = appState.settings.silentSosMode;

    return Scaffold(
      backgroundColor: isSilent ? Colors.black : AppTheme.emergencyRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  Icon(
                    isSilent ? Icons.volume_off : Icons.warning_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSilent ? 'SILENT EMERGENCY TRIGGERED' : 'EMERGENCY ALERT TRIGGERED!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSilent
                        ? 'Alerting contacts silently without sound or vibration...'
                        : 'Movement detected above threshold! SOS sequence starting soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),

              // Large Countdown Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: remaining / total,
                      strokeWidth: 14,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$remaining',
                        style: const TextStyle(
                          fontSize: 84,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'SECONDS',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.emergencyRed,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.cancel, size: 32),
                      label: const Text(
                        'CANCEL ALERT / DISARM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        appState.cancelCountdown();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap Cancel immediately if this was an accidental movement',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
