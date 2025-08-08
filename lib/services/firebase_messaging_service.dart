import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'api_service.dart';
import '../router.dart';

/// Firebase Cloud Messaging 서비스
/// FCM 토큰 관리, 푸시 알림 권한 요청, 토큰 등록/업데이트 등을 담당
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  /// 플랫폼 및 환경 확인
  bool _isSimulator() {
    if (kIsWeb) return false;
    
    // iOS 시뮬레이터 확인 (여러 방법)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS 시뮬레이터는 여러 환경변수로 확인 가능
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
             Platform.environment.containsKey('SIMULATOR_ROOT') ||
             Platform.environment['FLUTTER_TEST'] == 'true';
    }
    
    // Android 에뮬레이터 확인
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Platform.environment.containsKey('ANDROID_EMULATOR') || 
             Platform.environment['FLUTTER_TEST'] == 'true';
    }
    
    // 기본적으로 DEBUG 모드에서는 시뮬레이터로 간주 (안전한 방법)
    return kDebugMode;
  }

  /// 앱 초기화 시 FCM 설정 및 토큰 등록
  Future<void> initializeFirebaseMessaging() async {
    try {
      print('🔥 [FCM] Initializing Firebase Messaging...');
      
      // 시뮬레이터/에뮬레이터 확인
      final isSimulator = _isSimulator();
      print('🔥 [FCM] Running on simulator/emulator: $isSimulator');
      print('🔥 [FCM] Platform: ${defaultTargetPlatform.toString()}');
      
      if (isSimulator) {
        print('⚠️ [FCM] Simulator detected - FCM tokens may not work properly');
        print('⚠️ [FCM] For testing FCM, please use a real device');
        
        // 시뮬레이터에서는 가짜 토큰으로 테스트
        await _handleSimulatorMode();
        return;
      }
      
      // Firebase Core가 완전히 초기화되었는지 확인
      print('🔥 [FCM] Checking Firebase Core initialization...');
      if (Firebase.apps.isEmpty) {
        print('❌ [FCM] Firebase Core not initialized!');
        return;
      }
      
      final app = Firebase.app();
      print('🔥 [FCM] Firebase app: ${app.name}, options: ${app.options.projectId}');
      
      // FCM 인스턴스 상태 확인
      print('🔥 [FCM] Checking FCM instance...');
      print('🔥 [FCM] FCM instance: ${_firebaseMessaging.toString()}');

      // 1. 푸시 알림 권한 요청
      final NotificationSettings settings = await _requestPermissions();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('🔥 [FCM] Push notification permission granted');
        
        // 2. FCM 토큰 가져오기
        final String? token = await _getToken();
        
        if (token != null) {
          print('🔥 [FCM] Token retrieved: ${token.substring(0, 20)}...');
          
          // 3. 토큰을 서버에 등록
          await _registerTokenToServer(token, true);
          
          // 4. 로컬에 토큰과 권한 상태 저장
          await _saveTokenLocally(token, true);
        } else {
          print('❌ [FCM] Failed to get FCM token, will retry later');
          // 토큰 가져오기 실패시 나중에 재시도할 수 있도록 백그라운드에서 시도
          _retryTokenInitialization(true);
        }
      } else {
        print('⚠️ [FCM] Push notification permission denied');
        // 권한이 거부되어도 토큰은 가져올 수 있으므로 서버에 등록 (푸시 비허용 상태로)
        final String? token = await _getToken();
        if (token != null) {
          await _registerTokenToServer(token, false);
          await _saveTokenLocally(token, false);
        } else {
          _retryTokenInitialization(false);
        }
      }

      // 5. 토큰 갱신 리스너 설정
      _setupTokenRefreshListener();

      // 6. 메시지 리스너 설정
      _setupMessageHandlers();
      
      // 7. 앱 시작 시 초기 메시지 확인
      _checkInitialMessage();

      print('🔥 [FCM] Firebase Messaging initialization completed');
    } catch (e) {
      print('❌ [FCM] Error initializing Firebase Messaging: $e');
    }
  }

  /// 토큰 초기화 재시도 (백그라운드에서)
  void _retryTokenInitialization(bool isPushAllowed) {
    Future.delayed(Duration(seconds: 10), () async {
      try {
        print('🔄 [FCM] Retrying token initialization...');
        final String? token = await _getToken(maxRetries: 2);
        
        if (token != null) {
          await _registerTokenToServer(token, isPushAllowed);
          await _saveTokenLocally(token, isPushAllowed);
          print('✅ [FCM] Token initialization retry successful');
        } else {
          print('❌ [FCM] Token initialization retry failed');
          // 15분 후 다시 시도
          Future.delayed(Duration(minutes: 15), () {
            _retryTokenInitialization(isPushAllowed);
          });
        }
      } catch (e) {
        print('❌ [FCM] Error during token initialization retry: $e');
      }
    });
  }

  /// 푸시 알림 권한 요청
  Future<NotificationSettings> _requestPermissions() async {
    try {
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔥 [FCM] Permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      print('❌ [FCM] Error requesting permissions: $e');
      // 에러 발생 시 기본 설정 반환
      return NotificationSettings(
        authorizationStatus: AuthorizationStatus.denied,
        alert: AppleNotificationSetting.disabled,
        announcement: AppleNotificationSetting.disabled,
        badge: AppleNotificationSetting.disabled,
        carPlay: AppleNotificationSetting.disabled,
        lockScreen: AppleNotificationSetting.disabled,
        notificationCenter: AppleNotificationSetting.disabled,
        showPreviews: AppleShowPreviewSetting.never,
        timeSensitive: AppleNotificationSetting.disabled,
        criticalAlert: AppleNotificationSetting.disabled,
        sound: AppleNotificationSetting.disabled,
      );
    }
  }

  /// 네트워크 연결 상태 확인
  Future<bool> _checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// FCM 토큰 가져오기 (다양한 방법 시도)
  Future<String?> _getToken({int maxRetries = 3}) async {
    print('🔥 [FCM] Starting token retrieval process...');
    
    // 방법 1: 일반적인 토큰 가져오기
    try {
      print('🔥 [FCM] Method 1: Standard token retrieval...');
      final String? token = await _firebaseMessaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        print('🔥 [FCM] Method 1 SUCCESS - Token: ${token.substring(0, 20)}...');
        return token;
      } else {
        print('⚠️ [FCM] Method 1 - Token is null or empty');
      }
    } catch (e) {
      print('❌ [FCM] Method 1 failed: $e');
    }

    // 방법 2: 앱 ID와 함께 토큰 가져오기
    try {
      print('🔥 [FCM] Method 2: Token with app ID...');
      await _firebaseMessaging.deleteToken(); // 기존 토큰 삭제
      await Future.delayed(Duration(seconds: 2)); // 잠시 대기
      
      final String? token = await _firebaseMessaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        print('🔥 [FCM] Method 2 SUCCESS - Token: ${token.substring(0, 20)}...');
        return token;
      } else {
        print('⚠️ [FCM] Method 2 - Token is null or empty');
      }
    } catch (e) {
      print('❌ [FCM] Method 2 failed: $e');
    }

    // 방법 3: APNS 토큰 먼저 가져오기 (iOS용이지만 Android에서도 시도)
    try {
      print('🔥 [FCM] Method 3: APNS token first...');
      final String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print('🔥 [FCM] APNS Token: ${apnsToken ?? 'null'}');
      
      await Future.delayed(Duration(seconds: 1));
      final String? token = await _firebaseMessaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        print('🔥 [FCM] Method 3 SUCCESS - Token: ${token.substring(0, 20)}...');
        return token;
      } else {
        print('⚠️ [FCM] Method 3 - Token is null or empty');
      }
    } catch (e) {
      print('❌ [FCM] Method 3 failed: $e');
    }

    // 방법 4: 재시도 로직
    print('🔥 [FCM] Method 4: Retry with delays...');
    for (int i = 0; i < maxRetries; i++) {
      try {
        print('🔥 [FCM] Retry attempt ${i + 1}/$maxRetries...');
        
        // 더 긴 대기 시간
        if (i > 0) {
          final delay = i * 3; // 3초, 6초, 9초...
          print('🔄 [FCM] Waiting ${delay} seconds before retry...');
          await Future.delayed(Duration(seconds: delay));
        }
        
        final String? token = await _firebaseMessaging.getToken();
        
        if (token != null && token.isNotEmpty) {
          print('🔥 [FCM] Method 4 SUCCESS - Token: ${token.substring(0, 20)}...');
          return token;
        } else {
          print('⚠️ [FCM] Method 4 attempt ${i + 1} - Token is null or empty');
        }
      } catch (e) {
        print('❌ [FCM] Method 4 attempt ${i + 1} failed: $e');
      }
    }
    
    print('❌ [FCM] All methods failed to get token');
    return null;
  }

  /// 서버에 토큰 등록
  Future<void> _registerTokenToServer(String token, bool isPushAllowed) async {
    try {
      print('🔥 [FCM] Registering token to server...');
      
      final result = await _apiService.registerPushToken(
        token: token,
        isPushAllowed: isPushAllowed,
      );
      
      print('🔥 [FCM] Token registered successfully: $result');
    } catch (e) {
      print('❌ [FCM] Failed to register token to server: $e');
      // 서버 등록 실패해도 앱 사용에는 문제없도록 에러를 던지지 않음
    }
  }

  /// 로컬에 토큰과 권한 상태 저장
  Future<void> _saveTokenLocally(String token, bool isPushAllowed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await prefs.setBool('push_notification_allowed', isPushAllowed);
      await prefs.setString('last_token_update', DateTime.now().toIso8601String());
      
      print('🔥 [FCM] Token and permission status saved locally');
    } catch (e) {
      print('❌ [FCM] Error saving token locally: $e');
    }
  }

  /// 토큰 갱신 리스너 설정
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String newToken) async {
      print('🔥 [FCM] Token refreshed: ${newToken.substring(0, 20)}...');
      
      // 새로운 토큰을 서버에 등록
      final prefs = await SharedPreferences.getInstance();
      final bool isPushAllowed = prefs.getBool('push_notification_allowed') ?? false;
      
      await _registerTokenToServer(newToken, isPushAllowed);
      await _saveTokenLocally(newToken, isPushAllowed);
    });
  }

  /// 메시지 핸들러 설정
  void _setupMessageHandlers() {
    // 앱이 포그라운드에 있을 때 메시지 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔥 [FCM] Message received (foreground): ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // 알림을 탭해서 앱을 열었을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔥 [FCM] Message opened app: ${message.notification?.title}');
      _handleMessageOpenedApp(message);
    });
  }
  
  /// 앱 시작 시 초기 메시지 확인
  Future<void> _checkInitialMessage() async {
    try {
      print('🔥 [FCM] Checking for initial message...');
      
      // 시뮬레이터에서는 테스트용 메시지 처리
      if (_isSimulator()) {
        print('🎭 [FCM] Simulator mode - checking for test initial message');
        // 시뮬레이터에서는 SharedPreferences에서 테스트 메시지 확인 가능
        final prefs = await SharedPreferences.getInstance();
        final String? testKeywordId = prefs.getString('test_initial_keyword_id');
        if (testKeywordId != null) {
          print('🎭 [FCM] Found test initial message: keyword_id=$testKeywordId');
          
          // 테스트 데이터 삭제
          await prefs.remove('test_initial_keyword_id');
          
          // 직접 네비게이션 처리 (시뮬레이터용)
          Future.delayed(Duration(milliseconds: 500), () {
            _navigateToKeywordDetail(testKeywordId);
          });
          return;
        }
      }
      
      // 실제 기기에서 FCM 메시지 확인
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      
      if (initialMessage != null) {
        print('🔥 [FCM] App launched from notification: ${initialMessage.notification?.title}');
        print('🔥 [FCM] Initial message data: ${initialMessage.data}');
        
        // 약간의 지연을 추가하여 앱 완전 초기화 후 네비게이션 처리
        Future.delayed(Duration(milliseconds: 500), () {
          _handleMessageOpenedApp(initialMessage);
        });
      } else {
        print('🔥 [FCM] No initial message found');
      }
    } catch (e) {
      print('❌ [FCM] Error checking initial message: $e');
    }
  }
  

  /// 포그라운드에서 메시지 수신 처리
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      // 앱이 활성 상태일 때 받은 푸시 알림 처리
      print('🔥 [FCM] Foreground notification:');
      print('  - Title: ${message.notification?.title}');
      print('  - Body: ${message.notification?.body}');
      print('  - Data: ${message.data}');

      // 포그라운드에서도 사용자가 원한다면 바로 이동할 수 있도록 처리
      // 예: 다이얼로그를 표시하여 "지금 보기" 버튼 제공
      _showForegroundNotificationDialog(message);
    } catch (e) {
      print('❌ [FCM] Error handling foreground message: $e');
    }
  }
  
  /// 포그라운드 알림 다이얼로그 표시 (선택사항)
  void _showForegroundNotificationDialog(RemoteMessage message) {
    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification?.title ?? '알림'),
              content: Text(message.notification?.body ?? ''),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('나중에'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 새로운 푸시 메시지 구조에 따른 처리
                    final data = message.data;
                    
                    if (data.containsKey('action') && data['action'] == 'open_keyword_detail') {
                      if (data.containsKey('keyword_id')) {
                        _navigateToKeywordDetail(data['keyword_id']);
                      }
                    } else {
                      // 기존 구조와의 호환성 유지
                      if (data.containsKey('keyword_id')) {
                        _navigateToKeywordDetail(data['keyword_id']);
                      } else if (data.containsKey('discussion_room_id')) {
                        _navigateToDiscussionRoom(data['discussion_room_id']);
                      }
                    }
                  },
                  child: Text('지금 보기'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('❌ [FCM] Error showing foreground dialog: $e');
    }
  }

  /// 알림을 탭해서 앱을 열었을 때 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      print('🔥 [FCM] Notification tapped:');
      print('  - Title: ${message.notification?.title}');
      print('  - Body: ${message.notification?.body}');
      print('  - Data: ${message.data}');

      // 새로운 푸시 메시지 구조에 따른 처리
      final data = message.data;
      
      // action 기반 처리
      if (data.containsKey('action')) {
        final action = data['action'];
        print('🔥 [FCM] Action: $action');
        
        switch (action) {
          case 'open_keyword_detail':
            if (data.containsKey('keyword_id')) {
              final keywordId = data['keyword_id'];
              print('🔥 [FCM] Navigate to keyword: $keywordId (category: ${data['category']}, rank: ${data['rank']})');
              _navigateToKeywordDetail(keywordId);
            }
            break;
          default:
            print('⚠️ [FCM] Unknown action: $action');
        }
      } else {
        // 기존 구조와의 호환성 유지
        if (data.containsKey('keyword_id')) {
          final keywordId = data['keyword_id'];
          print('🔥 [FCM] Navigate to keyword: $keywordId (legacy format)');
          _navigateToKeywordDetail(keywordId);
        }
        
        if (data.containsKey('discussion_room_id')) {
          final roomId = data['discussion_room_id'];
          print('🔥 [FCM] Navigate to discussion room: $roomId (legacy format)');
          _navigateToDiscussionRoom(roomId);
        }
      }
    } catch (e) {
      print('❌ [FCM] Error handling message opened app: $e');
    }
  }
  
  /// 키워드 상세 페이지로 이동 (메인 페이지를 거쳐서)
  void _navigateToKeywordDetail(String keywordId) {
    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        // 먼저 메인 페이지로 이동하여 라우팅 스택 생성
        context.go('/');
        
        // 짧은 지연 후 키워드 상세 페이지로 push
        Future.delayed(Duration(milliseconds: 200), () {
          if (context.mounted) {
            context.push('/keyword/$keywordId');
            print('✅ [FCM] Navigation to keyword detail successful: $keywordId');
          }
        });
      } else {
        print('⚠️ [FCM] Navigation context not available, storing for later');
        // 컨텍스트가 없을 경우 나중에 처리할 수 있도록 저장
        _storePendingNavigation('keyword', keywordId);
      }
    } catch (e) {
      print('❌ [FCM] Error navigating to keyword detail: $e');
    }
  }
  
  /// 토론방으로 이동 (메인 페이지를 거쳐서)
  void _navigateToDiscussionRoom(String roomId) {
    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        // 먼저 메인 페이지로 이동하여 라우팅 스택 생성
        context.go('/');
        
        // 짧은 지연 후 토론방으로 push
        Future.delayed(Duration(milliseconds: 200), () {
          if (context.mounted) {
            context.push('/discussion/$roomId');
            print('✅ [FCM] Navigation to discussion room successful: $roomId');
          }
        });
      } else {
        print('⚠️ [FCM] Navigation context not available, storing for later');
        _storePendingNavigation('discussion', roomId);
      }
    } catch (e) {
      print('❌ [FCM] Error navigating to discussion room: $e');
    }
  }
  
  /// 보류된 네비게이션 저장 (앱 시작 후 처리하기 위해)
  void _storePendingNavigation(String type, String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_navigation_type', type);
      await prefs.setString('pending_navigation_id', id);
      print('📝 [FCM] Pending navigation stored: $type -> $id');
    } catch (e) {
      print('❌ [FCM] Error storing pending navigation: $e');
    }
  }
  
  /// 보류된 네비게이션 처리 (앱 시작 후 호출)
  Future<void> handlePendingNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? type = prefs.getString('pending_navigation_type');
      final String? id = prefs.getString('pending_navigation_id');
      
      if (type != null && id != null) {
        print('🔄 [FCM] Processing pending navigation: $type -> $id');
        
        // 네비게이션 처리 (메인 페이지를 거쳐서)
        final context = AppRouter.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          // 먼저 메인 페이지로 이동
          context.go('/');
          
          // 짧은 지연 후 목표 페이지로 push
          Future.delayed(Duration(milliseconds: 200), () {
            if (context.mounted) {
              if (type == 'keyword') {
                context.push('/keyword/$id');
              } else if (type == 'discussion') {
                context.push('/discussion/$id');
              }
            }
          });
          
          // 처리 완료 후 저장된 데이터 삭제
          await prefs.remove('pending_navigation_type');
          await prefs.remove('pending_navigation_id');
          print('✅ [FCM] Pending navigation processed and cleared');
        }
      }
    } catch (e) {
      print('❌ [FCM] Error handling pending navigation: $e');
    }
  }

  /// 사용자가 푸시 알림 설정을 변경했을 때 호출
  Future<void> updatePushNotificationPermission(bool isAllowed) async {
    try {
      // 시뮬레이터에서는 처리하지 않음
      if (_isSimulator()) {
        print('🎭 [FCM] Simulator detected - skipping permission update');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final String? currentToken = prefs.getString('fcm_token');
      
      if (currentToken != null) {
        print('🔥 [FCM] Updating push permission: $isAllowed');
        
        // 서버에 업데이트된 권한 상태 전송
        await _registerTokenToServer(currentToken, isAllowed);
        
        // 로컬에 업데이트된 권한 상태 저장
        await prefs.setBool('push_notification_allowed', isAllowed);
        await prefs.setString('last_token_update', DateTime.now().toIso8601String());
        
        print('🔥 [FCM] Push permission updated successfully');
      } else {
        print('⚠️ [FCM] No token found for permission update');
      }
    } catch (e) {
      print('❌ [FCM] Error updating push permission: $e');
    }
  }

  /// 현재 저장된 FCM 토큰 가져오기
  Future<String?> getCurrentToken() async {
    try {
      // 시뮬레이터에서는 null 반환
      if (_isSimulator()) {
        print('🎭 [FCM] Simulator detected - no token available');
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('❌ [FCM] Error getting current token: $e');
      return null;
    }
  }

  /// 현재 푸시 알림 허용 상태 가져오기
  Future<bool> isPushNotificationAllowed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('push_notification_allowed') ?? false;
    } catch (e) {
      print('❌ [FCM] Error getting push permission status: $e');
      return false;
    }
  }
  
  /// 테스트용 푸시 알림 시뮬레이션 (시뮬레이터에서 사용)
  Future<void> simulateNotificationTap(String keywordId) async {
    try {
      print('🧪 [FCM TEST] Simulating notification tap with keyword_id: $keywordId');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test_initial_keyword_id', keywordId);
      
      print('🧪 [FCM TEST] Test data saved. Restart app to simulate notification tap.');
    } catch (e) {
      print('❌ [FCM TEST] Error simulating notification: $e');
    }
  }

  /// FCM 관련 저장된 데이터 초기화 (로그아웃 등에서 사용)
  Future<void> clearFCMData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      await prefs.remove('push_notification_allowed');
      await prefs.remove('last_token_update');
      print('🔥 [FCM] FCM data cleared');
    } catch (e) {
      print('❌ [FCM] Error clearing FCM data: $e');
    }
  }

  /// 시뮬레이터 모드 처리
  Future<void> _handleSimulatorMode() async {
    try {
      print('🎭 [FCM SIMULATOR] Setting up simulator mode...');
      
      // 권한 요청 (시뮬레이터에서도 UI 테스트 가능)
      final NotificationSettings settings = await _requestPermissions();
      print('🎭 [FCM SIMULATOR] Permission status: ${settings.authorizationStatus}');
      
      // 메시지 핸들러는 여전히 설정 (시뮬레이터에서도 테스트 가능)
      _setupMessageHandlers();
      
      print('🎭 [FCM SIMULATOR] Simulator mode setup complete');
      print('📱 [FCM SIMULATOR] No token registration on simulator');
      print('📱 [FCM SIMULATOR] To test real FCM, please use a physical device');
      
    } catch (e) {
      print('❌ [FCM SIMULATOR] Error in simulator mode: $e');
    }
  }

  /// 간단한 FCM 토큰 테스트 (디버깅용)
  Future<void> testTokenRetrieval() async {
    print('🧪 [FCM TEST] Starting simple token test...');
    
    // 시뮬레이터 확인
    if (_isSimulator()) {
      print('🧪 [FCM TEST] Running on simulator - skipping real token test');
      return;
    }
    
    try {
      // Firebase 상태 확인
      print('🧪 [FCM TEST] Firebase apps count: ${Firebase.apps.length}');
      
      // FCM 인스턴스 확인
      final fcm = FirebaseMessaging.instance;
      print('🧪 [FCM TEST] FCM instance created: ${fcm != null}');
      
      // 토큰 가져오기 (타임아웃 설정)
      print('🧪 [FCM TEST] Requesting token with timeout...');
      final String? token = await fcm.getToken().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('🧪 [FCM TEST] Token request timed out');
          return null;
        },
      );
      
      if (token != null) {
        print('🧪 [FCM TEST] ✅ SUCCESS! Token: ${token.substring(0, 30)}...');
        print('🧪 [FCM TEST] Full token length: ${token.length} characters');
      } else {
        print('🧪 [FCM TEST] ❌ Token is null');
      }
      
    } catch (e, stackTrace) {
      print('🧪 [FCM TEST] ❌ Error: $e');
      print('🧪 [FCM TEST] Stack trace: $stackTrace');
    }
  }
}