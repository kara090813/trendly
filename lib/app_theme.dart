import 'package:flutter/material.dart';

class AppTheme {
  /// 기본 색상 설정
  static const String fontFamily = 'asgm';

  /// 공통 텍스트 스타일
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: fontFamily),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, fontFamily: fontFamily),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: fontFamily),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: fontFamily),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    bodyLarge: TextStyle(fontSize: 16, fontFamily: fontFamily),
    bodyMedium: TextStyle(fontSize: 14, fontFamily: fontFamily),
    bodySmall: TextStyle(fontSize: 12, fontFamily: fontFamily),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: fontFamily),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: fontFamily),
  );

  /// 공통 버튼 스타일
  static ButtonStyle getButtonStyle(Color color) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.white),
      backgroundColor: MaterialStateProperty.all(color),
      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 16, fontFamily: fontFamily)),
    );
  }

  /// 공통 테마 생성 함수
  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: getButtonStyle(colorScheme.primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          textStyle: const TextStyle(fontSize: 16, fontFamily: fontFamily),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontSize: 16, fontFamily: fontFamily),
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: Colors.grey, fontFamily: fontFamily),
        hintStyle: TextStyle(color: Colors.grey, fontFamily: fontFamily),
      ),
    );
  }

  /// 라이트 테마
  static ThemeData get lightTheme {
    return _baseTheme(
      const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        background: Colors.white,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      ),
    );
  }

  /// 다크 테마
  static ThemeData get darkTheme {
    return _baseTheme(
      ColorScheme.dark(
        primary: Colors.blueGrey,
        secondary: Colors.cyan,
        background: Colors.black,
        surface: Colors.grey[900]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
    );
  }
}
