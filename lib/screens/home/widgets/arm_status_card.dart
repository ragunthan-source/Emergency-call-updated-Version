import 'package:flutter/material.dart';
import '../../../providers/app_state.dart';
import '../../../theme/app_theme.dart';

class ArmStatusCard extends StatelessWidget {
  final AppState appState;

  const ArmStatusCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isArmed = appState.isArmed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isArmed
              ? [const Color(0xFF065F46), const Color(0xFF047857)]
              : [const Color(0xFF334155), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isArmed ? AppTheme.armedGreen : Colors.black).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isArmed ? Icons.shield : Icons.shield_outlined,
                    size: 36,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArmed ? 'APP IS ARMED' : 'APP IS DISARMED',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        isArmed
                            ? 'Motion sensors actively monitoring'
                            : 'Motion monitoring is paused',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: isArmed,
                  activeColor: Colors.white,
                  activeTrackColor: AppTheme.armedGreen,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.black26,
                  onChanged: (val) {
                    appState.setArmed(val);
                  },
                ),
              ),
            ],
          ),
          if (isArmed && appState.armedExpirationTime != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  'Auto-disarms at ${appState.armedExpirationTime!.toString().substring(11, 16)}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
