import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  AdsManager._privateConstructor();
  static final AdsManager instance = AdsManager._privateConstructor();

  // Test Ad Unit IDs provided by Google AdMob
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // Production Ad Unit IDs (Placeholders that can be replaced before release)
  static const String _prodBannerAdUnitId =
      'ca-app-pub-7040159214988736/4500115843';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-7040159214988736/9516638806';

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // UX Rate-Limiting & Frequency Settings
  DateTime? _lastInterstitialShownTime;
  static const Duration _interstitialCooldown = Duration(seconds: 45);

  /// Get the correct Banner Ad Unit ID based on environment
  String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }
    return _prodBannerAdUnitId;
  }

  /// Get the correct Interstitial Ad Unit ID based on environment
  String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
    return _prodInterstitialAdUnitId;
  }

  /// Initializes the Mobile Ads SDK and preloads an Interstitial ad
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdsManager: SDK successfully initialized.');
      // Preload the first interstitial ad in advance
      preloadInterstitial();
    } catch (e) {
      debugPrint('AdsManager: Failed to initialize SDK: $e');
    }
  }

  /// Preloads an Interstitial ad so it is ready when needed
  void preloadInterstitial() {
    if (!_isInitialized || _isInterstitialLoading || _interstitialAd != null)
      return;

    _isInterstitialLoading = true;
    debugPrint('AdsManager: Preloading Interstitial ad...');

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('AdsManager: Interstitial ad loaded successfully.');

          // Set up lifecycle callbacks for the loaded ad
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdsManager: Interstitial ad dismissed.');
              ad.dispose();
              _interstitialAd = null;
              // Preload the next one
              preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdsManager: Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              // Preload the next one
              preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          debugPrint(
              'AdsManager: Failed to load interstitial ad: ${error.message}');
        },
      ),
    );
  }

  /// Shows the Interstitial ad with frequency control / cooldown restrictions
  /// If the ad is not ready, or cooldown has not passed, it cleanly triggers [onAdClosed]
  /// so the user experience is not disrupted.
  void showInterstitial(
      {required VoidCallback onAdClosed, bool ignoreCooldown = false}) {
    // 1. Check if SDK is initialized
    if (!_isInitialized) {
      debugPrint('AdsManager: Ads not initialized yet. Skipping.');
      onAdClosed();
      return;
    }

    // 2. Enforce frequency/cooldown strategy
    if (!ignoreCooldown) {
      final now = DateTime.now();
      if (_lastInterstitialShownTime != null) {
        final elapsed = now.difference(_lastInterstitialShownTime!);
        if (elapsed < _interstitialCooldown) {
          debugPrint(
              'AdsManager: Cooldown active (${_interstitialCooldown.inSeconds - elapsed.inSeconds}s remaining). Skipping ad presentation.');
          onAdClosed();
          return;
        }
      }
    }

    // 3. Verify if ad is preloaded and ready
    if (_interstitialAd == null) {
      debugPrint(
          'AdsManager: Interstitial ad not preloaded or not ready. Preloading and skipping.');
      preloadInterstitial();
      onAdClosed();
      return;
    }

    // 4. Set custom callback to trigger the custom close sequence
    final currentAd = _interstitialAd!;
    currentAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdsManager: Interstitial ad dismissed by user.');
        ad.dispose();
        _interstitialAd = null;
        _lastInterstitialShownTime = DateTime.now();
        onAdClosed();
        // Load the next ad
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdsManager: Interstitial ad failed to show: $error.');
        ad.dispose();
        _interstitialAd = null;
        onAdClosed();
        // Attempt to reload
        preloadInterstitial();
      },
    );

    // 5. Show the ad
    debugPrint('AdsManager: Showing Interstitial ad.');
    currentAd.show();
  }
}
