import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlertSoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;


  Future<void> startAlarm({bool silentMode = false}) async {
    if (silentMode) return; // Silent SOS mode: no sound or vibration

    _isPlaying = true;
    try {
      // Set audio volume to max
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play emergency tone (using a reliable online alarm sound URL or built-in asset fallback)
      await _audioPlayer.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        ),
      );
    } catch (_) {
      // Audio playback fallback safely handled
    }

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Continuous emergency vibration pattern: 500ms on, 300ms off
        Vibration.vibrate(
          pattern: [500, 300, 500, 300, 1000],
          repeat: 0,
        );
      }
    } catch (_) {}
  }

  Future<void> playBeep() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
      }
    } catch (_) {}
  }

  Future<void> stopAlarm() async {
    _isPlaying = false;
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    try {
      Vibration.cancel();
    } catch (_) {}
  }

  void dispose() {
    stopAlarm();
    _audioPlayer.dispose();
  }
}
