import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../services/ad_service.dart';
import '../app_theme.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize; // 광고 크기
  
  const BannerAdWidget({
    Key? key,
    this.adSize = AdSize.banner, // 기본값: 320x50
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasFailedToLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && AdService.isAdEnabled) {
      // 🚀 성능 최적화: 조건부 지연 로딩
      if (AdService.enableScrollOptimization) {
        // 스크롤 최적화 모드: 더 긴 지연으로 초기 스크롤 성능 우선
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadAd();
          }
        });
      } else {
        // 일반 모드: 빠른 로딩
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _loadAd();
          }
        });
      }
    }
  }

  void _loadAd() {
    print('🚀 [Banner Ad] Starting to load banner ad...');
    
    // 🎯 Android Hybrid Composition 강제 활성화
    final AdRequest request = Platform.isAndroid 
      ? const AdRequest(
          httpTimeoutMillis: 10000, // 타임아웃 설정으로 성능 개선
        )
      : const AdRequest();
    
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: widget.adSize,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
            print('✅ [Banner Ad] Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ [Banner Ad] Failed: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _hasFailedToLoad = true;
            });
          }
        },
        onAdClicked: (ad) => print('👆 [Banner Ad] Clicked'),
      ),
    );
    
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (kIsWeb || !AdService.isAdEnabled) {
      return const SizedBox.shrink();
    }

    // 광고 로드 실패 시에도 레이아웃 안정성을 위해 동일한 높이 유지
    if (_hasFailedToLoad) {
      return SizedBox(
        width: double.infinity,
        height: 66.h, // 광고와 동일한 높이 유지
        child: Container(), // 투명한 빈 컨테이너
      );
    }

    // 🎯 최대 성능 최적화: 최소한의 래핑과 고정 구조
    return RepaintBoundary( // 🚀 최외곽에서 렌더링 완전 격리
      child: Container(
        width: double.infinity,
        height: 66.h, // 🎯 광고 표준 높이로 고정 (50 + 16 padding)
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(6.r), // 라운드 감소
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.1), // 투명도 증가
            width: 0.5,
          ),
        ),
        child: _isAdLoaded 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: AdWidget(ad: _bannerAd!), // 불필요한 래핑 제거
            )
          : Center(
              child: SizedBox(
                width: 12.w, // 크기 감소
                height: 12.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                  strokeWidth: 1.0, // 두께 감소
                ),
              ),
            ),
      ),
    );
  }
}