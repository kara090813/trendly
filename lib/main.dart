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
import 'dart:ui' as ui;
import 'dart:async' show unawaited;
import 'package:flutter_localizations/flutter_localizations.dart';

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
    // Hive 초기화 실패 시 앱 실행 중단
    return;
  }
  
  // FCM Background 메시지 핸들러 설정
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FCM 서비스 초기화를 백그라운드에서 비동기로 실행
  unawaited(
    FirebaseMessagingService().initializeFirebaseMessaging().catchError((e) {
      print('❌ [MAIN] Failed to initialize FCM: $e');
    })
  );

  // MobileAds 초기화를 try-catch로 감싸기
  // try {
  //   await MobileAds.instance.initialize();
  // } catch (e) {
  //   print('Failed to initialize MobileAds: $e');
  // }

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
              Future.microtask(() async {
                // 사용자 기본 정보 로드
                await Provider.of<UserPreferenceProvider>(context, listen: false)
                    .loadBasicInfo();
                
                // 약간의 지연 후 보류된 FCM 네비게이션 처리 (컨텍스트 완전 초기화 대기)
                await Future.delayed(Duration(milliseconds: 1000));
                await FirebaseMessagingService().handlePendingNavigation();
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
  bool? _prevIsDarkMode;

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
        final isDarkMode = preferences.isDarkMode;

        // 테마 모드가 변경되었는지 확인
        if (_prevIsDarkMode != null && _prevIsDarkMode != isDarkMode) {
          // 애니메이션 재설정 및 시작
          _controller.reset();
          _controller.forward();
        }

        // 현재 테마 모드 저장
        _prevIsDarkMode = isDarkMode;

        // 빌더 호출
        return widget.builder(context, _animation);
      },
    );
  }
}