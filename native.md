# Flutter AdMob 네이티브 광고 구현 가이드

## 개요
Flutter 앱에 Google AdMob 네이티브 광고를 구현하는 전체 과정을 정리합니다. 
네이티브 광고는 앱의 UI에 자연스럽게 통합되어 사용자 경험을 해치지 않으면서도 효과적인 광고를 제공합니다.

## 1. 의존성 추가

### pubspec.yaml
```yaml
dependencies:
  google_mobile_ads: ^5.2.0
```

## 2. Flutter 서비스 레이어 구현

### lib/services/ad_service.dart
AdMob 초기화 및 광고 단위 ID 관리를 위한 서비스 클래스입니다.

```dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

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
    
    try {
      print('🚀 Initializing AdMob...');
      print('🚀 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      print('🚀 Native Ad Unit ID: ${nativeAdUnitId}');
      
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
```

### lib/widgets/native_ad_widget.dart
네이티브 광고를 표시하는 Flutter 위젯입니다.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/ad_service.dart';
import '../app_theme.dart';

class NativeAdWidget extends StatefulWidget {
  final double height;
  final int index; // 광고 위치 인덱스
  
  const NativeAdWidget({
    Key? key,
    this.height = 120,
    required this.index,
  }) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasFailedToLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // 약간의 지연 후 광고 로드 (UI 초기화 완료 대기)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _loadAd();
        }
      });
    }
  }

  void _loadAd() {
    print('🚀 [${widget.index}] Starting to load native ad...');
    print('🚀 [${widget.index}] Using ad unit ID: ${AdService.nativeAdUnitId}');
    print('🚀 [${widget.index}] Using factory ID: trendlyNativeAd');
    
    _nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
            print('✅ [${widget.index}] Native ad loaded successfully!');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ [${widget.index}] Failed to load native ad: ${error.message}');
          print('❌ [${widget.index}] Error code: ${error.code}');
          print('❌ [${widget.index}] Error domain: ${error.domain}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _hasFailedToLoad = true;
            });
          }
        },
        onAdClicked: (ad) {
          print('👆 [${widget.index}] Native ad clicked');
        },
      ),
      request: const AdRequest(),
      factoryId: 'trendlyNativeAd', // 네이티브 팩토리 ID 사용
    );
    
    print('🔄 [${widget.index}] Calling load() method...');
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
    
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    // 광고 로드 실패 시 빈 공간 반환
    if (_hasFailedToLoad) {
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded) {
      // 로딩 중 플레이스홀더
      return Container(
        height: widget.height.h,
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
      height: 200.h, // 고정 높이 설정 (XIB 파일의 높이와 일치)
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
```

### main.dart에서 초기화
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AdMob 초기화
  await AdService.initialize();
  
  runApp(MyApp());
}
```

## 3. Android 네이티브 구현

### android/app/build.gradle
CardView 의존성을 추가합니다.
```gradle
dependencies {
    implementation 'androidx.cardview:cardview:1.0.0'
}
```

### android/app/src/main/kotlin/{package}/MainActivity.kt
네이티브 광고 팩토리를 등록합니다.
```kotlin
package net.lamoss.trendly

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "trendlyNativeAd",
            TrendlyNativeAdFactory(context))
    }
    
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine,
            "trendlyNativeAd")
    }
}
```

### android/app/src/main/kotlin/{package}/TrendlyNativeAdFactory.kt
네이티브 광고 팩토리 구현체입니다.
```kotlin
package net.lamoss.trendly

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class TrendlyNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.trendly_native_ad, null) as NativeAdView
            
        with(nativeAdView) {
            val headlineView = findViewById<TextView>(R.id.ad_headline)
            val bodyView = findViewById<TextView>(R.id.ad_body)
            val callToActionView = findViewById<Button>(R.id.ad_call_to_action)
            val iconView = findViewById<ImageView>(R.id.ad_icon)
            val mediaView = findViewById<com.google.android.gms.ads.nativead.MediaView>(R.id.ad_media)

            headlineView.text = nativeAd.headline
            this.headlineView = headlineView

            if (nativeAd.body != null) {
                bodyView.text = nativeAd.body
                bodyView.visibility = View.VISIBLE
            } else {
                bodyView.visibility = View.GONE
            }
            this.bodyView = bodyView

            if (nativeAd.callToAction != null) {
                callToActionView.text = nativeAd.callToAction
                callToActionView.visibility = View.VISIBLE
            } else {
                callToActionView.visibility = View.GONE
            }
            this.callToActionView = callToActionView

            if (nativeAd.icon != null) {
                iconView.setImageDrawable(nativeAd.icon.drawable)
                iconView.visibility = View.VISIBLE
            } else {
                iconView.visibility = View.GONE
            }
            this.iconView = iconView

            this.mediaView = mediaView
            this.setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}
```

### android/app/src/main/res/layout/trendly_native_ad.xml
네이티브 광고의 레이아웃을 정의합니다.
```xml
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.gms.ads.nativead.NativeAdView 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <androidx.cardview.widget.CardView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_margin="12dp"
        app:cardCornerRadius="12dp"
        app:cardElevation="4dp"
        app:cardUseCompatPadding="true">

        <androidx.constraintlayout.widget.ConstraintLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="?android:attr/colorBackground"
            android:padding="8dp">

            <!-- MediaView -->
            <com.google.android.gms.ads.nativead.MediaView
                android:id="@+id/ad_media"
                android:layout_width="0dp"
                android:layout_height="0dp"
                android:background="#F5F5F5"
                android:contentDescription="광고 이미지"
                app:layout_constraintDimensionRatio="H,16:9"
                app:layout_constraintEnd_toEndOf="parent"
                app:layout_constraintStart_toStartOf="parent"
                app:layout_constraintTop_toTopOf="parent" />

            <!-- 광고 배지 -->
            <TextView
                android:id="@+id/tv_ad_badge"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_margin="8dp"
                android:background="#4A90E2"
                android:paddingHorizontal="6dp"
                android:paddingVertical="3dp"
                android:text="광고"
                android:textColor="@android:color/white"
                android:textSize="10sp"
                android:textStyle="bold"
                app:layout_constraintEnd_toEndOf="@+id/ad_media"
                app:layout_constraintTop_toTopOf="@+id/ad_media" />

            <!-- 아이콘 -->
            <ImageView
                android:id="@+id/ad_icon"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:layout_marginTop="8dp"
                android:background="#E6E6E6"
                android:contentDescription="광고 아이콘"
                android:scaleType="centerCrop"
                app:layout_constraintStart_toStartOf="parent"
                app:layout_constraintTop_toBottomOf="@+id/ad_media" />

            <!-- 광고 제목 -->
            <TextView
                android:id="@+id/ad_headline"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="8dp"
                android:layout_marginTop="8dp"
                android:ellipsize="end"
                android:maxLines="2"
                android:textColor="?android:attr/textColorPrimary"
                android:textSize="15sp"
                android:textStyle="bold"
                app:layout_constraintEnd_toEndOf="parent"
                app:layout_constraintStart_toEndOf="@+id/ad_icon"
                app:layout_constraintTop_toBottomOf="@+id/ad_media" />

            <!-- 광고 본문 -->
            <TextView
                android:id="@+id/ad_body"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="8dp"
                android:layout_marginTop="4dp"
                android:ellipsize="end"
                android:maxLines="2"
                android:textColor="?android:attr/textColorSecondary"
                android:textSize="13sp"
                app:layout_constraintEnd_toEndOf="parent"
                app:layout_constraintStart_toEndOf="@+id/ad_icon"
                app:layout_constraintTop_toBottomOf="@+id/ad_headline" />

            <!-- 클릭 유도 문구 -->
            <Button
                android:id="@+id/ad_call_to_action"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:background="@drawable/rounded_button"
                android:paddingHorizontal="16dp"
                android:paddingVertical="6dp"
                android:text="자세히 보기"
                android:textColor="@android:color/white"
                android:textSize="13sp"
                app:layout_constraintEnd_toEndOf="parent"
                app:layout_constraintTop_toBottomOf="@+id/ad_body" />

        </androidx.constraintlayout.widget.ConstraintLayout>
    </androidx.cardview.widget.CardView>
</com.google.android.gms.ads.nativead.NativeAdView>
```

### android/app/src/main/res/drawable/rounded_button.xml
버튼 배경을 위한 drawable 리소스입니다.
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#4A90E2" />
    <corners android:radius="6dp" />
</shape>
```

## 4. iOS 네이티브 구현

### ios/Runner/AppDelegate.swift
네이티브 광고 팩토리를 등록합니다.
```swift
import UIKit
import Flutter
import firebase_core
import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    
    // Native Ad Factory 등록
    let trendlyNativeAdFactory = TrendlyNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self, factoryId: "trendlyNativeAd", nativeAdFactory: trendlyNativeAdFactory)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// 네이티브 광고 팩토리 클래스
class TrendlyNativeAdFactory: FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd,
                       customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("TrendlyNativeAdView", owner: nil, options: nil)?.first
        let nativeAdView = nibView as! GADNativeAdView
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
}
```

### ios/Runner/TrendlyNativeAdView.xib
iOS용 네이티브 광고 UI 레이아웃 파일입니다. Xcode에서 Interface Builder로 생성해야 합니다.

주요 구성 요소:
- **MediaView**: 광고 이미지/비디오
- **Headline Label**: 광고 제목
- **Body Label**: 광고 내용
- **Call to Action Button**: 액션 버튼
- **Icon ImageView**: 앱 아이콘
- **Ad Badge**: "광고" 표시

## 5. Android Manifest 설정

### android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- 인터넷 권한 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application>
        <!-- Google AdMob App ID (테스트용) -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
            
        <!-- AD_SERVICES_CONFIG 충돌 해결 -->
        <property
            android:name="android.adservices.AD_SERVICES_CONFIG"
            android:resource="@xml/gma_ad_services_config"
            tools:replace="android:resource" />
    </application>
</manifest>
```

## 6. 사용 방법

### 위젯에서 네이티브 광고 사용
```dart
class KeywordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: keywords.length + 2, // 광고 2개 추가
      itemBuilder: (context, index) {
        // 3-4위 사이에 첫 번째 광고
        if (index == 3) {
          return NativeAdWidget(index: 1);
        }
        // 7-8위 사이에 두 번째 광고  
        if (index == 7) {
          return NativeAdWidget(index: 2);
        }
        // 일반 키워드 아이템
        return KeywordItem(keyword: keywords[index]);
      },
    );
  }
}
```

## 7. 트러블슈팅

### 일반적인 문제들

1. **MissingPluginException**: 
   - 네이티브 팩토리가 등록되지 않음
   - 해결: MainActivity.kt와 AppDelegate.swift에서 팩토리 등록 확인

2. **광고 로드 실패**:
   - 테스트 광고 ID 확인
   - 네트워크 연결 상태 확인
   - AndroidManifest.xml의 APPLICATION_ID 확인

3. **Android Manifest 충돌**:
   - AD_SERVICES_CONFIG 충돌 시 tools:replace 사용

4. **iOS 빌드 오류**:
   - XIB 파일의 아울렛 연결 확인
   - iOS 버전 호환성 확인

### 디버깅 방법

로그를 통한 디버깅:
```dart
// AdService 초기화 로그
print('🚀 Initializing AdMob...');
print('📱 Adapter status: ${status.description}');

// 네이티브 광고 로드 로그  
print('✅ Native ad loaded successfully!');
print('❌ Failed to load native ad: ${error.message}');
```

## 8. 실제 광고로 전환

테스트가 완료되면 다음 단계로 실제 광고를 적용합니다:

1. **AdMob 콘솔**에서 앱 등록 및 광고 단위 생성
2. **테스트 광고 ID**를 **실제 광고 ID**로 교체
3. **APPLICATION_ID**를 실제 ID로 변경
4. 앱 스토어 배포

## 주의사항

1. **테스트 중에는 반드시 테스트 광고 ID 사용**
2. **실제 광고에서 클릭하지 말 것** (계정 정지 위험)
3. **광고 정책 준수** (콘텐츠 가이드라인)
4. **사용자 경험 고려** (광고 빈도 및 위치)