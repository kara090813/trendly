import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_theme.dart'; // 다크모드 판단용

enum IconStyle {
  elevated,      // 강한 그림자 효과
  bordered,      // 보더 효과
  gradient,      // 그라데이션 효과
  neumorphic,    // 뉴모피즘 효과
  glowing,       // 글로우 효과
}

class HistoryTitleWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  // 배경색
  final Color? primaryColor;
  final Color? secondaryColor;

  // 다크/라이트 배경용
  final Color? lightPrimaryColor;
  final Color? lightSecondaryColor;
  final Color? darkPrimaryColor;
  final Color? darkSecondaryColor;

  // 텍스트/아이콘 색상 (선택적 커스터마이징 허용)
  final Color? lightTextColor;
  final Color? darkTextColor;
  final Color? lightIconBackground;
  final Color? darkIconBackground;
  final Color? lightIconColor;
  final Color? darkIconColor;

  // 아이콘 스타일 옵션
  final IconStyle iconStyle;

  const HistoryTitleWidget({
    Key? key,
    required this.title,
    required this.icon,
    this.primaryColor,
    this.secondaryColor,
    this.lightPrimaryColor,
    this.lightSecondaryColor,
    this.darkPrimaryColor,
    this.darkSecondaryColor,
    this.lightTextColor,
    this.darkTextColor,
    this.lightIconBackground,
    this.darkIconBackground,
    this.lightIconColor,
    this.darkIconColor,
    this.iconStyle = IconStyle.elevated, // 기본값
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDark(context);

    // 배경 그라데이션 색
    final Color color1 = primaryColor ??
        (isDarkMode ? darkPrimaryColor : lightPrimaryColor) ??
        (isDarkMode ? const Color(0xFF3B4D63) : const Color(0xFF667eea));

    final Color color2 = secondaryColor ??
        (isDarkMode ? darkSecondaryColor : lightSecondaryColor) ??
        (isDarkMode ? const Color(0xFF2E3947) : const Color(0xFF764ba2));

    // 텍스트, 아이콘 색상
    final Color textColor =
    isDarkMode ? (darkTextColor ?? Colors.white) : (lightTextColor ?? Colors.black);

    final Color iconColor = Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconContainer(isDarkMode, iconColor, color1),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textColor.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(bool isDarkMode, Color iconColor, Color primaryColor) {
    switch (iconStyle) {
      case IconStyle.elevated:
        return _buildElevatedIcon(isDarkMode, iconColor, primaryColor);
      case IconStyle.bordered:
        return _buildBorderedIcon(isDarkMode, iconColor, primaryColor);
      case IconStyle.gradient:
        return _buildGradientIcon(isDarkMode, iconColor, primaryColor);
      case IconStyle.neumorphic:
        return _buildNeumorphicIcon(isDarkMode, iconColor, primaryColor);
      case IconStyle.glowing:
        return _buildGlowingIcon(isDarkMode, iconColor, primaryColor);
      default:
        return _buildElevatedIcon(isDarkMode, iconColor, primaryColor);
    }
  }

  // 1. 강한 그림자 효과 (Elevated)
  Widget _buildElevatedIcon(bool isDarkMode, Color iconColor, Color primaryColor) {
    final Color iconBackgroundColor = isDarkMode
        ? (darkIconBackground ?? Colors.white.withOpacity(0.15))
        : (lightIconBackground ?? Colors.white.withOpacity(0.2));

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }

  // 2. 보더 효과 (Bordered)
  Widget _buildBorderedIcon(bool isDarkMode, Color iconColor, Color primaryColor) {
    final Color iconBackgroundColor = isDarkMode
        ? (darkIconBackground ?? Colors.white.withOpacity(0.1))
        : (lightIconBackground ?? Colors.white.withOpacity(0.15));

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }

  // 3. 그라데이션 효과 (Gradient)
  Widget _buildGradientIcon(bool isDarkMode, Color iconColor, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }

  // 4. 뉴모피즘 효과 (Neumorphic)
  Widget _buildNeumorphicIcon(bool isDarkMode, Color iconColor, Color primaryColor) {
    final Color baseColor = isDarkMode
        ? const Color(0xFF2A2A36)
        : Colors.white.withOpacity(0.9);

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          // 어두운 그림자 (오목한 효과)
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.15),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(2, 2),
          ),
          // 밝은 그림자 (볼록한 효과)
          BoxShadow(
            color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.7),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }

  // 5. 글로우 효과 (Glowing)
  Widget _buildGlowingIcon(bool isDarkMode, Color iconColor, Color primaryColor) {
    final Color iconBackgroundColor = isDarkMode
        ? (darkIconBackground ?? Colors.white.withOpacity(0.1))
        : (lightIconBackground ?? Colors.white.withOpacity(0.15));

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }
}