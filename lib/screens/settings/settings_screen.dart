import 'package:flutter/material.dart';

import '../../models/app_settings.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../onboarding/onboarding_flow_screen.dart';
import 'contacts_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bloodCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _templateCtrl;

  @override
  void initState() {
    super.initState();
    final profile = widget.appState.userProfile;
    _nameCtrl = TextEditingController(text: profile.name);
    _bloodCtrl = TextEditingController(text: profile.bloodGroup);
    _notesCtrl = TextEditingController(text: profile.medicalNotes);
    _templateCtrl = TextEditingController(text: profile.emergencyMessageTemplate);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bloodCtrl.dispose();
    _notesCtrl.dispose();
    _templateCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updated = widget.appState.userProfile.copyWith(
      name: _nameCtrl.text.trim(),
      bloodGroup: _bloodCtrl.text.trim(),
      medicalNotes: _notesCtrl.text.trim(),
      emergencyMessageTemplate: _templateCtrl.text.trim(),
    );
    widget.appState.saveProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.appState.settings;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Contacts Management
          Card(
            child: ListTile(
              leading: const Icon(Icons.contacts, color: AppTheme.emergencyRed),
              title: const Text('Manage Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${widget.appState.contacts.length} priority contacts configured'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactsManagerScreen(appState: widget.appState),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Section: Motion Sensitivity Calibration
          const Text('MOTION TRIGGER & CALIBRATION',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Motion Sensitivity Level', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(settings.sensitivity.displayName),
                ),
                ...MotionSensitivity.values.where((s) => s != MotionSensitivity.custom).map((sens) {
                  return RadioListTile<MotionSensitivity>(
                    value: sens,
                    groupValue: settings.sensitivity,
                    title: Text(sens.name.toUpperCase()),
                    subtitle: Text('${sens.thresholdAcceleration} m/s² threshold'),
                    activeColor: AppTheme.emergencyRed,
                    onChanged: (val) {
                      if (val != null) {
                        widget.appState.saveSettings(settings.copyWith(sensitivity: val));
                      }
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Section: Emergency Sequence Options
          const Text('EMERGENCY SEQUENCE OPTIONS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Countdown Alert Duration'),
                  subtitle: Text('${settings.countdownDurationSeconds} seconds'),
                  trailing: DropdownButton<int>(
                    value: settings.countdownDurationSeconds,
                    dropdownColor: AppTheme.darkCardBg,
                    items: [5, 7, 10].map((sec) {
                      return DropdownMenuItem(value: sec, child: Text('$sec seconds'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.appState.saveSettings(settings.copyWith(countdownDurationSeconds: val));
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Call Timeout Per Contact'),
                  subtitle: Text('${settings.callTimeoutSeconds}s before dialing next priority contact'),
                  trailing: DropdownButton<int>(
                    value: settings.callTimeoutSeconds,
                    dropdownColor: AppTheme.darkCardBg,
                    items: [10, 15, 20, 30].map((sec) {
                      return DropdownMenuItem(value: sec, child: Text('$sec s'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.appState.saveSettings(settings.copyWith(callTimeoutSeconds: val));
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Auto-Disarm Session Timer'),
                  subtitle: Text(settings.autoDisarmHours == 0
                      ? 'Disabled (Stay armed)'
                      : 'Disarm automatically after ${settings.autoDisarmHours} hours'),
                  trailing: DropdownButton<int>(
                    value: settings.autoDisarmHours,
                    dropdownColor: AppTheme.darkCardBg,
                    items: [0, 1, 2, 4, 8].map((hrs) {
                      return DropdownMenuItem(
                          value: hrs, child: Text(hrs == 0 ? 'Off' : '$hrs hrs'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.appState.saveSettings(settings.copyWith(autoDisarmHours: val));
                      }
                    },
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Silent SOS Mode'),
                  subtitle: const Text('Trigger alerts without alarm sound or vibration'),
                  value: settings.silentSosMode,
                  activeColor: AppTheme.amberWarning,
                  onChanged: (val) {
                    widget.appState.saveSettings(settings.copyWith(silentSosMode: val));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Section: Edit User Profile & Template
          const Text('USER PROFILE & SOS MESSAGE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bloodCtrl,
                    decoration: const InputDecoration(labelText: 'Blood Group'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(labelText: 'Medical Notes'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _templateCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'SOS Message Template ([NAME], [LOCATION_LINK])',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile & Template'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Re-run Onboarding Assistant
          Card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt, color: AppTheme.amberWarning),
              title: const Text('Re-run Setup Assistant'),
              subtitle: const Text('Walk through the initial onboarding wizard again'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnboardingFlowScreen(
                      appState: widget.appState,
                      onOnboardingCompleted: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
