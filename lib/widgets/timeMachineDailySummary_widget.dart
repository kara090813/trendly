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
            lightIconBackground: Color(0xFFFF6B6B),  // 코랄 레드 (강조)
            darkIconBackground: Color(0xFFE74C3C),
          ),

          SizedBox(height: 14.h),

          // 3개 통계를 가로로 배치
          Row(
            children: [
              // 종합 1위
              Expanded(
                child: _buildCompactStatItem(
                  context: context,
                  icon: Icons.emoji_events_rounded,
                  label: "종합 1위",
                  value: summaryData['topKeyword'] ?? "포켓몬 우유",
                  subtitle: summaryData['topKeywordStats'] ?? "15.2만 검색",
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
              ),

              SizedBox(width: 8.w),

              // 최다 카테고리
              Expanded(
                child: _buildCompactStatItem(
                  context: context,
                  icon: Icons.category_rounded,
                  label: "최다 카테고리",
                  value: summaryData['topCategory'] ?? "연예",
                  subtitle: summaryData['topCategoryStats'] ?? "전체 40%",
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                ),
              ),

              SizedBox(width: 8.w),

              // 인기 토론방
              Expanded(
                child: _buildCompactStatItem(
                  context: context,
                  icon: Icons.forum_rounded,
                  label: "인기 토론방",
                  value: summaryData['topDiscussion'] ?? "갤럭시 S25",
                  subtitle: _extractReactionCount(
                      summaryData['topDiscussionStats'] ?? "반응 3,291개"),
                  colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                ),
              ),
            ],
          ),
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
      padding: padding ?? EdgeInsets.all(16.w),
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

  Widget _buildCompactStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required List<Color> colors,
  }) {
    final bool isDark = AppTheme.isDark(context);

    return Container(
      height: 140.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        // 라이트모드에서 더 명확한 배경색 사용
        color: isDark
            ? Color(0xFF2A2A36)
            : Color(0xFFFBFBFB), // 순백색 대신 약간 회색빛 흰색
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          // 라이트모드에서 더 진한 테두리
          color: isDark
              ? colors[0].withOpacity(0.3)
              : colors[0].withOpacity(0.6), // 0.3 -> 0.6으로 증가
          width: 1.2, // 1 -> 1.2로 증가
        ),
        boxShadow: [
          BoxShadow(
            // 라이트모드에서 더 진한 그림자
            color: isDark
                ? colors[0].withOpacity(0.1)
                : colors[0].withOpacity(0.15), // 0.1 -> 0.15로 증가
            blurRadius: isDark ? 4 : 6, // 라이트모드에서 블러 증가
            spreadRadius: 0,
            offset: Offset(0, isDark ? 1 : 2), // 라이트모드에서 오프셋 증가
          ),
          // 라이트모드에서 추가 그림자 효과
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 1),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 상단: 아이콘 + 라벨
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      // 아이콘 컨테이너 그림자도 개선
                      color: colors[0].withOpacity(isDark ? 0.25 : 0.35),
                      blurRadius: isDark ? 3 : 4,
                      spreadRadius: 0,
                      offset: Offset(0, isDark ? 1 : 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),

              SizedBox(height: 6.h),

              // 라벨 - 색상 개선
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark
                      ? Colors.grey[400]
                      : Colors.grey[700], // 600 -> 700으로 더 진하게
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // 중간: 메인 값 (키워드명) - 색상 개선
          Expanded(
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  // 라이트모드에서 더 진한 텍스트
                  color: isDark
                      ? AppTheme.getTextColor(context)
                      : Color(0xFF1A1A1A), // 검은색에 가깝게
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // 하단: 서브 정보 - 색상 개선
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              // 액센트 색상도 라이트모드에서 더 진하게
              color: isDark
                  ? colors[0]
                  : Color.lerp(colors[0], Colors.black, 0.3)!, // 원색에 검은색 30% 혼합
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 토론방 통계에서 반응 개수만 추출하는 함수
  String _extractReactionCount(String stats) {
    // "댓글 1,847개 • 반응 3,291개" 에서 "반응 3,291개"만 추출
    List<String> parts = stats.split(' • ');
    for (String part in parts) {
      if (part.contains('반응')) {
        return part.trim();
      }
    }
    // 반응이 없으면 전체 문자열 반환 (fallback)
    return stats;
  }
}