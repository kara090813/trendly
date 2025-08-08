# FCM 푸시 알림 테스트 가이드

## 🔧 구현된 수정사항

### 1. AndroidManifest.xml 수정
- `OPEN_KEYWORD_DETAIL` intent filter 추가
- 푸시 알림 탭 시 앱이 정상 실행되도록 설정

### 2. FCM 메시지 핸들링 개선
- 앱 시작 시 `_checkInitialMessage()` 호출
- 초기 메시지 확인 및 네비게이션 처리
- 시뮬레이터용 테스트 기능 추가

### 3. 앱 초기화 순서 최적화
- FCM 초기화를 앱 시작과 함께 즉시 실행
- 네비게이션 처리를 위한 적절한 지연 시간 설정

## 🧪 테스트 방법

### A. 실제 기기에서 테스트
1. 실제 Android 기기에서 앱 실행
2. 백엔드에서 다음 형태로 푸시 발송:
```json
{
  "notification": {
    "title": "'BTS' 키워드가 3위에 랭크되었습니다",
    "body": "트렌들리에서 실검 등재 이유를 확인해보세요!"
  },
  "data": {
    "keyword_id": "12345"
  },
  "android": {
    "priority": "high",
    "notification": {
      "click_action": "OPEN_KEYWORD_DETAIL",
      "sound": "default"
    }
  }
}
```

### B. 시뮬레이터에서 테스트 (개발용)
앱이 실행된 상태에서 Flutter Inspector 또는 디버그 콘솔에서:
```dart
FirebaseMessagingService().simulateNotificationTap("12345");
```
실행 후 앱을 재시작하면 키워드 상세 페이지로 이동

## 🔍 디버깅 로그 확인사항

앱 시작 시 다음 로그들이 출력되어야 합니다:
```
🔥 [FCM] Checking for initial message...
🔥 [FCM] App launched from notification: [제목]
🔥 [FCM] Initial message data: {keyword_id: 12345}
🔥 [FCM] Navigate to keyword: 12345
✅ [FCM] Navigation to keyword detail successful: 12345
```

## 📱 테스트 시나리오

### 시나리오 1: 앱 완전 종료 상태
1. 앱을 완전히 종료
2. 푸시 알림 발송
3. 알림 탭 → 앱 시작 → 키워드 상세 페이지로 이동

### 시나리오 2: 앱 백그라운드 상태  
1. 앱을 홈 버튼으로 백그라운드로 전환
2. 푸시 알림 발송
3. 알림 탭 → 앱 포그라운드 → 키워드 상세 페이지로 이동

### 시나리오 3: 앱 포그라운드 상태
1. 앱 사용 중
2. 푸시 알림 수신 → 다이얼로그 표시
3. "지금 보기" 버튼 → 키워드 상세 페이지로 이동

## ⚠️ 주의사항

1. **실제 기기 필요**: FCM은 시뮬레이터에서 제한적으로만 작동
2. **네트워크 연결**: 푸시 알림 수신에는 인터넷 연결 필요
3. **앱 권한**: 알림 권한이 허용되어야 함
4. **백엔드 연동**: 올바른 FCM 서버 키와 프로젝트 설정 필요

## 🚀 다음 단계

테스트가 성공적으로 완료되면:
1. 프로덕션 환경에서 최종 테스트
2. 사용자 플로우 검증
3. 성능 모니터링 설정