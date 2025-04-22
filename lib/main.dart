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
            ChangeNotifierProvider(
                create: (context) => UserPreferenceProvider()),
            // ChangeNotifierProvider<FoodStatus>(create: (context) => FoodStatus()),
            // ChangeNotifierProvider(create: (context) => SelectedFoodProvider()),
          ],
          child: Builder(
            builder: (BuildContext context) {
              Future.microtask(() =>
                  Provider.of<UserPreferenceProvider>(context, listen: false)
                      .loadBasicInfo());

              final router =
                  Provider.of<AppRouter>(context, listen: false).router;
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerDelegate: router.routerDelegate,
                routeInformationProvider: router.routeInformationProvider,
                routeInformationParser: router.routeInformationParser,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.light,
              );
            },
          ),
        );
      },
    );
  }
}
