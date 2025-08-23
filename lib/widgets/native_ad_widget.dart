import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../services/ad_service.dart';
import '../app_theme.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({Key? key}) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> 
    with AutomaticKeepAliveClientMixin {
  
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasFailedToLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Don't load ad here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb && AdService.isAdEnabled && _nativeAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    print('🚀 [Native Ad] Starting to load native ad...');
    
    _nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
            print('✅ [Native Ad] Native ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ [Native Ad] Failed: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _hasFailedToLoad = true;
            });
          }
        },
        onAdClicked: (ad) => print('👆 [Native Ad] Clicked'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppTheme.getCardColor(context),
        cornerRadius: 8.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Color(0xFF19B3F6),
          style: NativeTemplateFontStyle.bold,
          size: 12.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.getTextColor(context),
          style: NativeTemplateFontStyle.bold,
          size: 15.0, // 뉴스 제목과 동일
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.isDark(context) ? Colors.grey[500]! : Colors.grey[600]!,
          style: NativeTemplateFontStyle.normal,
          size: 13.0, // 뉴스 메타데이터와 동일
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.isDark(context) ? Colors.grey[500]! : Colors.grey[500]!,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );
    
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (kIsWeb || !AdService.isAdEnabled) {
      return const SizedBox.shrink();
    }

    // 광고 로드 실패 시
    if (_hasFailedToLoad) {
      return SizedBox(
        height: 80.w, // 뉴스 썸네일과 같은 높이 유지
        child: Container(), // 투명한 빈 컨테이너
      );
    }

    if (_isAdLoaded && _nativeAd != null) {
      return Container(
        height: 100.h, // 뉴스 아이템과 유사한 높이
        margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Stack(
          children: [
            // AdMob 네이티브 광고 (실제 광고 데이터 포함)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: AdWidget(ad: _nativeAd!),
            ),
            // AD 마크 오버레이 (우측 상단)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Color(0xFF19B3F6),
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 로딩 중 플레이스홀더 (뉴스 아이템과 동일한 레이아웃)
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 플레이스홀더
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.isDark(context) ? Color(0xFF333340) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue.withOpacity(0.5),
                    ),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // 텍스트 플레이스홀더
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 30.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF19B3F6).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 40.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF19B3F6).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}