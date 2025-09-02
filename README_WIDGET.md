# Trendly 홈 위젯 구현 가이드

## 🚀 완료된 구현

### ✅ 핵심 기능
- **홈 위젯 서비스**: 1~5위 키워드 데이터 관리 및 위젯 업데이트
- **마이페이지 설정**: 위젯 활성화/비활성화, 업데이트 간격, 키워드 수 설정  
- **Android 위젯**: 네이티브 Kotlin 구현으로 홈스크린에 키워드 표시
- **iOS 위젯**: Swift 구현 (Xcode 설정 필요)
- **위젯 클릭**: 키워드 클릭 시 앱의 해당 페이지로 이동

### ✅ 해결된 문제들
- **workmanager 호환성 이슈**: 복잡한 백그라운드 작업 대신 간단한 수동 새로고침으로 변경
- **iOS 호환성**: MissingPluginException 해결
- **Android 빌드 오류**: 의존성 충돌 해결

## 📱 사용법

### 1. 홈 위젯 활성화
1. Trendly 앱 실행
2. 마이페이지 → 빠른 설정 → "홈 위젯" 토글 ON
3. 설정 조정:
   - 업데이트 간격: 15분, 30분, 60분, 120분 중 선택
   - 키워드 수: 1~5개 중 선택

### 2. 홈 스크린에 위젯 추가
**Android:**
1. 홈 스크린에서 빈 공간 길게 누르기
2. "위젯" 선택
3. "Trendly" 찾아서 선택
4. 원하는 크기로 위젯 배치

**iOS:**
1. 홈 스크린에서 빈 공간 길게 누르기  
2. 좌상단 "+" 버튼 누르기
3. "Trendly Widget" 검색 후 선택
4. 위젯 크기 선택 후 "위젯 추가"

### 3. 위젯 사용하기
- **키워드 보기**: 위젯에서 1~5위 실시간 키워드 확인
- **키워드 클릭**: 키워드 터치 시 앱의 해당 키워드 상세 페이지로 이동
- **수동 업데이트**: 앱 내 "지금 업데이트" 버튼으로 즉시 새로고침

## 🛠 기술적 구현

### 패키지
```yaml
dependencies:
  home_widget: ^0.6.0  # 홈 위젯 구현
```

### 주요 파일들
```
lib/
├── services/
│   └── home_widget_service.dart         # 위젯 데이터 관리
├── components/
│   └── mypageHome_component.dart        # 위젯 설정 UI
├── models/hive/
│   └── user_preferences.dart            # 위젯 설정 저장
└── providers/
    └── user_preference_provider.dart    # 위젯 설정 상태 관리

android/app/src/main/
├── kotlin/net/lamoss/trendly/
│   └── TrendlyWidgetProvider.kt         # Android 위젯
└── res/
    ├── layout/widget_trendly.xml        # 위젯 레이아웃
    ├── drawable/                        # 위젯 리소스
    └── xml/trendly_widget_info.xml      # 위젯 메타데이터

ios/
└── TrendlyWidget.swift                  # iOS 위젯 (수동 설정 필요)
```

### API 연동
- `ApiService.getCurrentKeywords()` 호출
- 상위 5개 키워드 추출
- JSON 형태로 위젯에 데이터 전달

## 🔄 데이터 흐름

1. **앱에서 위젯 활성화**
   - 사용자가 마이페이지에서 홈 위젯 토글
   - `HomeWidgetService.enableAutoRefresh(true)` 호출
   - 즉시 데이터 업데이트 실행

2. **위젯 데이터 업데이트**
   - `HomeWidgetService.refreshWidgetData()` 호출
   - API에서 최신 키워드 가져오기
   - `HomeWidget.saveWidgetData()` 로 데이터 저장
   - `HomeWidget.updateWidget()` 로 위젯 새로고침

3. **위젯에서 앱으로 이동**
   - 사용자가 위젯의 키워드 클릭
   - `HomeWidget.widgetClicked` 스트림 수신
   - 키워드 ID 추출 후 해당 페이지로 라우팅

## ⚠️ 알려진 제한사항

### 자동 업데이트
- iOS/Android의 시스템 제약으로 인해 완전한 자동 업데이트 불가
- 사용자가 앱을 주기적으로 열어야 위젯 데이터 갱신됨
- 위젯 자체에서 30분마다 시스템 업데이트 요청 (제한적)

### iOS 설정
- Xcode에서 Widget Extension 수동 추가 필요
- App Group 설정으로 데이터 공유 활성화 필요
- `group.com.trendly.widget` ID 사용

### 네트워크 의존성
- 위젯 업데이트 시 네트워크 연결 필요
- 오프라인 상태에서는 이전 데이터 표시

## 🐛 문제 해결

### 위젯이 표시되지 않을 때
1. 앱에서 홈 위젯이 활성화되어 있는지 확인
2. 홈 스크린에서 위젯 재추가
3. "지금 업데이트" 버튼으로 수동 새로고침

### 데이터가 업데이트되지 않을 때
1. 네트워크 연결 확인
2. 앱을 열어서 백그라운드 업데이트 트리거
3. 마이페이지에서 "지금 업데이트" 실행

### 위젯 클릭이 작동하지 않을 때
1. 위젯 재추가
2. 앱 재시작
3. 디바이스 재부팅

## 🔮 향후 개선 사항

1. **Native Background Updates**: Android의 AlarmManager, iOS의 Background App Refresh 활용
2. **더 나은 오프라인 지원**: 로컬 캐시 개선
3. **위젯 크기 옵션**: 소형/중형/대형 위젯 지원
4. **테마 지원**: 라이트/다크 모드 대응
5. **설정 고도화**: 업데이트 시간대, 키워드 카테고리 필터링

## 💡 개발 팁

- 위젯 테스트 시 실제 기기 사용 권장 (시뮬레이터 제약)
- 위젯 디버깅은 Android Studio의 Logcat 활용
- iOS 위젯은 Xcode의 Widget Extension 디버깅 모드 사용
- 위젯 데이터는 SharedPreferences/UserDefaults 기반으로 저장됨