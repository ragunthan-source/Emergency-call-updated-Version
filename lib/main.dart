import 'package:flutter/material.dart';

import 'providers/app_state.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.initialize();

  runApp(EmergencyApp(appState: appState));
}

class EmergencyApp extends StatefulWidget {
  final AppState appState;

  const EmergencyApp({super.key, required this.appState});

  @override
  State<EmergencyApp> createState() => _EmergencyAppState();
}

class _EmergencyAppState extends State<EmergencyApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, child) {
        final profile = widget.appState.userProfile;
        final isFirstLaunch = !profile.onboardingCompleted;

        return MaterialApp(
          title: 'Emergency Call - Updated Version',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: isFirstLaunch
              ? OnboardingFlowScreen(
                  appState: widget.appState,
                  onOnboardingCompleted: () {
                    setState(() {});
                  },
                )
              : HomeScreen(appState: widget.appState),
        );
      },
    );
  }
}
