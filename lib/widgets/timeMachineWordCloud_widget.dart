import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '_widgets.dart';

class TimeMachineWordCloudWidget extends StatelessWidget {
  final Map<String, Color> categoryColors;
  final String? wordCloudImagePath;

  const TimeMachineWordCloudWidget({
    Key? key,
    required this.categoryColors,
    this.wordCloudImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryTitleWidget(
            title: "키워드 클라우드",
            icon: Icons.cloud_rounded,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFFB39DDB),
            darkIconBackground: Color(0xFF9C27B0),
          ),

          SizedBox(height: 18.h),

          // 워드클라우드 이미지
          Container(
            width: double.infinity,
            height: 240.h, // 높이 증가
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF21202C)
                  : Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.grey[700]!.withOpacity(0.3)
                    : Colors.grey[300]!.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.isDark(context)
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: wordCloudImagePath != null
                  ? Image.asset(
                      wordCloudImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder(context);
                      },
                    )
                  : _buildPlaceholder(context),
            ),
          ),

          SizedBox(height: 18.h),

          // 카테고리 레전드
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF1E3A8A).withOpacity(0.1)
                  : Color(0xFFE0E7FF).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_rounded,
                      color: Color(0xFF3B82F6),
                      size: 20.sp, // 크기 증가
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "카테고리 색상",
                      style: TextStyle(
                        fontSize: 16.sp, // 폰트 크기 증가
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 14.w, // 간격 증가
                  runSpacing: 10.h,
                  children: categoryColors.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14.w, // 크기 증가
                          height: 14.w,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(4.r),
                            boxShadow: [
                              BoxShadow(
                                color: entry.value.withOpacity(0.3),
                                blurRadius: 2,
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14.sp, // 폰트 크기 증가
                            fontWeight: FontWeight.w500,
                            color: AppTheme.isDark(context) 
                                ? Colors.grey[400] 
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
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
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey[300]!.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w), // 패딩 증가
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.cloud_sync_rounded,
              size: 56.sp, // 크기 증가
              color: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "워드클라우드 생성 중...",
            style: TextStyle(
              fontSize: 18.sp, // 폰트 크기 증가
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "키워드 분석이 완료되면 표시됩니다",
            style: TextStyle(
              fontSize: 14.sp, // 폰트 크기 증가
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Container(
            width: 120.w, // 너비 증가
            height: 4.h, // 높이 증가
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Container(
              width: 40.w,
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms),
        ],
      ),
    );
  }
}