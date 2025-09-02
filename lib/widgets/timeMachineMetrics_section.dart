import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_theme.dart';
import 'package:go_router/go_router.dart';

class TimeMachineMetricsSection extends StatefulWidget {
  final Map<String, dynamic> summaryData;

  const TimeMachineMetricsSection({
    Key? key,
    required this.summaryData,
  }) : super(key: key);

  @override
  State<TimeMachineMetricsSection> createState() => _TimeMachineMetricsSectionState();
}

class _TimeMachineMetricsSectionState extends State<TimeMachineMetricsSection> 
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasAnimated) {
        _countController.forward();
        _hasAnimated = true;
      }
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    final top3Data = widget.summaryData['top3_keywords'] as List<dynamic>? ?? [];
    
    final List<Map<String, dynamic>> keywords = [];
    for (int i = 0; i < 3; i++) {
      final data = i < top3Data.length ? top3Data[i] : null;
      final rank = i + 1;
      
      // 순위별 색상 설정
      List<Color> gradient;
      List<Color> bgGradient;
      Color rankColor;
      Color textColor;
      
      if (rank == 1) {
        gradient = isDark 
            ? [Color(0xFFFFD700), Color(0xFFB8860B)]
            : [Color(0xFFFFD700), Color(0xFFFFA500)];
        bgGradient = isDark 
            ? [Color(0xFF2A2419), Color(0xFF3D3526)]
            : [Color(0xFFFFFDF7), Color(0xFFFFF8E1)];
        rankColor = isDark ? Color(0xFFFFD700) : Color(0xFFB8860B);
        textColor = isDark ? Color(0xFFFFD700) : Color(0xFF8B6914);
      } else if (rank == 2) {
        gradient = isDark 
            ? [Color(0xFFC0C0C0), Color(0xFF8C8C8C)]
            : [Color(0xFFC0C0C0), Color(0xFF9E9E9E)];
        bgGradient = isDark 
            ? [Color(0xFF252525), Color(0xFF383838)]
            : [Color(0xFFFAFAFA), Color(0xFFF0F0F0)];
        rankColor = isDark ? Color(0xFFC0C0C0) : Color(0xFF757575);
        textColor = isDark ? Color(0xFFC0C0C0) : Color(0xFF616161);
      } else {
        gradient = isDark 
            ? [Color(0xFFCD7F32), Color(0xFFA0522D)]
            : [Color(0xFFCD7F32), Color(0xFFB87333)];
        bgGradient = isDark 
            ? [Color(0xFF2A1F18), Color(0xFF3D2E21)]
            : [Color(0xFFFFF9F5), Color(0xFFFFF2E6)];
        rankColor = isDark ? Color(0xFFCD7F32) : Color(0xFF8B4513);
        textColor = isDark ? Color(0xFFCD7F32) : Color(0xFF8B4513);
      }
      
      if (data != null) {
        final appearanceCount = data['appearance_count'] ?? 0;
        final avgRank = data['avg_rank']?.toStringAsFixed(1) ?? '0.0';
        
        keywords.add({
          'rank': rank,
          'keyword': data['keyword'] ?? '키워드 없음',
          'stats': '${appearanceCount}회 등장, 평균 등수 ${avgRank}등',
          'countValue': appearanceCount,
          'category': '트렌드',
          'gradient': gradient,
          'bgGradient': bgGradient,
          'rankColor': rankColor,
          'textColor': textColor,
          'last_keyword_id': data['last_keyword_id'],
        });
      } else {
        keywords.add({
          'rank': rank,
          'keyword': '데이터 없음',
          'stats': '이 날짜에는 데이터가 없습니다',
          'countValue': 0,
          'category': '없음',
          'gradient': gradient,
          'bgGradient': bgGradient,
          'rankColor': rankColor,
          'textColor': textColor,
        });
      }
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "이날의 검색어 Top3",
                      style: TextStyle(
                        fontSize: 29.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "가장 화제가 된 검색어 순위",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 28.h),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: keywords.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> keyword = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < keywords.length - 1 ? 10.h : 0),
                  child: _buildKeywordRankCard(
                    context: context,
                    keyword: keyword,
                    index: index,
                    isDark: isDark,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordRankCard({
    required BuildContext context,
    required Map<String, dynamic> keyword,
    required int index,
    required bool isDark,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: () {
        HapticFeedback.mediumImpact();
        final lastKeywordId = keyword['last_keyword_id'];
        if (lastKeywordId != null) {
          context.push('/keyword/$lastKeywordId');
        }
      },
      child: AnimatedBuilder(
        animation: _countAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: List<Color>.from(keyword['bgGradient']),
              ),
              borderRadius: BorderRadius.circular(20.r),
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
                      : (keyword['gradient'][0] as Color).withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // 순위 배지
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: List<Color>.from(keyword['gradient']),
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: (keyword['gradient'][0] as Color).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${keyword['rank']}',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // 컨텐츠 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 배지
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: (keyword['rankColor'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: (keyword['rankColor'] as Color).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          keyword['category'] ?? '기타',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: keyword['textColor'],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 6.h),
                      
                      // 키워드 제목
                      Text(
                        keyword['keyword'] ?? '',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextColor(context),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 6.h),
                      
                      // 통계 정보
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 13.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              keyword['stats'] ?? '데이터 없음',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 오른쪽 장식 요소
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: (keyword['rankColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 17.sp,
                    color: keyword['textColor'],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate(delay: Duration(milliseconds: 150 * index + 500))
        .fadeIn(duration: 700.ms)
        .slideX(begin: 0.3, end: 0, duration: 700.ms, curve: Curves.easeOutCubic)
        .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 700.ms);
  }

}