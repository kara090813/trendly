import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '_widgets.dart';

class TimeMachineHourlyTrendsWidget extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final Function(int) getKeywordsForHour;
  final List<DateTime> availableTimes;

  const TimeMachineHourlyTrendsWidget({
    Key? key,
    required this.categoryColors,
    required this.getKeywordsForHour,
    required this.availableTimes,
  }) : super(key: key);

  @override
  State<TimeMachineHourlyTrendsWidget> createState() => _TimeMachineHourlyTrendsWidgetState();
}

class _TimeMachineHourlyTrendsWidgetState extends State<TimeMachineHourlyTrendsWidget>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentTimeIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 시간대별 아이콘과 색상을 반환하는 메서드
  Map<String, dynamic> _getTimeTheme(int hour) {
    if (hour >= 0 && hour < 6) {
      return {
        'icon': Icons.nightlight_round,
        'colors': [Color(0xFF1A237E), Color(0xFF3949AB)],
        'label': '새벽',
        'gradient': [Color(0xFF0F0C29), Color(0xFF24243e)],
      };
    } else if (hour >= 6 && hour < 12) {
      return {
        'icon': Icons.wb_sunny_outlined,
        'colors': [Color(0xFFFF6F00), Color(0xFFFFB74D)],
        'label': '아침',
        'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
      };
    } else if (hour >= 12 && hour < 18) {
      return {
        'icon': Icons.sunny,
        'colors': [Color(0xFF1976D2), Color(0xFF42A5F5)],
        'label': '오후',
        'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      };
    } else {
      return {
        'icon': Icons.nights_stay,
        'colors': [Color(0xFF4A148C), Color(0xFF7B1FA2)],
        'label': '저녁',
        'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableTimes.isEmpty) {
      return Container();
    }

    return _buildContainer(
      context: context,
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          _buildTimeNavigator(),
          SizedBox(height: 16.h),
          _buildKeywordsList(),
          SizedBox(height: 16.h),
          _buildPageIndicator(),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
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

  Widget _buildHeader() {
    return HistoryTitleWidget(
      title: "시간별 실시간 검색어",
      icon: Icons.schedule_rounded,
      lightPrimaryColor: Color(0xFFDCF1FF),
      lightSecondaryColor: Color(0xFFBAE6FD),
      darkPrimaryColor: Color(0xFF334155),
      darkSecondaryColor: Color(0xFF475569),
      lightIconBackground: Color(0xFF81C784),
      darkIconBackground: Color(0xFF4CAF50),
    );
  }

  Widget _buildTimeNavigator() {
    final DateTime currentTime = widget.availableTimes[_currentTimeIndex];
    final Map<String, dynamic> timeTheme = _getTimeTheme(currentTime.hour);
    final String timeString = _formatTime(currentTime);

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: timeTheme['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: (timeTheme['colors'][0] as Color).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 버튼
          _buildNavButton(
            icon: Icons.chevron_left,
            onTap: _currentTimeIndex > 0 ? _goToPreviousTime : null,
            isLeft: true,
          ),

          // 중앙 시간 표시
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      timeTheme['icon'],
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        timeTheme['label'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 다음 버튼
          _buildNavButton(
            icon: Icons.chevron_right,
            onTap: _currentTimeIndex < widget.availableTimes.length - 1
                ? _goToNextTime
                : null,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isLeft,
  }) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 12.r : 0),
            bottomLeft: Radius.circular(isLeft ? 12.r : 0),
            topRight: Radius.circular(isLeft ? 0 : 12.r),
            bottomRight: Radius.circular(isLeft ? 0 : 12.r),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isEnabled
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildKeywordsList() {
    return Container(
      height: 420.h, // 10개 키워드 * 42h = 420h
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          if (mounted && index >= 0 && index < widget.availableTimes.length) {
            setState(() {
              _currentTimeIndex = index;
            });
            _animationController.reset();
            _animationController.forward();
          }
        },
        itemCount: widget.availableTimes.length,
        itemBuilder: (context, index) {
          if (index < 0 || index >= widget.availableTimes.length) {
            return Container();
          }
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _buildKeywordPage(index),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildKeywordPage(int timeIndex) {
    if (timeIndex < 0 || timeIndex >= widget.availableTimes.length) {
      return Container();
    }

    final int hour = widget.availableTimes[timeIndex].hour;
    final dynamic keywordsData = widget.getKeywordsForHour(hour);

    List<Map<String, dynamic>> displayKeywords = [];

    if (keywordsData is List) {
      displayKeywords = keywordsData
          .cast<Map<String, dynamic>>()
          .take(10)
          .toList();
    }

    // 키워드가 10개 미만이면 빈 공간으로 채우기
    while (displayKeywords.length < 10) {
      displayKeywords.add({
        'keyword': '키워드 ${displayKeywords.length + 1}',
        'category': '기타',
        'change': 0,
      });
    }

    return Column(
      children: displayKeywords.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> keyword = entry.value;
        return _buildCompactKeywordItem(keyword, index + 1, index);
      }).toList(),
    );
  }

  Widget _buildCompactKeywordItem(Map<String, dynamic> keyword, int rank, int index) {
    // 안전한 변화 수치 계산
    int change = 0;
    if (keyword.containsKey('change') && keyword['change'] != null) {
      change = keyword['change'] as int? ?? 0;
    } else {
      // 기본 로직
      if (rank % 3 == 0) {
        change = rank % 50;
      } else if (rank % 3 == 1) {
        change = -(rank % 30);
      } else {
        change = rank % 100;
      }
    }

    String changeText = '';
    Color changeColor = Colors.grey;

    if (change > 0) {
      changeText = '+$change';
      changeColor = Colors.red;
    } else if (change < 0) {
      changeText = '$change';
      changeColor = Colors.blue;
    } else {
      changeText = '0';
    }

    final String keywordText = keyword['keyword']?.toString() ?? '키워드 $rank';
    final String categoryText = keyword['category']?.toString() ?? '기타';

    return Container(
      height: 42.h,
      margin: EdgeInsets.only(bottom: rank == 10 ? 0 : 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: rank == 10 ? null : Border(
          bottom: BorderSide(
            color: AppTheme.isDark(context)
                ? Colors.grey.withOpacity(0.1)
                : Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 순위
          Container(
            width: 32.w,
            alignment: Alignment.center,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? Color(0xFF19B3F6)
                    : (AppTheme.isDark(context)
                    ? Colors.grey[700]
                    : Colors.grey[300]),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: rank <= 3
                        ? Colors.white
                        : (AppTheme.isDark(context)
                        ? Colors.grey[300]
                        : Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 키워드
          Expanded(
            child: Text(
              keywordText,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextColor(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 변화 수치 및 카테고리
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 50.w,
                alignment: Alignment.centerRight,
                child: Text(
                  changeText,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                width: 50.w,
                alignment: Alignment.centerRight,
                child: Text(
                  categoryText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.isDark(context)
                        ? Colors.grey[500]
                        : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildPageIndicator() {
    final int totalTimes = widget.availableTimes.length;
    final int maxDots = 7;
    final int dotsToShow = totalTimes < maxDots ? totalTimes : maxDots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 페이지 도트 인디케이터
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            dotsToShow,
                (index) {
              int realIndex;

              if (totalTimes <= maxDots) {
                // 전체 항목이 maxDots 이하면 그대로 표시
                realIndex = index;
              } else {
                // 현재 페이지 근처의 인덱스만 표시
                final int halfDots = maxDots ~/ 2;
                final int startIndex = (_currentTimeIndex - halfDots).clamp(0, totalTimes - maxDots);
                realIndex = startIndex + index;
              }

              final bool isActive = realIndex == _currentTimeIndex;

              return GestureDetector(
                onTap: () => _goToTimeIndex(realIndex),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Color(0xFF19B3F6)
                        : (AppTheme.isDark(context)
                        ? Colors.grey[600]
                        : Colors.grey[400]),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 시간 포맷팅 함수
  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 이전 시간으로 이동
  void _goToPreviousTime() {
    if (_currentTimeIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 다음 시간으로 이동
  void _goToNextTime() {
    if (_currentTimeIndex < widget.availableTimes.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 특정 시간 인덱스로 이동
  void _goToTimeIndex(int index) {
    if (index >= 0 && index < widget.availableTimes.length && mounted) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}