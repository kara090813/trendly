import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 테마 색상만 정의하는 간소화된 AppTheme 클래스
class AppTheme {
  // 색상 상수 정의
  // 컨테이너
  static const Color lightContainer = Color(0xFFFFFFFF);
  static const Color darkContainer = Color(0xFF21202C);

  // 배경색
  static const Color lightBackground = Color(0xFFF6F6F6);
  static const Color darkBackground = Color(0xFF18181A);

  // 토글버튼
  static const Color lightToggleButton = Color(0xFFFFFFFF);
  static const Color darkToggleButton = Color(0xFF4F4E5F);

  // 카드
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF2F2E39);

  // 버튼
  static const Color lightButton = Color(0xFFEFEFF1);
  static const Color darkButton = Color(0xFF424242);

  // 하단앱바
  static const Color lightBottomBar = Color(0xFFFFFFFF);
  static const Color darkBottomBar = Color(0xFF19191D);

  // 텍스트
  static const Color lightText = Color(0xFF000000);
  static const Color darkText = Color(0xFFFFFFFF);

  // 앱 주요 색상 (변하지 않는 색상)
  static const Color primaryBlue = Color(0xFF19B3F6);

  // 기본 폰트 설정
  static const String fontFamily = 'asgm';

  /// 간소화된 라이트 테마 - 색상 정의만 포함
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        background: lightBackground,
        surface: lightContainer,
        onBackground: lightText,
        onSurface: lightText,
      ),
    );
  }

  /// 간소화된 다크 테마 - 색상 정의만 포함
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        background: darkBackground,
        surface: darkContainer,
        onBackground: darkText,
        onSurface: darkText,
      ),
    );
  }

  /// 현재 테마가 다크모드인지 확인하는 간편한 메서드
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 현재 테마에 따라 적절한 색상 반환 (위젯 내에서 사용)
  static Color getContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkContainer
        : lightContainer;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color getToggleButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkToggleButton
        : lightToggleButton;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }


  static Color getButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkButton
        : lightButton;
  }

  static Color getBottomBarColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBottomBar
        : lightBottomBar;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkText
        : lightText;
  }
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: getContainerColor(context),
    borderRadius: BorderRadius.circular(15.r),
    boxShadow: isDark(context)
        ? [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 10,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ]
        : [
      BoxShadow(
        color: Colors.black.withOpacity(0.23),
        blurRadius: 10,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration insetDecoration(BuildContext context) => BoxDecoration(
    color: isDark(context) ? Color(0xFF2D2D3A) : Color(0xFFFAFAFA),
    borderRadius: BorderRadius.circular(15.r),
    boxShadow: isDark(context)
        ? [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.05),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(-2, -2),
      ),
    ]
        : [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(-2, -2),
      ),
    ],
  );

  static BoxDecoration commentDecoration(BuildContext context) => BoxDecoration(
    color: isDark(context) ? Color(0xFF2A2A36) : Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(15.r),
    boxShadow: isDark(context)
        ? [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 4,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ]
        : [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        spreadRadius: 0,
        offset: Offset(0, 2),
      ),
    ],
  );
}