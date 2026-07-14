import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ads_manager.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  BannerAd? _nextBannerAd;
  bool _isLoaded = false;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _startReloadTimer();
  }

  void _startReloadTimer() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadAd();
      }
    });
  }

  void _loadAd() {
    final newAd = BannerAd(
      adUnitId: AdsManager.instance.bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              if (ad == _bannerAd) {
                _isLoaded = true;
              } else if (ad == _nextBannerAd) {
                // Seamlessly swap the old ad with the new one to prevent layout flickers
                _bannerAd?.dispose();
                _bannerAd = _nextBannerAd;
                _isLoaded = true;
                _nextBannerAd = null;
              }
            });
            debugPrint('BannerAdWidget: Banner ad loaded successfully.');
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: Banner ad failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              if (ad == _nextBannerAd) {
                _nextBannerAd = null;
              } else if (ad == _bannerAd) {
                _isLoaded = false;
                _bannerAd = null;
              }
            });
          }
        },
      ),
    );

    if (_bannerAd == null) {
      _bannerAd = newAd;
      _bannerAd!.load();
    } else {
      // Load next ad in background to avoid visual flicker/empty spaces
      _nextBannerAd?.dispose();
      _nextBannerAd = newAd;
      _nextBannerAd!.load();
    }
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    _bannerAd?.dispose();
    _nextBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return an empty container when loading or failed, avoiding layout shifts
    return const SizedBox.shrink();
  }
}
