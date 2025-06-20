import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '_widgets.dart';

class TimeMachineDailySummaryWidget extends StatelessWidget {
  final Map<String, dynamic> summaryData;

  const TimeMachineDailySummaryWidget({
    Key? key,
    required this.summaryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HistoryTitleWidget(
            title: "요약 리포트",
            icon: Icons.assessment_rounded,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFFFF6B6B),
            darkIconBackground: Color(0xFFE74C3C),
          ),

          SizedBox(height: 18.h),

          // 메인 통계 - 세로로 배치해서 더 큰 폰트 사용
          Column(
            children: [
              _buildMainStatItem(
                context: context,
                icon: Icons.emoji_events_rounded,
                label: "종합 1위",
                value: summaryData['topKeyword'] ?? "포켓몬 우유",
                subtitle: summaryData['topKeywordStats'] ?? "15.2만 검색",
                color: Color(0xFFFFD700),
              ),
              
              SizedBox(height: 14.h),
              
              _buildStatItem(
                context: context,
                icon: Icons.category_rounded,
                label: "최다 카테고리",
                value: summaryData['topCategory'] ?? "연예",
                subtitle: summaryData['topCategoryStats'] ?? "전체 40%",
                color: Color(0xFF11998e),
              ),
              
              SizedBox(height: 14.h),
              
              _buildStatItem(
                context: context,
                icon: Icons.forum_rounded,
                label: "인기 토론방",
                value: summaryData['topDiscussion'] ?? "갤럭시 S25",
                subtitle: _extractReactionCount(
                    summaryData['topDiscussionStats'] ?? "반응 3,291개"),
                color: Color(0xFFf093fb),
              ),
            ],
          ),

          // AI 인사이트가 있으면 표시
          if (summaryData['insights'] != null) ...[
            SizedBox(height: 18.h),
            _buildInsightsSection(context),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
        begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutQuad);
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

  Widget _buildMainStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final bool isDark = AppTheme.isDark(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
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
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final bool isDark = AppTheme.isDark(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark
            ? Color(0xFF2A2A36).withOpacity(0.6)
            : Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    final insights = summaryData['insights'] as List;
    
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark
            ? Color(0xFF1E3A8A).withOpacity(0.1)
            : Color(0xFFE0E7FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(14.r),
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
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF3B82F6),
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                "AI 인사이트",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...insights.map((insight) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['icon'] ?? '💡',
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    insight['text'] ?? '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppTheme.getTextColor(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _extractReactionCount(String stats) {
    List<String> parts = stats.split(' • ');
    for (String part in parts) {
      if (part.contains('반응')) {
        return part.trim();
      }
    }
    return stats;
  }
}