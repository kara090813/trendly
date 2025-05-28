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
          // 헤더
          HistoryTitleWidget(
            title: "키워드 클라우드",
            icon: Icons.assessment_rounded,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFFB39DDB),  // 라벤더 (창의적)
            darkIconBackground: Color(0xFF9C27B0),
          ),

          SizedBox(height: 20.h),

          // 워드클라우드 이미지
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF21202C)
                  : Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
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

          SizedBox(height: 16.h),

          // 카테고리 레전드
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: categoryColors.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }).toList(),
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

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: 48.sp,
            color: AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            "워드클라우드 생성 중...",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}