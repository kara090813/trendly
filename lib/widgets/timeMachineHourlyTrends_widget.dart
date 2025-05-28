import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import 'dart:math' as math;

import '_widgets.dart';

class TimeMachineHourlyTrendsWidget extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final Function(int) getKeywordsForHour;
  final int initialSelectedHour;

  const TimeMachineHourlyTrendsWidget({
    Key? key,
    required this.categoryColors,
    required this.getKeywordsForHour,
    this.initialSelectedHour = 12,
  }) : super(key: key);

  @override
  State<TimeMachineHourlyTrendsWidget> createState() => _TimeMachineHourlyTrendsWidgetState();
}

class _TimeMachineHourlyTrendsWidgetState extends State<TimeMachineHourlyTrendsWidget>
    with TickerProviderStateMixin {
  late int _selectedHour;
  late PageController _pageController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialSelectedHour;
    _pageController = PageController(
      initialPage: _selectedHour,
      viewportFraction: 0.22,
      keepPage: true,
    );

    // 펄스 애니메이션 컨트롤러
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(),

          SizedBox(height: 20.h),

          // 키워드 섹션 (시간 표시 포함)
          _buildKeywordSection(),

          SizedBox(height: 24.h),

          // 컴팩트한 시간 선택 영역
          _buildCompactTimeSelector(),
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
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeader() {
    return HistoryTitleWidget(
      title: "시간별 트렌드",
      icon: Icons.schedule_rounded,
      lightPrimaryColor: Color(0xFFDCF1FF),
      lightSecondaryColor: Color(0xFFBAE6FD),
      darkPrimaryColor: Color(0xFF334155),
      darkSecondaryColor: Color(0xFF475569),
      lightIconBackground: Color(0xFF81C784),  // 민트 그린 (성장)
      darkIconBackground: Color(0xFF4CAF50),
    );
  }

  Widget _buildCompactTimeSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 원래 크기의 시간 카드들
          SizedBox(
            height: 75.h,
            child: Stack(
              children: [
                // 배경 가이드 라인
                Center(
                  child: Container(
                    height: 2.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF19B3F6).withOpacity(0.3),
                          Color(0xFF42A5F5).withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // 중앙 선택 인디케이터
                Center(
                  child: Container(
                    width: 70.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF19B3F6),
                      borderRadius: BorderRadius.circular(2.r),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF19B3F6).withOpacity(0.4),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // 시간 카드들 (원래 디자인)
                PageView.builder(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedHour;
                    final distance = (index - _selectedHour).abs();
                    final scale = isSelected ? 1.0 : math.max(0.7, 1.0 - (distance * 0.15));
                    final opacity = isSelected ? 1.0 : math.max(0.4, 1.0 - (distance * 0.2));

                    final displayHour = index == 0 ? 12 : (index > 12 ? index - 12 : index);
                    final period = index < 12 ? "AM" : "PM";

                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedHour = index;
                          });
                          _pageController.animateToPage(
                            index,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final pulseScale = isSelected ? _pulseAnimation.value : 1.0;

                            return Transform.scale(
                              scale: scale * pulseScale,
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: opacity,
                                child: Container(
                                  width: 60.w,
                                  height: 65.h,
                                  decoration: BoxDecoration(
                                    gradient: isSelected ? LinearGradient(
                                      colors: [Color(0xFF19B3F6), Color(0xFF42A5F5)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ) : null,
                                    color: !isSelected ? (AppTheme.isDark(context)
                                        ? Color(0xFF424242)
                                        : Colors.white) : null,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: isSelected ? null : Border.all(
                                      color: AppTheme.isDark(context)
                                          ? Colors.grey[600]!.withOpacity(0.5)
                                          : Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: Color(0xFF19B3F6).withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 6),
                                      ),
                                    ] : [
                                      BoxShadow(
                                        color: AppTheme.isDark(context)
                                            ? Colors.black.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 12시간 표기 숫자
                                      Text(
                                        displayHour.toString(),
                                        style: TextStyle(
                                          fontSize: isSelected ? 24.sp : 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.getTextColor(context),
                                        ),
                                      ),

                                      // AM/PM 표시
                                      if (isSelected)
                                        Container(
                                          margin: EdgeInsets.only(top: 2.h),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            period,
                                            style: TextStyle(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF19B3F6),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // 컴팩트한 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Color(0xFF19B3F6),
              inactiveTrackColor: AppTheme.isDark(context)
                  ? Colors.grey[700]
                  : Colors.grey[300],
              thumbColor: Color(0xFF19B3F6),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayColor: Color(0xFF19B3F6).withOpacity(0.2),
              trackHeight: 3.h,
            ),
            child: Slider(
              value: _selectedHour.toDouble(),
              min: 0,
              max: 23,
              divisions: 23,
              onChanged: (value) {
                setState(() {
                  _selectedHour = value.round();
                });
                _pageController.animateToPage(
                  _selectedHour,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordSection() {
    // 12시간 표기 변환
    final displayHour = _selectedHour == 0 ? 12 : (_selectedHour > 12 ? _selectedHour - 12 : _selectedHour);
    final period = _selectedHour < 12 ? "AM" : "PM";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더 (시간 표시 포함)
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: Color(0xFF19B3F6),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "$period ${displayHour}시 키워드",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                height: 1.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF19B3F6).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 키워드 칩들
        _buildKeywordChips(),
      ],
    );
  }

  Widget _buildKeywordChips() {
    final keywords = widget.getKeywordsForHour(_selectedHour);
    final displayKeywords = keywords.take(8).toList();

    return Wrap(
      spacing: 8.w,
      runSpacing: 10.h,
      children: displayKeywords.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final keyword = entry.value;
        return _buildKeywordChip(keyword, index + 1);
      }).toList(),
    );
  }

  Widget _buildKeywordChip(Map<String, dynamic> keyword, int rank) {
    Color chipColor;
    Color textColor;

    if (rank == 1) {
      chipColor = Color(0xFF1E88E5);
      textColor = Colors.white;
    } else if (rank == 2) {
      chipColor = Color(0xFF42A5F5);
      textColor = Colors.white;
    } else if (rank == 3) {
      chipColor = Color(0xFF64B5F6);
      textColor = Colors.white;
    } else {
      chipColor = AppTheme.isDark(context)
          ? Color(0xFF424242)
          : Color(0xFFE0E0E0);
      textColor = AppTheme.isDark(context)
          ? Colors.grey[300]!
          : Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: rank <= 3 ? [
          BoxShadow(
            color: chipColor.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ] : [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 순위 뱃지
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? Colors.white.withOpacity(0.2)
                  : (AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[500]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3
                      ? Colors.white
                      : (AppTheme.isDark(context) ? Colors.white : Colors.grey[700]),
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // 키워드명
          Text(
            keyword['keyword'],
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: rank * 50))
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}