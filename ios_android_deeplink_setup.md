# iOS & Android 딥링크 설정 완료 가이드

## 🚀 구현 완료 사항

### 1. iOS 딥링크 설정 ✅

#### Info.plist 설정 완료
- **경로**: `ios/Runner/Info.plist`
- **추가된 설정**:
  ```xml
  <!-- URL Schemes for Deep Linking -->
  <key>CFBundleURLTypes</key>
  <array>
      <dict>
          <key>CFBundleURLName</key>
          <string>com.trendly.deeplink</string>
          <key>CFBundleURLSchemes</key>
          <array>
              <string>trendly</string>
          </array>
      </dict>
  </array>
  ```

#### AppDelegate.swift 업데이트 완료
- **경로**: `ios/Runner/AppDelegate.swift`
- **추가된 기능**:
  - iOS 알림 카테고리 등록 (`KEYWORD_NOTIFICATION`)
  - UNUserNotificationCenter delegate 설정
  
### 2. Android 딥링크 설정 ✅

#### AndroidManifest.xml 업데이트 완료
- **경로**: `android/app/src/main/AndroidManifest.xml`
- **수정된 설정**:
  - 기본 런처에 `android:autoVerify="true"` 추가
  - FCM 푸시 딥링크 intent-filter 정리

### 3. FCM 서비스 업데이트 ✅

#### 새로운 푸시 메시지 구조 지원
- **Action 기반 처리**: `data.action = "open_keyword_detail"`
- **기존 구조 호환성 유지**: 기존 `keyword_id` 직접 접근 방식도 계속 지원
- **추가 데이터 로깅**: category, rank, screen 정보 로깅

#### 업데이트된 메시지 처리 로직
```dart
// 새로운 구조
if (data.containsKey('action') && data['action'] == 'open_keyword_detail') {
  if (data.containsKey('keyword_id')) {
    final keywordId = data['keyword_id'];
    // category, rank 정보도 함께 로깅
    _navigateToKeywordDetail(keywordId);
  }
}
```

## 📋 백엔드 푸시 메시지 구조 (지원됨)

```json
{
  "notification": {
    "title": "'키워드명' 키워드가 X위에 랭크되었습니다",
    "body": "트렌들리에서 실검 등재 이유를 확인해보세요!"
  },
  "data": {
    "keyword_id": "12345",
    "action": "open_keyword_detail",
    "screen": "keyword_detail",
    "category": "스포츠",
    "rank": "3"
  },
  "android": {
    "priority": "high",
    "notification": {
      "click_action": "OPEN_KEYWORD_DETAIL",
      "sound": "default"
    }
  },
  "apns": {
    "aps": {
      "sound": "default",
      "badge": 1,
      "category": "KEYWORD_NOTIFICATION"
    }
  }
}
```

## 🧪 테스트 방법

### A. iOS 실기기에서 테스트
1. iOS 실기기에서 앱 빌드 및 실행
2. 백엔드에서 위의 푸시 메시지 구조로 발송
3. 알림 탭 → 앱 실행/포그라운드 → 키워드 상세 페이지로 자동 이동

### B. Android 실기기에서 테스트  
1. Android 실기기에서 앱 빌드 및 실행
2. 백엔드에서 동일한 푸시 메시지 발송
3. 알림 탭 → 앱 실행/포그라운드 → 키워드 상세 페이지로 자동 이동

### C. 시뮬레이터에서 테스트 (개발용)
```dart
// Flutter Inspector 또는 디버그 콘솔에서 실행
FirebaseMessagingService().simulateNotificationTap("12345");
```

## 📱 지원되는 딥링크 시나리오

### 1. 앱 완전 종료 상태
- 푸시 알림 탭 → 앱 시작 → 키워드 상세 페이지로 이동
- 뒤로가기 버튼으로 메인 페이지로 이동 가능

### 2. 앱 백그라운드 상태
- 푸시 알림 탭 → 앱 포그라운드 → 키워드 상세 페이지로 이동

### 3. 앱 포그라운드 상태
- 푸시 알림 수신 → 다이얼로그 표시 → "지금 보기" 버튼으로 이동

## 🔍 디버깅 로그 확인

성공적인 딥링크 실행 시 다음 로그들이 출력됩니다:

```
🔥 [FCM] Notification tapped:
  - Title: 'BTS' 키워드가 3위에 랭크되었습니다
  - Body: 트렌들리에서 실검 등재 이유를 확인해보세요!
  - Data: {keyword_id: 12345, action: open_keyword_detail, category: 스포츠, rank: 3}
🔥 [FCM] Action: open_keyword_detail
🔥 [FCM] Navigate to keyword: 12345 (category: 스포츠, rank: 3)
✅ [FCM] Navigation to keyword detail successful: 12345
```

## ⚠️ 주의사항

1. **실기기 필요**: FCM은 iOS/Android 시뮬레이터에서 제한적으로만 작동
2. **인증서 설정**: iOS의 경우 올바른 Push Notification 인증서 필요
3. **권한 허용**: 각 플랫폼에서 알림 권한이 허용되어야 함
4. **백엔드 연동**: 올바른 FCM 서버 키와 프로젝트 설정 필요

## ✅ 구현 상태

- [x] iOS Info.plist URL Schemes 설정
- [x] iOS AppDelegate 알림 카테고리 설정
- [x] Android AndroidManifest.xml intent-filter 설정
- [x] FCM 서비스 새로운 메시지 구조 지원
- [x] 기존 구조와의 호환성 유지
- [ ] 실기기 테스트 (사용자가 직접 수행 필요)

## 🚀 다음 단계

1. iOS/Android 실기기에서 푸시 알림 딥링크 테스트
2. 백엔드팀과 함께 푸시 메시지 발송 테스트
3. 프로덕션 환경에서 최종 검증
4. 사용자 플로우 및 UX 검증