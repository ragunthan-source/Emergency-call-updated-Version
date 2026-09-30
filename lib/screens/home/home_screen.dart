import 'package:flutter/material.dart';

import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../emergency/active_emergency_screen.dart';
import '../emergency/countdown_screen.dart';
import '../history/incident_history_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/arm_status_card.dart';
import 'widgets/emergency_numbers.dart';
import 'widgets/health_check_card.dart';
import 'widgets/live_motion_gauge.dart';
import 'widgets/quick_actions.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;

    // Overlay 1: Active Countdown Screen
    if (appState.isCountdownActive) {
      return CountdownScreen(appState: appState);
    }

    // Overlay 2: Active Emergency Execution Screen
    if (appState.isEmergencyActive) {
      return ActiveEmergencyScreen(appState: appState);
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emergency, color: AppTheme.emergencyRed),
            SizedBox(width: 8),
            Text('Emergency Call'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(appState: widget.appState),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildDashboardTab(appState),
          IncidentHistoryScreen(appState: appState),
          SettingsScreen(appState: appState),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        backgroundColor: AppTheme.darkCardBg,
        selectedItemColor: AppTheme.emergencyRed,
        unselectedItemColor: AppTheme.textSecondary,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(AppState appState) {
    final name = appState.userProfile.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header
          if (name.isNotEmpty) ...[
            Text(
              'Hello, $name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Motion monitoring and emergency response ready.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
          ],

          // Permission Health Check Warning (if missing permissions)
          HealthCheckCard(appState: appState),

          // Prominent Arm / Disarm Toggle Card
          ArmStatusCard(appState: appState),

          const SizedBox(height: 16),

          // Real-time Motion Gauge
          LiveMotionGauge(appState: appState),

          const SizedBox(height: 20),

          // Quick SOS & Silent Actions
          QuickActionsWidget(appState: appState),

          const SizedBox(height: 20),

          // Local Emergency Direct Dial Numbers
          const EmergencyNumbersWidget(),
        ],
      ),
    );
  }
}
