import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ========================================
  // 광고 ON/OFF 제어 변수
  // ========================================
  // 🟢 true  = 광고 활성화 (일반 버전)
  // 🔴 false = 광고 비활성화 (광고 제거 버전)
  //
  // 사용 방법:
  // 1. 광고 버전: isAdEnabled = true
  // 2. 광고 제거 버전: isAdEnabled = false
  // ========================================
  static const bool isAdEnabled = true;
  
  // ========================================
  // 성능 최적화 설정
  // ========================================
  // 🎯 애니메이션 성능 제어
  static const bool enableAnimations = true; // false로 설정하면 모든 애니메이션 비활성화
  
  // 🚀 스크롤 성능 최적화
  static const bool enableScrollOptimization = true;

  // 배너 광고 테스트 ID
  static String get bannerAdUnitId {
    if (kIsWeb) {
      return ''; // 웹은 지원하지 않음
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android 배너 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS 배너 테스트 ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // 네이티브 광고 테스트 ID
  static String get nativeAdUnitId {
    if (kIsWeb) {
      return ''; // 웹은 지원하지 않음
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110'; // Android 네이티브 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511'; // iOS 네이티브 테스트 ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }


  // AdMob 초기화
  static Future<void> initialize() async {
    if (kIsWeb) {
      print('❌ AdMob is not supported on Web');
      return;
    }
    
    if (!isAdEnabled) {
      print('📴 AdMob is disabled by configuration');
      return;
    }
    
    try {
      print('🚀 Initializing AdMob...');
      print('🚀 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      print('🚀 Banner Ad Unit ID: ${bannerAdUnitId}');
      
      final InitializationStatus initializationStatus = await MobileAds.instance.initialize();
      
      // 어댑터 상태 확인
      initializationStatus.adapterStatuses.forEach((key, value) {
        print('📱 Adapter status for $key: ${value.description} (State: ${value.state})');
      });
      
      // 초기화 완료 후 테스트 디바이스 설정
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [])
      );
      
      print('✅ AdMob initialized successfully');
      print('✅ Test device configuration updated');
    } catch (e) {
      print('❌ Failed to initialize AdMob: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

}