# Emergency Call - Updated Version 🚨

A cross-platform mobile application built with **Flutter (Android + iOS)** designed for rapid personal emergency response. The app automatically triggers a high-priority emergency sequence when movement is detected after the phone is armed.

---

## 🌟 Key Features

### 1. Motion Detection Engine (General Movement Trigger)
- **Beyond Shake Gestures**: Detects general physical disturbances (walking, jerking, dropping, sudden tilts, displacement) by fusing **Linear Acceleration** (`sensors_plus`) and **Gyroscope angular velocity**.
- **Movement Magnitude Vector**:
  $$\text{Motion Metric } M = |\mathbf{a}| + 1.5 \times |\boldsymbol{\omega}|$$
- **Debounce & False-Positive Filter**: Requires $N$ consecutive high-motion readings sustained over ~200–400ms to filter out accidental bumps or normal phone handling.
- **Configurable Sensitivity**:
  - **Low**: $19.0\text{ m/s}^2$ threshold, 4 consecutive samples (strongest false-positive rejection).
  - **Medium**: $14.5\text{ m/s}^2$ threshold, 3 consecutive samples (balanced daily monitoring).
  - **High**: $10.0\text{ m/s}^2$ threshold, 2 consecutive samples (hyper-sensitive to slight motions).
  - **Custom**: User-calibrated sensitivity.

### 2. Onboarding & First-Launch Setup Wizard (7-Step Flow)
1. **User Emergency Profile**: Full name, blood group, medical notes & allergy warnings.
2. **Custom SOS Template**: Editable message with auto-inserted `[NAME]` and `[LOCATION_LINK]` placeholders.
3. **Priority Emergency Contacts**: Reorderable drag-and-drop contact list with individual "Call" and "SMS" toggles.
4. **Permissions Explainer & Requester**: Location (foreground + background), SMS, Phone calls, Motion sensors.
5. **Interactive Motion Calibration**: Live sensor gauge displaying real-time acceleration levels before arming.
6. **Arm / Disarm Philosophy**: Clear visual explanation of the armed monitoring state vs. paused state.
7. **Boot & Battery Optimization**: Background service persistence and start-on-boot configuration.

### 3. Emergency Alert & Countdown
- **Full-Screen Emergency Alert**: 5–10 second animated countdown timer.
- **Loud Siren + Vibration**: Maximum volume alarm and pulsing vibration patterns (or **Silent SOS Mode** for dangerous situations).
- **One-Tap Cancel/Disarm**: Allows user to immediately cancel accidental triggers before messages or calls fire.

### 4. Emergency Sequence Protocol (On Countdown Expiry)
1. **High-Precision GPS Fetch**: Obtains current coordinates with fallback to last known location.
2. **Simultaneous SMS Broadcast**: Sends customized SOS message with live Google Maps link to all pre-set contacts.
3. **Sequential Priority Auto-Dialing**:
   - Automatically dials Contact #1.
   - Monitors call duration/timeout (e.g. 15s).
   - If unanswered or short duration, immediately dials Contact #2 down the list.
   - Loops through list twice before activating persistent "Emergency Not Resolved" manual screen.
4. **Incident History Logging**: Persists every alert event, timestamps, coordinates, and step-by-step timeline.

---

## 📱 Platform Specifics

### Android
- **Foreground Service**: Persistent status notification (*"Emergency Call is Armed and monitoring"*) prevents Android OS from killing the sensor listener.
- **Auto-Dialing**: Uses `tel:` and telephony platform channels with sequential call progression.
- **Boot Receiver**: Resumes monitoring on reboot if enabled.

### iOS
- **Graceful Degradation**: iOS sandboxing prevents programmatic dialer automation; opens pre-filled dialer with one-tap confirmation for each priority contact.
- **Background Location**: Configured with `NSLocationAlwaysAndWhenInUseUsageDescription`.

---

## 📁 Project Architecture

```
lib/
├── main.dart                          # App initialization, theme, root widget
├── models/
│   ├── app_settings.dart              # Sensitivity enums, timeouts, countdown config
│   ├── emergency_contact.dart         # Contact entity with priority & call/sms toggles
│   ├── incident_log.dart              # Incident history model with timeline events
│   └── user_profile.dart              # User profile & SOS message template
├── providers/
│   └── app_state.dart                 # Central state coordinator (ChangeNotifier)
├── screens/
│   ├── emergency/
│   │   ├── active_emergency_screen.dart # Real-time emergency execution tracker
│   │   └── countdown_screen.dart        # 5-10s full-screen alert & cancel screen
│   ├── history/
│   │   └── incident_history_screen.dart # Filterable past incident logs & map links
│   ├── home/
│   │   ├── home_screen.dart           # Dashboard with bottom navigation
│   │   └── widgets/
│   │       ├── arm_status_card.dart   # Prominent Armed/Disarmed card & switch
│   │       ├── emergency_numbers.dart # Quick 911 / 112 / 100 direct call shortcuts
│   │       ├── health_check_card.dart # Permission & battery status alert card
│   │       ├── live_motion_gauge.dart # Real-time m/s² sensor visualization
│   │       └── quick_actions.dart     # Manual SOS & Silent SOS switches
│   ├── onboarding/
│   │   └── onboarding_flow_screen.dart# 7-step onboarding & calibration wizard
│   └── settings/
│       ├── contacts_manager_screen.dart# Reorderable drag-and-drop contact list
│       └── settings_screen.dart       # App configuration & profile editor
├── services/
│   ├── alert_sound_service.dart       # High volume alarm tone & haptic vibration
│   ├── background_service.dart        # Persistent status notification helper
│   ├── emergency_service.dart         # SMS dispatch & sequential priority calling
│   ├── location_service.dart          # GPS location & Google Maps URL builder
│   ├── motion_service.dart            # Accelerometer + Gyroscope stream & debouncer
│   ├── permission_service.dart        # Permissions health check & request system
│   └── storage_service.dart           # Local persistence with SharedPreferences
└── theme/
    └── app_theme.dart                 # Dark mode & emergency color palette
```

---

## 🧪 Testing

Run automated tests:
```bash
flutter test
```
All unit tests verify model serialization, SOS placeholder replacement, motion sensitivity threshold calculations, and incident logging.
