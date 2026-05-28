import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../state/game_store.dart';

/// Sound effects service for the Sudoku app
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  Future<void> init(GameStore store) async {
    if (_initialized) return;
    _soundEnabled = store.soundEnabled;
    _hapticEnabled = store.hapticEnabled;
    _initialized = true;

    // Configure audio player for short sound effects
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(0.5);
  }

  void updateSettings({bool? sound, bool? haptic}) {
    if (sound != null) _soundEnabled = sound;
    if (haptic != null) _hapticEnabled = haptic;
  }

  // ─── Sound Effects ───

  /// Play when tapping a cell
  Future<void> playTap() async {
    _haptic(HapticFeedback.selectionClick);
    if (!_soundEnabled) return;
    await _playTone(800, 30);
  }

  /// Play when inputting a number
  Future<void> playInput() async {
    _haptic(HapticFeedback.lightImpact);
    if (!_soundEnabled) return;
    await _playTone(1000, 50);
  }

  /// Play when number is correct
  Future<void> playCorrect() async {
    _haptic(HapticFeedback.lightImpact);
    if (!_soundEnabled) return;
    await _playTone(1200, 80);
  }

  /// Play when number is wrong
  Future<void> playWrong() async {
    _haptic(HapticFeedback.heavyImpact);
    if (!_soundEnabled) return;
    await _playTone(300, 150);
  }

  /// Play when completing a row/column/box
  Future<void> playComplete() async {
    _haptic(HapticFeedback.mediumImpact);
    if (!_soundEnabled) return;
    // Play ascending notes
    await _playTone(800, 60);
    await Future.delayed(const Duration(milliseconds: 70));
    await _playTone(1000, 60);
    await Future.delayed(const Duration(milliseconds: 70));
    await _playTone(1200, 80);
  }

  /// Play when winning the game
  Future<void> playWin() async {
    _haptic(HapticFeedback.heavyImpact);
    if (!_soundEnabled) return;
    // Victory fanfare
    await _playTone(800, 100);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(1000, 100);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(1200, 100);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(1600, 200);
  }

  /// Play when losing the game
  Future<void> playLose() async {
    _haptic(HapticFeedback.vibrate);
    if (!_soundEnabled) return;
    // Sad descending notes
    await _playTone(600, 150);
    await Future.delayed(const Duration(milliseconds: 150));
    await _playTone(400, 150);
    await Future.delayed(const Duration(milliseconds: 150));
    await _playTone(300, 300);
  }

  /// Play when unlocking an achievement
  Future<void> playAchievement() async {
    _haptic(HapticFeedback.mediumImpact);
    if (!_soundEnabled) return;
    // Special achievement sound
    await _playTone(1000, 80);
    await Future.delayed(const Duration(milliseconds: 80));
    await _playTone(1200, 80);
    await Future.delayed(const Duration(milliseconds: 80));
    await _playTone(1500, 120);
  }

  /// Play when using a hint
  Future<void> playHint() async {
    _haptic(HapticFeedback.mediumImpact);
    if (!_soundEnabled) return;
    await _playTone(600, 100);
    await Future.delayed(const Duration(milliseconds: 50));
    await _playTone(900, 100);
  }

  /// Play when erasing
  Future<void> playErase() async {
    _haptic(HapticFeedback.lightImpact);
    if (!_soundEnabled) return;
    await _playTone(500, 50);
  }

  /// Play when undoing
  Future<void> playUndo() async {
    _haptic(HapticFeedback.lightImpact);
    if (!_soundEnabled) return;
    await _playTone(700, 40);
    await Future.delayed(const Duration(milliseconds: 40));
    await _playTone(500, 40);
  }

  /// Play button click
  Future<void> playClick() async {
    _haptic(HapticFeedback.lightImpact);
    if (!_soundEnabled) return;
    await _playTone(900, 30);
  }

  // ─── Internal Methods ───

  Future<void> _playTone(int frequency, int durationMs) async {
    try {
      // Generate a simple tone using BytesSource
      // For now, we'll use system sounds via haptic feedback
      // In a full implementation, you'd generate WAV data or use asset files
    } catch (e) {
      // Ignore audio errors
    }
  }

  void _haptic(Function hapticFunction) {
    if (_hapticEnabled) {
      hapticFunction();
    }
  }

  void dispose() {
    _player.dispose();
  }
}

/// Extension for easier haptic feedback
extension HapticHelper on SoundService {
  void selectionClick() => _haptic(HapticFeedback.selectionClick);
  void lightImpact() => _haptic(HapticFeedback.lightImpact);
  void mediumImpact() => _haptic(HapticFeedback.mediumImpact);
  void heavyImpact() => _haptic(HapticFeedback.heavyImpact);
  void vibrate() => _haptic(HapticFeedback.vibrate);
}
