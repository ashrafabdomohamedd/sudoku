import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // ═══════════════════════════════════════════════════════════════════════════
  // APP STORE LINKS - UPDATE THESE WITH YOUR ACTUAL STORE IDs
  // ═══════════════════════════════════════════════════════════════════════════

  // TODO: Replace with your actual App Store ID
  static const String _appStoreId = 'YOUR_APP_STORE_ID';

  // TODO: Replace with your actual Play Store package name
  static const String _playStorePackage = 'com.yourcompany.sudoku';

  // TODO: Replace with your website domain (for universal links)
  static const String _websiteDomain = 'https://yourapp.com';

  // Custom URL scheme for deep linking
  static const String _urlScheme = 'sudoku';

  // ═══════════════════════════════════════════════════════════════════════════
  // STORE LINKS
  // ═══════════════════════════════════════════════════════════════════════════

  String get playStoreUrl => 'https://play.google.com/store/apps/details?id=$_playStorePackage';

  String get appStoreUrl => 'https://apps.apple.com/app/id$_appStoreId';

  String get storeUrl {
    if (Platform.isAndroid) return playStoreUrl;
    if (Platform.isIOS) return appStoreUrl;
    return playStoreUrl; // Default to Play Store
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEEP LINKS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate a deep link to open the app
  String getAppLink() => '$_urlScheme://open';

  /// Generate a deep link for a challenge
  String getChallengeLink(String pin) => '$_urlScheme://challenge/$pin';

  /// Generate a web link that redirects to app or store
  String getWebLink({String? path}) {
    if (path != null) {
      return '$_websiteDomain/$path';
    }
    return _websiteDomain;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARE FUNCTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Share the app with friends
  Future<void> shareApp() async {
    const message = '''
🧩 Play Sudoku with me!

Challenge yourself with daily puzzles, compete on leaderboards, and track your progress!

Download now:
''';

    await Share.share('$message$storeUrl');
    debugPrint('ShareService: Shared app link');
  }

  /// Share a challenge invite
  Future<void> shareChallenge({
    required String pin,
    required String difficulty,
  }) async {
    final message = '''
🎮 I challenge you to a Sudoku duel!

Difficulty: ${difficulty[0].toUpperCase()}${difficulty.substring(1)}
Challenge PIN: $pin

1. Download Sudoku: $storeUrl
2. Open the app and tap "Challenge Friend"
3. Enter PIN: $pin

Let's see who solves it faster! ⏱️
''';

    await Share.share(message);
    debugPrint('ShareService: Shared challenge $pin');
  }

  /// Share game result (Wordle-style)
  Future<void> shareResult({
    required String difficulty,
    required int time,
    required int mistakes,
    required int streak,
    bool isDaily = false,
    int? dayNumber,
  }) async {
    final timeStr = '${(time ~/ 60).toString().padLeft(2, '0')}:${(time % 60).toString().padLeft(2, '0')}';

    String header;
    if (isDaily && dayNumber != null) {
      header = '🧩 Sudoku Daily #$dayNumber';
    } else {
      header = '🧩 Sudoku · ${difficulty[0].toUpperCase()}${difficulty.substring(1)}';
    }

    final mistakeEmoji = mistakes == 0 ? '✨' : '❌';
    final streakEmoji = streak > 0 ? ' · 🔥 $streak day streak' : '';

    final message = '''
$header
⏱️ $timeStr | $mistakeEmoji $mistakes mistakes$streakEmoji

Can you beat my time?
$storeUrl
''';

    await Share.share(message);
    debugPrint('ShareService: Shared result');
  }

  /// Share with custom message
  Future<void> shareCustom(String message) async {
    await Share.share(message);
  }
}
