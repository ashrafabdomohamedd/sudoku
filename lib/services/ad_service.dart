import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ═══════════════════════════════════════════════════════════════════════════
  // AD UNIT IDS
  // ═══════════════════════════════════════════════════════════════════════════

  // Production Ad Unit IDs
  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-9989686575938822/8912798298';
  static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-9989686575938822/4019564261';
  static const String _rewardedAdUnitIdAndroid = 'ca-app-pub-9989686575938822/6627900365';

  // iOS uses same IDs (update if you have separate iOS ad units)
  static const String _bannerAdUnitIdIOS = 'ca-app-pub-9989686575938822/8912798298';
  static const String _interstitialAdUnitIdIOS = 'ca-app-pub-9989686575938822/4019564261';
  static const String _rewardedAdUnitIdIOS = 'ca-app-pub-9989686575938822/6627900365';

  // Test Ad Unit IDs (for development)
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';

  static const String _testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Set to false for production
  static const bool _useTestAds = kDebugMode;

  String get bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testBannerAdUnitIdAndroid : _testBannerAdUnitIdIOS;
    }
    return Platform.isAndroid ? _bannerAdUnitIdAndroid : _bannerAdUnitIdIOS;
  }

  String get interstitialAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testInterstitialAdUnitIdAndroid : _testInterstitialAdUnitIdIOS;
    }
    return Platform.isAndroid ? _interstitialAdUnitIdAndroid : _interstitialAdUnitIdIOS;
  }

  String get rewardedAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testRewardedAdUnitIdAndroid : _testRewardedAdUnitIdIOS;
    }
    return Platform.isAndroid ? _rewardedAdUnitIdAndroid : _rewardedAdUnitIdIOS;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  bool _initialized = false;
  bool get isInitialized => _initialized;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdService: Mobile Ads SDK initialized');

      // Pre-load ads
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('AdService: Failed to initialize - $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BANNER ADS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a banner ad widget
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('AdService: Banner ad opened'),
        onAdClosed: (ad) => debugPrint('AdService: Banner ad closed'),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERSTITIAL ADS
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isInterstitialAdReady => _isInterstitialAdReady;

  void _loadInterstitialAd() {
    if (!_initialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Pre-load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: Interstitial ad failed to show - $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial ad failed to load - $error');
          _isInterstitialAdReady = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Show interstitial ad (call after game completion)
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      debugPrint('AdService: Interstitial ad not ready');
      return false;
    }

    try {
      await _interstitialAd!.show();
      _interstitialAd = null;
      return true;
    } catch (e) {
      debugPrint('AdService: Failed to show interstitial - $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REWARDED ADS
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isRewardedAdReady => _isRewardedAdReady;

  void _loadRewardedAd() {
    if (!_initialized) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: Rewarded ad loaded');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Rewarded ad failed to load - $error');
          _isRewardedAdReady = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// Show rewarded ad (for hints)
  /// Returns true if user earned the reward
  Future<bool> showRewardedAd({
    required void Function() onUserEarnedReward,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('AdService: Rewarded ad not ready');
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: Rewarded ad dismissed');
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd(); // Pre-load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Rewarded ad failed to show - $error');
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('AdService: User earned reward - ${reward.amount} ${reward.type}');
          rewardEarned = true;
          onUserEarnedReward();
        },
      );
      _rewardedAd = null;
      return rewardEarned;
    } catch (e) {
      debugPrint('AdService: Failed to show rewarded ad - $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
