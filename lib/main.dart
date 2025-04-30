import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'router.dart';
import 'providers/_providers.dart';
import 'package:flutter/services.dart';
import 'services/user_preference_service.dart';
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
              Future.microtask(() =>
                  Provider.of<UserPreferenceProvider>(context, listen: false)
                      .loadBasicInfo());

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