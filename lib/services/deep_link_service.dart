import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

/// Handles incoming deep links and app links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();

  // Stream controller for deep link events
  final _linkController = StreamController<DeepLinkData>.broadcast();
  Stream<DeepLinkData> get linkStream => _linkController.stream;

  StreamSubscription<Uri>? _subscription;

  /// Initialize the deep link listener
  Future<void> initialize() async {
    try {
      // Handle link that opened the app (cold start)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('DeepLinkService: Initial link - $initialUri');
        _handleUri(initialUri);
      }

      // Handle links while app is running (warm start)
      _subscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('DeepLinkService: Received link - $uri');
          _handleUri(uri);
        },
        onError: (error) {
          debugPrint('DeepLinkService: Error - $error');
        },
      );

      debugPrint('DeepLinkService: Initialized');
    } catch (e) {
      debugPrint('DeepLinkService: Failed to initialize - $e');
    }
  }

  void _handleUri(Uri uri) {
    final data = _parseUri(uri);
    if (data != null) {
      _linkController.add(data);
    }
  }

  DeepLinkData? _parseUri(Uri uri) {
    debugPrint('DeepLinkService: Parsing URI - scheme: ${uri.scheme}, host: ${uri.host}, path: ${uri.path}');

    // Handle custom scheme: sudoku://challenge/123456
    if (uri.scheme == 'sudoku') {
      if (uri.host == 'challenge' || uri.pathSegments.firstOrNull == 'challenge') {
        final pin = uri.pathSegments.length > 1
            ? uri.pathSegments[1]
            : uri.pathSegments.firstOrNull;
        if (pin != null && pin != 'challenge') {
          return DeepLinkData(type: DeepLinkType.challenge, challengePin: pin);
        }
      }
      return DeepLinkData(type: DeepLinkType.open);
    }

    // Handle https links: https://yourapp.com/challenge/123456
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      if (uri.pathSegments.contains('challenge')) {
        final challengeIndex = uri.pathSegments.indexOf('challenge');
        if (challengeIndex < uri.pathSegments.length - 1) {
          final pin = uri.pathSegments[challengeIndex + 1];
          return DeepLinkData(type: DeepLinkType.challenge, challengePin: pin);
        }
      }
      return DeepLinkData(type: DeepLinkType.open);
    }

    return null;
  }

  void dispose() {
    _subscription?.cancel();
    _linkController.close();
  }
}

enum DeepLinkType {
  open,      // Just open the app
  challenge, // Open a specific challenge
}

class DeepLinkData {
  final DeepLinkType type;
  final String? challengePin;

  DeepLinkData({
    required this.type,
    this.challengePin,
  });

  @override
  String toString() => 'DeepLinkData(type: $type, pin: $challengePin)';
}
