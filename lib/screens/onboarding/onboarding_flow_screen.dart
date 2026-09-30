import 'package:flutter/material.dart';

import '../../models/emergency_contact.dart';
import '../../models/app_settings.dart';
import '../../providers/app_state.dart';
import '../../services/permission_service.dart';
import '../../theme/app_theme.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOnboardingCompleted;

  const OnboardingFlowScreen({
    super.key,
    required this.appState,
    required this.onOnboardingCompleted,
  });

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 Controllers
  late TextEditingController _nameController;
  late TextEditingController _bloodController;
  late TextEditingController _notesController;

  // Step 2 Controller
  late TextEditingController _sosMessageController;

  // Step 3 Contacts state
  List<EmergencyContact> _tempContacts = [];

  // Step 5 Sensitivity state
  MotionSensitivity _selectedSensitivity = MotionSensitivity.medium;

  // Step 7 Battery/Boot state
  bool _startOnBoot = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.appState.userProfile.name);
    _bloodController = TextEditingController(text: widget.appState.userProfile.bloodGroup);
    _notesController = TextEditingController(text: widget.appState.userProfile.medicalNotes);
    _sosMessageController = TextEditingController(
        text: widget.appState.userProfile.emergencyMessageTemplate);
    _tempContacts = List.from(widget.appState.contacts);
    _selectedSensitivity = widget.appState.settings.sensitivity;
    _startOnBoot = widget.appState.settings.startOnBoot;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodController.dispose();
    _notesController.dispose();
    _sosMessageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final updatedProfile = widget.appState.userProfile.copyWith(
      name: _nameController.text.trim(),
      bloodGroup: _bloodController.text.trim(),
      medicalNotes: _notesController.text.trim(),
      emergencyMessageTemplate: _sosMessageController.text.trim(),
      onboardingCompleted: true,
    );

    await widget.appState.saveProfile(updatedProfile);
    await widget.appState.saveContacts(_tempContacts);
    await widget.appState.saveSettings(
      widget.appState.settings.copyWith(
        sensitivity: _selectedSensitivity,
        startOnBoot: _startOnBoot,
        isArmed: true, // Armed by default upon onboarding completion
      ),
    );

    widget.appState.setArmed(true);
    widget.onOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text('Setup Assistant (${_currentStep + 1}/7)'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 7,
              backgroundColor: AppTheme.surfaceGlass,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emergencyRed),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStep1Profile(),
                  _buildStep2SosTemplate(),
                  _buildStep3Contacts(),
                  _buildStep4Permissions(),
                  _buildStep5Calibration(),
                  _buildStep6ArmDisarmInfo(),
                  _buildStep7BootBattery(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevPage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: AppTheme.surfaceGlass),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emergencyRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(_currentStep == 6 ? 'Complete & Arm App' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: User Profile
  Widget _buildStep1Profile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_pin, size: 50, color: AppTheme.emergencyRed),
          const SizedBox(height: 12),
          const Text(
            'User Emergency Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your basic details so emergency responders and contacts receive vital information instantly.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bloodController,
            decoration: const InputDecoration(
              labelText: 'Blood Group (Optional, e.g. O+, A-)',
              prefixIcon: Icon(Icons.bloodtype),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Medical Notes / Allergies (Optional)',
              prefixIcon: Icon(Icons.medical_information),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: SOS Template
  Widget _buildStep2SosTemplate() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sms, size: 50, color: AppTheme.amberWarning),
          const SizedBox(height: 12),
          const Text(
            'Custom SOS Message',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize the emergency message automatically sent to your contacts with live GPS coordinates.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _sosMessageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Emergency Message Template',
              border: OutlineInputBorder(),
              helperText: 'Available placeholders: [NAME], [LOCATION_LINK]',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message Preview:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.amberWarning),
                ),
                const SizedBox(height: 6),
                Text(
                  _sosMessageController.text
                      .replaceAll('[NAME]', _nameController.text.isEmpty ? 'User' : _nameController.text)
                      .replaceAll('[LOCATION_LINK]', 'https://maps.google.com/?q=37.7749,-122.4194'),
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Emergency Contacts Priority List
  Widget _buildStep3Contacts() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Emergency Contacts',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.armedGreen, size: 30),
                    onPressed: _showAddContactDialog,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Drag contacts to reorder priority. High priority contacts will be called first.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: _tempContacts.isEmpty
              ? const Center(
                  child: Text('No contacts added yet. Tap + to add.'),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _tempContacts.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _tempContacts.removeAt(oldIndex);
                      _tempContacts.insert(newIndex, item);

                      for (int i = 0; i < _tempContacts.length; i++) {
                        _tempContacts[i] = _tempContacts[i].copyWith(priority: i + 1);
                      }
                    });
                  },
                  itemBuilder: (context, index) {
                    final contact = _tempContacts[index];
                    return Card(
                      key: ValueKey(contact.id),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.emergencyRed,
                          child: Text('#${index + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${contact.phoneNumber} (${contact.relationship})'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                contact.callEnabled ? Icons.phone_in_talk : Icons.phone_disabled,
                                color: contact.callEnabled ? AppTheme.armedGreen : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _tempContacts[index] = contact.copyWith(
                                    callEnabled: !contact.callEnabled,
                                  );
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _tempContacts.removeAt(index);
                                });
                              },
                            ),
                            const Icon(Icons.drag_handle),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController(text: 'Family');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name *'),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number *'),
            ),
            TextField(
              controller: relationCtrl,
              decoration: const InputDecoration(labelText: 'Relationship (e.g. Spouse/Hospital)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _tempContacts.add(
                    EmergencyContact(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      relationship: relationCtrl.text.trim(),
                      priority: _tempContacts.length + 1,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }

  // STEP 4: Request Permissions
  Widget _buildStep4Permissions() {
    final report = widget.appState.permissionReport;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security, size: 50, color: AppTheme.armedGreen),
          const SizedBox(height: 12),
          const Text(
            'Grant Essential Permissions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Emergency Call requires system permissions to monitor movement, grab GPS coordinates, and place emergency calls.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildPermissionTile(
            title: 'Motion Sensors (Accelerometer/Gyro)',
            subtitle: 'Detect sudden movement & phone disturbance',
            isGranted: report?.sensorsGranted ?? false,
          ),
          _buildPermissionTile(
            title: 'Location Services (GPS)',
            subtitle: 'Embed live Google Maps location link in SOS SMS',
            isGranted: report?.locationGranted ?? false,
          ),
          _buildPermissionTile(
            title: 'SMS Transmission',
            subtitle: 'Send instant emergency SMS alerts to contacts',
            isGranted: report?.smsGranted ?? false,
          ),
          _buildPermissionTile(
            title: 'Phone Calls',
            subtitle: 'Auto-dial emergency contacts in priority order',
            isGranted: report?.phoneGranted ?? false,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Grant All Permissions Now'),
              onPressed: () async {
                await PermissionService.requestAllPermissions();
                await widget.appState.refreshPermissions();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool isGranted,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(
          isGranted ? Icons.check_circle : Icons.warning_amber_rounded,
          color: isGranted ? AppTheme.armedGreen : AppTheme.amberWarning,
          size: 28,
        ),
      ),
    );
  }

  // STEP 5: Motion Calibration
  Widget _buildStep5Calibration() {
    final liveMotion = widget.appState.latestMotionPoint?.combinedMotion ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.speed, size: 50, color: AppTheme.amberWarning),
          const SizedBox(height: 12),
          const Text(
            'Motion Sensitivity Calibration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'IMPORTANT: This app triggers on ANY noticeable movement (walking, jerking, dropping). Calibrate carefully to prevent false alarms.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceGlass),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Live Sensor Reading:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${liveMotion.toStringAsFixed(1)} m/s²',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: liveMotion >= _selectedSensitivity.thresholdAcceleration
                            ? AppTheme.emergencyRed
                            : AppTheme.armedGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (liveMotion / 30.0).clamp(0.0, 1.0),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: Colors.black26,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    liveMotion >= _selectedSensitivity.thresholdAcceleration
                        ? AppTheme.emergencyRed
                        : AppTheme.armedGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Current Trigger Threshold: ${_selectedSensitivity.thresholdAcceleration} m/s²',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Select Sensitivity Level:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...MotionSensitivity.values.where((s) => s != MotionSensitivity.custom).map((sens) {
            return RadioListTile<MotionSensitivity>(
              value: sens,
              groupValue: _selectedSensitivity,
              title: Text(sens.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(sens.displayName),
              activeColor: AppTheme.emergencyRed,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSensitivity = val;
                  });
                }
              },
            );
          }),
        ],
      ),
    );
  }

  // STEP 6: Arm / Disarm Mode Explanation
  Widget _buildStep6ArmDisarmInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield, size: 60, color: AppTheme.emergencyRed),
          const SizedBox(height: 16),
          const Text(
            'Arm & Disarm Protection',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'The app defaults to ARMED when opened. When Armed, motion sensors actively monitor your phone.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: AppTheme.armedGreen),
                    title: Text('ARMED State'),
                    subtitle: Text('Continuous monitoring. Persistent status notification active.'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.cancel, color: Colors.grey),
                    title: Text('DISARMED State'),
                    subtitle: Text('Sensors paused. No automatic motion alerts will fire.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 7: Start on Boot & Battery Optimizations
  Widget _buildStep7BootBattery() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.battery_saver, size: 50, color: AppTheme.armedGreen),
          const SizedBox(height: 12),
          const Text(
            'Background Service & Boot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ensure the app remains active in the background and starts automatically on device boot.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Start monitoring on system boot', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Automatically resume Armed state when device restarts'),
            value: _startOnBoot,
            activeColor: AppTheme.emergencyRed,
            onChanged: (val) {
              setState(() {
                _startOnBoot = val;
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.amberWarning),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'On Android devices, please exempt Emergency Call from Battery Optimization settings to prevent background service termination.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
