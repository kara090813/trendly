import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_theme.dart';

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
    
    final metrics = [
      {
        'title': '종합 1위 키워드',
        'value': widget.summaryData['topKeyword'] ?? '포켓몬 우유',
        'subtitle': widget.summaryData['topKeywordStats'] ?? '15.2만 검색',
        'icon': Icons.emoji_events_rounded,
        'gradient': [Color(0xFFFFD700), Color(0xFFFFA500)],
        'bgGradient': isDark 
            ? [Color(0xFF1A1625), Color(0xFF2D1B3D)]
            : [Color(0xFFFFF9E6), Color(0xFFFFF3D1)],
        'countValue': 152000,
        'suffix': '검색',
      },
      {
        'title': '최다 카테고리',
        'value': widget.summaryData['topCategory'] ?? '연예',
        'subtitle': widget.summaryData['topCategoryStats'] ?? '전체 40%',
        'icon': Icons.category_rounded,
        'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
        'bgGradient': isDark 
            ? [Color(0xFF0D2818), Color(0xFF1A3D2E)]
            : [Color(0xFFE8FDF2), Color(0xFFE0F7E9)],
        'countValue': 40,
        'suffix': '%',
      },
      {
        'title': '인기 토론방',
        'value': widget.summaryData['topDiscussion'] ?? '갤럭시 S25',
        'subtitle': _extractReactionCount(widget.summaryData['topDiscussionStats'] ?? '반응 3,291개'),
        'icon': Icons.forum_rounded,
        'gradient': [Color(0xFFF093FB), Color(0xFFF5576C)],
        'bgGradient': isDark 
            ? [Color(0xFF2A1B2E), Color(0xFF3D1A28)]
            : [Color(0xFFFDF2F8), Color(0xFFFCE7F3)],
        'countValue': 3291,
        'suffix': '개',
      },
    ];

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
                      "주요 지표",
                      style: TextStyle(
                        fontSize: 28.sp,
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
                    "핵심 데이터 요약",
                    style: TextStyle(
                      fontSize: 15.sp,
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
          
          SizedBox(height: 24.h),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // 첫 번째 행 - 1위 키워드 (전체 너비)
                _buildMetricCard(
                  context: context,
                  metric: metrics[0],
                  index: 0,
                  isDark: isDark,
                  isFullWidth: true,
                ),
                
                SizedBox(height: 12.h),
                
                // 두 번째 행 - 나머지 2개 (50% 너비씩)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        metric: metrics[1],
                        index: 1,
                        isDark: isDark,
                        isFullWidth: false,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        metric: metrics[2],
                        index: 2,
                        isDark: isDark,
                        isFullWidth: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required Map<String, dynamic> metric,
    required int index,
    required bool isDark,
    bool isFullWidth = true,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: () {
        // 탭 시 확대 애니메이션
        HapticFeedback.mediumImpact();
      },
      child: AnimatedBuilder(
        animation: _countAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: List<Color>.from(metric['bgGradient']),
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
                      : (metric['gradient'][0] as Color).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
      child: isFullWidth ? Row(
        children: [
          // 아이콘
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: List<Color>.from(metric['gradient']),
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: (metric['gradient'][0] as Color).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              metric['icon'],
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric['title'] ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: 6.h),
                
                Text(
                  metric['value'] ?? '',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextColor(context),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8.h),
                
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: List<Color>.from(metric['gradient']),
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (metric['countValue'] != null) ...[
                        Text(
                          _formatNumber(
                            (metric['countValue'] * _countAnimation.value).round()
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (metric['suffix'] != null)
                          Text(
                            metric['suffix'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ] else
                        Text(
                          metric['subtitle'] ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ) : Column(
        children: [
          // 아이콘
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: List<Color>.from(metric['gradient']),
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: (metric['gradient'][0] as Color).withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              metric['icon'],
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // 텍스트 정보
          Column(
            children: [
              Text(
                metric['title'] ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 6.h),
              
              Text(
                metric['value'] ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor(context),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8.h),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: List<Color>.from(metric['gradient']),
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (metric['countValue'] != null) ...[
                      Text(
                        _formatNumber(
                          (metric['countValue'] * _countAnimation.value).round()
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (metric['suffix'] != null)
                        Text(
                          metric['suffix'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                    ] else
                      Text(
                        metric['subtitle'] ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
          );
        },
      ),
    ).animate(delay: Duration(milliseconds: 100 * index + 500))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
        .scale(begin: Offset(0.9, 0.9), end: Offset(1, 1), duration: 600.ms)
        .shimmer(duration: 2000.ms, delay: 1200.ms);
  }
  
  String _formatNumber(int number) {
    if (number >= 100000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
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