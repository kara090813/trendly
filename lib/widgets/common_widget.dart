import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_theme.dart';

// 버튼 위젯
Widget buildButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? color,
}) {
  final buttonColor = color ?? Color(0xFF19B3F6);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// 설정 컨테이너 스타일
Widget buildSettingContainer({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
      color: AppTheme.isDark(context)
          ? Color(0xFF252530)
          : Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: Color(0xFF19B3F6).withOpacity(0.15),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.isDark(context)
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.05),
          blurRadius: 6,
          spreadRadius: 0,
          offset: Offset(0, 2),
        ),
      ],
    ),
    padding: padding ?? EdgeInsets.all(16.w),
    child: child,
  );
}