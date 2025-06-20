import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../app_theme.dart';

class TimeMachineTrendsSection extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final Function(int) getKeywordsForHour;
  final List<DateTime> availableTimes;

  const TimeMachineTrendsSection({
    Key? key,
    required this.categoryColors,
    required this.getKeywordsForHour,
    required this.availableTimes,
  }) : super(key: key);

  @override
  State<TimeMachineTrendsSection> createState() => _TimeMachineTrendsSectionState();
}

class _TimeMachineTrendsSectionState extends State<TimeMachineTrendsSection> with TickerProviderStateMixin {
  int _selectedTimeIndex = 0;
  bool _showAll = false;
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipeAnimation;
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _chartAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutQuart,
    );
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    
    if (widget.availableTimes.isEmpty) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
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
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "실시간 트렌드",
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
                    "시간대별 키워드 순위",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 20.h),
          
          // 시간대별 실검 리스트
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildModernTrendsList(isDark),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildCompactNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: enabled 
              ? Color(0xFF3B82F6).withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: enabled 
                ? Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: enabled 
              ? Color(0xFF3B82F6)
              : (isDark ? Colors.grey[600] : Colors.grey[400]),
          size: 18.sp,
        ),
      ),
    );
  }

  void _animateSwipe(double direction, VoidCallback onComplete) {
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(direction, 0),
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _swipeAnimationController.forward().then((_) {
      onComplete();
      _swipeAnimationController.reverse();
    });
  }

  void _navigateTime(int direction) {
    setState(() {
      final newIndex = _selectedTimeIndex + direction;
      if (newIndex >= 0 && newIndex < widget.availableTimes.length) {
        _selectedTimeIndex = newIndex;
        _showAll = false;
      }
    });
  }



  LinearGradient _getRankGradient(int rank) {
    if (rank == 1) {
      return LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]);
    } else if (rank == 2) {
      return LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFF999999)]);
    } else if (rank == 3) {
      return LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFFB8860B)]);
    } else if (rank <= 5) {
      return LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]);
    } else {
      return LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF4B5563)]);
    }
  }

  Widget _buildModernTrendsList(bool isDark) {
    return Column(
      children: [
        // 간단한 시간 네비게이션
        _buildSimpleTimeNavigation(isDark),
        SizedBox(height: 24.h),
        
        // 깔끔한 키워드 리스트
        _buildStreamlinedKeywordList(isDark),
      ],
    );
  }

  Widget _buildSimpleTimeNavigation(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전/다음 버튼
          _buildCompactNavButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => _navigateTime(-1),
            enabled: _selectedTimeIndex > 0,
            isDark: isDark,
          ),
          
          SizedBox(width: 16.w),
          
          // 현재 시간 표시
          Expanded(
            child: Column(
              children: [
                Text(
                  _formatTime(widget.availableTimes[_selectedTimeIndex]),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "${_selectedTimeIndex + 1} / ${widget.availableTimes.length}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16.w),
          
          _buildCompactNavButton(
            icon: Icons.chevron_right_rounded,
            onTap: () => _navigateTime(1),
            enabled: _selectedTimeIndex < widget.availableTimes.length - 1,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStreamlinedKeywordList(bool isDark) {
    final hour = widget.availableTimes[_selectedTimeIndex].hour;
    final keywordsData = widget.getKeywordsForHour(hour);
    
    List<Map<String, dynamic>> displayKeywords = [];
    if (keywordsData is List) {
      displayKeywords = keywordsData.cast<Map<String, dynamic>>().take(10).toList();
    }
    
    while (displayKeywords.length < 10) {
      displayKeywords.add({
        'keyword': '키워드 ${displayKeywords.length + 1}',
        'category': '기타',
        'change': 0,
      });
    }

    final displayCount = _showAll ? displayKeywords.length : 5;
    final keywordsToShow = displayKeywords.take(displayCount).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 키워드 리스트
          ...keywordsToShow.asMap().entries.map((entry) {
            final index = entry.key;
            final keyword = entry.value;
            return _buildCleanKeywordRow(keyword, index + 1, isDark, index == keywordsToShow.length - 1);
          }),
          
          // 더보기 버튼
          if (displayKeywords.length > 5)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAll = !_showAll;
                    });
                  },
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAll ? "접기" : "더 보기 (${displayKeywords.length - 5}개)",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        AnimatedRotation(
                          turns: _showAll ? 0.5 : 0,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF3B82F6),
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCleanKeywordRow(Map<String, dynamic> keyword, int rank, bool isDark, bool isLast) {
    final String keywordText = keyword['keyword']?.toString() ?? '키워드 $rank';
    final String categoryText = keyword['category']?.toString() ?? '기타';
    final categoryColor = widget.categoryColors[categoryText] ?? Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 순위 번호 - 단순화
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: rank <= 3 
                  ? _getRankColor(rank)
                  : (isDark ? Colors.grey[700] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: rank <= 3 ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // 키워드 정보
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    keywordText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                // 카테고리 태그
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    categoryText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700); // 금색
      case 2:
        return Color(0xFFC0C0C0); // 은색
      case 3:
        return Color(0xFFCD7F32); // 동색
      default:
        return Color(0xFF6B7280);
    }
  }


  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}