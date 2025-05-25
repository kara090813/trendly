import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';

class TimeMachineDateSelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDateTap;

  const TimeMachineDateSelectorWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context: context,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF19B3F6).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "키워드 타임머신",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.calendar_today_rounded,
            label: "날짜 변경",
            onTap: onDateTap,
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey[300]!.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionButton({
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
              color: buttonColor.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 2),
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
}