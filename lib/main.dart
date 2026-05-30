import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'state/game_store.dart';
import 'state/game_state.dart';
import 'services/sound_service.dart';
import 'services/ad_service.dart';
import 'services/deep_link_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/gdpr_consent_dialog.dart';
import 'widgets/legal_modal.dart';
import 'theme/app_theme.dart';
import 'theme/board_themes.dart';

bool _firebaseInitialized = false;

Future<void> _initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      _firebaseInitialized = true;
      return;
    }

    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    _firebaseInitialized = false;
    debugPrint('Firebase initialization failed: $e');
  }
}

bool get isFirebaseAvailable => _firebaseInitialized;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await _initializeFirebase();
  runApp(const SudokuApp());
}

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  final GameStore _store = GameStore();
  final GameState _gameState = GameState();
  bool _showSplash = true;
  bool _loaded = false;
  bool _showGdprConsent = false;

  // Deep link handling
  final DeepLinkService _deepLinkService = DeepLinkService();
  StreamSubscription<DeepLinkData>? _deepLinkSubscription;
  String? _pendingChallengePin;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) async {
      await SoundService().init(_store);

      // Initialize ads if consent already given
      if (_store.gdprConsentGiven && _store.adsConsent) {
        await AdService().initialize();
      }

      // Initialize deep links
      await _deepLinkService.initialize();
      _deepLinkSubscription = _deepLinkService.linkStream.listen(_handleDeepLink);

      setState(() {
        _loaded = true;
        _showGdprConsent = _store.needsGdprConsent;
      });
    });
    _store.addListener(() {
      // Update sound service when settings change
      SoundService().updateSettings(
        sound: _store.soundEnabled,
        haptic: _store.hapticEnabled,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _handleDeepLink(DeepLinkData data) {
    debugPrint('Main: Handling deep link - $data');

    if (data.type == DeepLinkType.challenge && data.challengePin != null) {
      // Store the pin and show challenge dialog when ready
      _pendingChallengePin = data.challengePin;

      // If app is loaded and not showing splash, show the challenge dialog
      if (_loaded && !_showSplash && !_showGdprConsent && navigatorKey.currentContext != null) {
        _showChallengeFromDeepLink();
      }
    }
  }

  void _showChallengeFromDeepLink() {
    if (_pendingChallengePin == null) return;

    // Rebuild the home screen with the challenge PIN
    // This will trigger the modal to show automatically
    setState(() {});
  }

  /// Initialize ads after consent is given
  Future<void> _initializeAdsAfterConsent() async {
    if (_store.adsConsent) {
      await AdService().initialize();
    }
  }

  void _toggleTheme() {
    _store.toggleTheme();
  }

  AppColorScheme get _colors {
    final theme = ColorThemes.fromId(_store.colorThemeId);
    return AppColors.fromColorTheme(theme, isDark: _store.isDark);
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => LegalModal(
        colors: _colors,
        documentType: LegalDocumentType.privacyPolicy,
      ),
    );
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Segoe UI'),
      home: _showSplash
          ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
          : !_loaded
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _buildHomeWithGdpr(),
    );
  }

  Widget _buildHomeWithGdpr() {
    // Show GDPR consent dialog on first launch
    if (_showGdprConsent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showGdprConsent && navigatorKey.currentContext != null) {
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: false,
            builder: (_) => GdprConsentDialog(
              colors: _colors,
              onAcceptAll: () {
                _store.acceptAllConsent();
                setState(() => _showGdprConsent = false);
                Navigator.pop(navigatorKey.currentContext!);
                _initializeAdsAfterConsent();
              },
              onAcceptEssential: () {
                _store.acceptEssentialOnly();
                setState(() => _showGdprConsent = false);
                Navigator.pop(navigatorKey.currentContext!);
                // No ads for essential-only consent
              },
              onShowPrivacyPolicy: _showPrivacyPolicy,
            ),
          );
        }
      });
    }

    // Consume the pending challenge PIN
    final challengePin = _pendingChallengePin;
    _pendingChallengePin = null;

    return HomeScreen(
      store: _store,
      gameState: _gameState,
      onToggleTheme: _toggleTheme,
      initialChallengePin: challengePin,
    );
  }
}
