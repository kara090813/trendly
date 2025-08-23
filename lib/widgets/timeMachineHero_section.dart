import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';

class TimeMachineHeroSection extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDateTap;
  final Map<String, dynamic> summaryData;

  const TimeMachineHeroSection({
    Key? key,
    required this.selectedDate,
    required this.onDateTap,
    required this.summaryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 구조화된 타이틀
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "실검 타임머신",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "과거의 실시간 검색어를 조회해보세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 32.h),
          
          // 날짜 선택 카드
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                      : [Colors.white, Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
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
                              _formatDate(selectedDate),
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getTextColor(context),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getRelativeDateText(selectedDate),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF3B82F6),
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
              .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 800.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}년 ${date.month}월 ${date.day}일";
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