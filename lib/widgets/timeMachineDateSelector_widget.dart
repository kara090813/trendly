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
    final bool isDark = AppTheme.isDark(context);
    
    return GestureDetector(
      onTap: onDateTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.getContainerColor(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.3)
                : Colors.grey[300]!.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Color(0xFF19B3F6),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF19B3F6).withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.white,
                size: 26.sp,
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
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        "키워드 타임머신",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "• ${_getRelativeDateText(selectedDate)}",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Color(0xFF19B3F6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Color(0xFF19B3F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Color(0xFF19B3F6).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.edit_calendar_rounded,
                color: Color(0xFF19B3F6),
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return "오늘";
    } else if (difference == 1) {
      return "어제";
    } else if (difference == 2) {
      return "그제";
    } else if (difference <= 7) {
      return "$difference일 전";
    } else if (difference <= 30) {
      return "${(difference / 7).floor()}주 전";
    } else {
      return "${(difference / 30).floor()}개월 전";
    }
  }
}