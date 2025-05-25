import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';

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
          // 헤더
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "일일 트렌드 요약",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // 3분할 통계 카드
          Row(
            children: [
              Expanded(child: _buildSummaryCard(
                context: context,
                icon: Icons.emoji_events_rounded,
                title: "종합 1위",
                value: summaryData['topKeyword'] ?? "포켓몬 우유",
                subtitle: summaryData['topKeywordStats'] ?? "15.2만 검색",
                color: Color(0xFFFFD700),
              )),
              SizedBox(width: 12.w),
              Expanded(child: _buildSummaryCard(
                context: context,
                icon: Icons.category_rounded,
                title: "최다 카테고리",
                value: summaryData['topCategory'] ?? "연예",
                subtitle: summaryData['topCategoryStats'] ?? "전체 40%",
                color: Color(0xFFE74C3C),
              )),
            ],
          ),

          SizedBox(height: 12.h),

          _buildSummaryCard(
            context: context,
            icon: Icons.forum_rounded,
            title: "인기 토론방",
            value: summaryData['topDiscussion'] ?? "갤럭시 S25",
            subtitle: summaryData['topDiscussionStats'] ?? "댓글 1,847개 • 반응 3,291개",
            color: Color(0xFF3498DB),
            isWide: true,
          ),

          SizedBox(height: 20.h),

          // 트렌드 인사이트
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF2A2A36)
                  : Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Color(0xFF19B3F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "트렌드 인사이트",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF19B3F6),
                  ),
                ),
                SizedBox(height: 16.h),
                ...(summaryData['insights'] as List<Map<String, String>>? ?? _getDefaultInsights())
                    .map((insight) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildInsightItem(
                    context: context,
                    icon: insight['icon']!,
                    text: insight['text']!,
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutQuad);
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

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: isWide
          ? Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required BuildContext context,
    required String icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: AppTheme.getTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getDefaultInsights() {
    return [
      {
        'icon': '🚀',
        'text': '연예계 이슈가 급부상하며 포켓몬 관련 밈이 대세로 자리잡았습니다.',
      },
      {
        'icon': '⏰',
        'text': '오후 9시경 검색량이 집중되며 IT 기기 관련 토론이 활발했습니다.',
      },
      {
        'icon': '📈',
        'text': '전체적으로 엔터테인먼트 콘텐츠에 대한 관심도가 크게 증가했습니다.',
      },
    ];
  }
}