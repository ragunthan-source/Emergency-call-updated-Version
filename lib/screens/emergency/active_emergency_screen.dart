import 'package:flutter/material.dart';
import '../../providers/app_state.dart';
import '../../services/emergency_service.dart';
import '../../theme/app_theme.dart';

class ActiveEmergencyScreen extends StatelessWidget {
  final AppState appState;

  const ActiveEmergencyScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final status = appState.emergencyExecutionStatus;
    final contacts = appState.contacts;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('ACTIVE EMERGENCY RESPONSE'),
        backgroundColor: AppTheme.emergencyRed,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Current Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.emergencyRed, width: 2),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.emergencyRed,
                      radius: 24,
                      child: Icon(Icons.emergency, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status?.currentAction ?? 'Processing Emergency Protocol...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SMS Sent: ${status?.contactsNotified ?? 0} | Calls Attempted: ${status?.callsAttempted ?? 0}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Event Timeline Header
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Live Incident Timeline',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),

              // Timeline List
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGlass.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListView.builder(
                    itemCount: status?.timeline.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = status!.timeline[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right, color: AppTheme.amberWarning, size: 20),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Direct Manual Call Fallback Grid
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Manual Dial Fallback:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.call, size: 18, color: Colors.white),
                        label: Text(contact.name),
                        backgroundColor: AppTheme.surfaceGlass,
                        onPressed: () {
                          EmergencyService.launchDirectCall(contact.phoneNumber);
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Resolve / Dismiss Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('MARK EMERGENCY RESOLVED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.armedGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    appState.dismissEmergencyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
