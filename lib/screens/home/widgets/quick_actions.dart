import 'package:flutter/material.dart';
import '../../../providers/app_state.dart';
import '../../../theme/app_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  final AppState appState;

  const QuickActionsWidget({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final settings = appState.settings;

    return Column(
      children: [
        // Giant Manual SOS Button
        SizedBox(
          width: double.infinity,
          height: 72,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.touch_app, size: 36),
            label: const Text(
              'MANUAL SOS TRIGGER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyRed,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              appState.triggerCountdown(triggerType: 'Manual SOS Button');
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            // Silent SOS Switch Tile
            Expanded(
              child: Card(
                child: SwitchListTile(
                  title: const Text('Silent SOS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('No siren sound', style: TextStyle(fontSize: 11)),
                  value: settings.silentSosMode,
                  activeColor: AppTheme.amberWarning,
                  dense: true,
                  onChanged: (val) {
                    appState.saveSettings(settings.copyWith(silentSosMode: val));
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Test Mode Simulation Button
            Expanded(
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    appState.executeEmergencySequence(
                      triggerType: 'Manual Test Run',
                      isTestMode: true,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.science, color: AppTheme.armedGreen, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Run Test Mode',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
