import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'router.dart';
import 'providers/_providers.dart';
import 'package:flutter/services.dart';
import 'services/user_preference_service.dart';
import 'services/hive_service.dart';
import 'services/firebase_messaging_service.dart';
import 'services/ad_service.dart';
import 'services/home_widget_service.dart';
import 'dart:ui' as ui;
import 'dart:async' show unawaited;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Hive 초기화
  try {
    print('📦 [MAIN] Initializing Hive...');
    await HiveService().initializeHive();
    print('✅ [MAIN] Hive initialized successfully');
  } catch (e) {
    print('❌ [MAIN] Failed to initialize Hive: $e');
    print('⚠️ [MAIN] 앱을 계속 실행하지만 사용자 데이터가 초기화될 수 있습니다.');
    // Hive 초기화 실패해도 앱은 계속 실행 (기본값으로 동작)
  }
  
  // 모바일 플랫폼에서만 실행되는 서비스들
  if (!kIsWeb) {
    // FCM Background 메시지 핸들러 설정
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // FCM 서비스 초기화를 백그라운드에서 비동기로 실행
    unawaited(
      FirebaseMessagingService().initializeFirebaseMessaging().catchError((e) {
        print('❌ [MAIN] Failed to initialize FCM: $e');
      })
    );

    // AdMob 초기화
    await AdService.initialize();

    // 홈 위젯 초기화 (선택적 - 위젯은 독립적으로 동작)
    try {
      await HomeWidgetService.initialize();
      print('✅ [MAIN] Home widget service initialized (optional)');
    } catch (e) {
      print('⚠️ [MAIN] Widget service init skipped: $e');
    }
  } else {
    print('🌐 [MAIN] Running on Web - Mobile-specific services skipped');
  }

  runApp(Trendly());
}

// 앱 루트 위젯에 적용
class Trendly extends StatelessWidget {
  const Trendly({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(430, 932),
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            Provider<AppRouter>(lazy: false, create: (context) => AppRouter()),
            ChangeNotifierProvider(create: (context) => UserPreferenceProvider()),
          ],
          child: Builder(
            builder: (BuildContext context) {
              // 앱 완전 빌드 후 사용자 데이터 로드
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                try {
                  // 사용자 기본 정보 로드 (Hive 이미 초기화됨)
                  await Provider.of<UserPreferenceProvider>(context, listen: false)
                      .loadBasicInfo();
                  
                  // 모바일 플랫폼에서만 실행
                  if (!kIsWeb) {
                    // FCM 네비게이션 처리 (컨텍스트 완전 준비 후)
                    await Future.delayed(Duration(milliseconds: 500));
                    await FirebaseMessagingService().handlePendingNavigation();
                    
                    // 홈 위젯 클릭 리스너 설정
                    HomeWidgetService.setupWidgetClickListener((keywordId) {
                      if (keywordId != null && keywordId.isNotEmpty) {
                        try {
                          final router = Provider.of<AppRouter>(context, listen: false).router;
                          router.go('/keyword/$keywordId');
                        } catch (e) {
                          print('❌ [WIDGET_CLICK] Navigation failed: $e');
                        }
                      }
                    });
                  }
                  
                  // 모바일 플랫폼에서만 위젯 업데이트
                  if (!kIsWeb) {
                    // 앱 시작 시 위젯 선택적 업데이트 (위젯은 독립적으로 동작)
                    Future.delayed(Duration(seconds: 2), () async {
                      try {
                        print('🔄 [MAIN] 선택적 위젯 업데이트 시작');
                        await HomeWidgetService.refreshWidgetData();
                        print('✅ [MAIN] 선택적 위젯 업데이트 완료');
                      } catch (e) {
                        print('⚠️ [MAIN] 선택적 위젯 업데이트 무시: $e');
                      }
                    });
                  }
                } catch (e) {
                  print('❌ [MAIN] Post-frame initialization error: $e');
                }
              });

              final router = Provider.of<AppRouter>(context, listen: false).router;

              return Consumer<UserPreferenceProvider>(
                builder: (context, preferences, _) {
                  // 애니메이션 테마 빌더 적용
                  return AnimatedThemeBuilder(
                    builder: (context, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          return MaterialApp.router(
                            debugShowCheckedModeBanner: false,
                            routerDelegate: router.routerDelegate,
                            routeInformationProvider: router.routeInformationProvider,
                            routeInformationParser: router.routeInformationParser,
                            theme: AppTheme.lightTheme,
                            darkTheme: AppTheme.darkTheme,
                            themeMode: preferences.themeMode,
                            locale: const Locale('ko', 'KR'),
                            localizationsDelegates: const [
                              GlobalMaterialLocalizations.delegate,
                              GlobalWidgetsLocalizations.delegate,
                              GlobalCupertinoLocalizations.delegate,
                            ],
                            supportedLocales: const [
                              Locale('ko', 'KR'),
                              Locale('en', 'US'),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// 테마 전환 시 애니메이션 효과를 제공하는 위젯
class AnimatedThemeBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Animation<double> animation) builder;
  final Duration duration;

  const AnimatedThemeBuilder({
    Key? key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedThemeBuilder> createState() => _AnimatedThemeBuilderState();
}

class _AnimatedThemeBuilderState extends State<AnimatedThemeBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ThemeMode? _prevThemeMode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferenceProvider>(
      builder: (context, preferences, child) {
        final themeMode = preferences.themeMode;

        // 테마 모드가 변경되었는지 확인
        if (_prevThemeMode != null && _prevThemeMode != themeMode) {
          // 애니메이션 재설정 및 시작
          _controller.reset();
          _controller.forward();
        }

        // 현재 테마 모드 저장
        _prevThemeMode = themeMode;

        // 빌더 호출
        return widget.builder(context, _animation);
      },
    );
  }
}