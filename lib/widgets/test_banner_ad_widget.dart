import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' show Platform;
import '../app_theme.dart';

class TestBannerAdWidget extends StatefulWidget {
  final int index;
  
  const TestBannerAdWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<TestBannerAdWidget> createState() => _TestBannerAdWidgetState();
}

class _TestBannerAdWidgetState extends State<TestBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasFailedToLoad = false;

  // 테스트 배너 광고 ID
  String get _adUnitId {
    if (kIsWeb) {
      return '';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android 배너 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS 배너 테스트 ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
            print('🎯 Banner ad loaded for position ${widget.index}');
          }
        },
        onAdFailedToLoad: (ad, err) {
          print('❌ Failed to load banner ad for position ${widget.index}: ${err.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _hasFailedToLoad = true;
            });
          }
        },
        onAdClicked: (ad) {
          print('👆 Banner ad clicked at position ${widget.index}');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _hasFailedToLoad) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      return Container(
        height: 60.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue.withOpacity(0.5),
            ),
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context) 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: _bannerAd!.size.height.toDouble().h,
              width: _bannerAd!.size.width.toDouble().w,
              color: AppTheme.isDark(context) ? Colors.grey[850] : Colors.white,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
          // 광고 라벨
          Positioned(
            top: 4.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: Text(
                'AD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}