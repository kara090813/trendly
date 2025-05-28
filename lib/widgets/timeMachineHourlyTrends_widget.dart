import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '_widgets.dart';

class TimeMachineHourlyTrendsWidget extends StatefulWidget {
  final Map<String, Color> categoryColors;
  final Function(int) getKeywordsForHour;
  final List<DateTime> availableTimes; // API에서 받아온 시간 리스트

  const TimeMachineHourlyTrendsWidget({
    Key? key,
    required this.categoryColors,
    required this.getKeywordsForHour,
    required this.availableTimes,
  }) : super(key: key);

  @override
  State<TimeMachineHourlyTrendsWidget> createState() => _TimeMachineHourlyTrendsWidgetState();
}

class _TimeMachineHourlyTrendsWidgetState extends State<TimeMachineHourlyTrendsWidget> {
  int _selectedTimeIndex = 0; // 현재 선택된 시간의 인덱스

  @override
  void initState() {
    super.initState();
    // 시간 리스트가 비어있지 않다면 첫 번째 시간을 기본값으로
    if (widget.availableTimes.isNotEmpty) {
      _selectedTimeIndex = 0;
    }
  }

  // 시간대별 아이콘과 색상을 반환하는 메서드
  Map<String, dynamic> _getTimeTheme(int hour) {
    if (hour >= 0 && hour < 6) {
      // 새벽 (0-5시)
      return {
        'icon': Icons.nightlight_round,
        'colors': [Color(0xFF1A237E), Color(0xFF3949AB)],
        'label': '새벽',
        'iconColor': Color(0xFF7986CB),
      };
    } else if (hour >= 6 && hour < 12) {
      // 아침 (6-11시)
      return {
        'icon': Icons.wb_sunny_outlined,
        'colors': [Color(0xFFFF6F00), Color(0xFFFFB74D)],
        'label': '아침',
        'iconColor': Color(0xFFFF9800),
      };
    } else if (hour >= 12 && hour < 18) {
      // 오후 (12-17시)
      return {
        'icon': Icons.sunny,
        'colors': [Color(0xFF1976D2), Color(0xFF42A5F5)],
        'label': '오후',
        'iconColor': Color(0xFF2196F3),
      };
    } else {
      // 저녁 (18-23시)
      return {
        'icon': Icons.nights_stay,
        'colors': [Color(0xFF4A148C), Color(0xFF7B1FA2)],
        'label': '저녁',
        'iconColor': Color(0xFFAB47BC),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // 시간 데이터가 없으면 빈 컨테이너 반환
    if (widget.availableTimes.isEmpty) {
      return Container();
    }

    return _buildContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(),

          SizedBox(height: 20.h),

          // 키워드 섹션 (위로 이동)
          _buildKeywordSection(),

          SizedBox(height: 24.h),

          // 시간 선택기
          _buildEnhancedTimeSelector(),
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
      lightIconBackground: Color(0xFF81C784),
      darkIconBackground: Color(0xFF4CAF50),
    );
  }

  Widget _buildKeywordSection() {
    final DateTime currentTime = widget.availableTimes[_selectedTimeIndex];
    final String timeString = _formatTime(currentTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더 (현재 선택된 시간 표시)
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: Color(0xFF19B3F6),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "$timeString 키워드",
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

  Widget _buildEnhancedTimeSelector() {
    final DateTime currentTime = widget.availableTimes[_selectedTimeIndex];
    final String timeString = _formatTime(currentTime);
    final Map<String, dynamic> timeTheme = _getTimeTheme(currentTime.hour);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (timeTheme['colors'][0] as Color).withOpacity(0.1),
            (timeTheme['colors'][1] as Color).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (timeTheme['colors'][0] as Color).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 시간대 표시 섹션
            _buildTimeDisplaySection(timeTheme, timeString),

            SizedBox(height: 20.h),

            // 네비게이션 컨트롤
            _buildNavigationControls(timeTheme),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTimeDisplaySection(Map<String, dynamic> timeTheme, String timeString) {
    return Column(
      children: [
        // 시간대 아이콘과 라벨
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: timeTheme['colors'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: (timeTheme['colors'][0] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                timeTheme['icon'],
                color: Colors.white,
                size: 24.sp,
              ),
            ).animate()
                .rotate(duration: 2.seconds, curve: Curves.easeInOut)
                .then()
                .rotate(begin: 0, end: 0.1, duration: 200.ms)
                .then()
                .rotate(begin: 0.1, end: 0, duration: 200.ms),

            SizedBox(width: 12.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeTheme['label'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.isDark(context)
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // 프로그레스 인디케이터
        _buildProgressIndicator(timeTheme),
      ],
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> timeTheme) {
    final double progress = (_selectedTimeIndex + 1) / widget.availableTimes.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedTimeIndex + 1} / ${widget.availableTimes.length}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.isDark(context)
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            Text(
              _formatDate(widget.availableTimes[_selectedTimeIndex]),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.isDark(context)
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Container(
          height: 4.h,
          decoration: BoxDecoration(
            color: AppTheme.isDark(context)
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                height: 4.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: timeTheme['colors'],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ).animate()
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationControls(Map<String, dynamic> timeTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildModernNavButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onTap: _selectedTimeIndex > 0 ? _goToPreviousTime : null,
          timeTheme: timeTheme,
          isLeft: true,
        ),

        // 중앙 시간 점프 버튼들
        _buildTimeJumpButtons(timeTheme),

        _buildModernNavButton(
          icon: Icons.keyboard_arrow_right_rounded,
          onTap: _selectedTimeIndex < widget.availableTimes.length - 1
              ? _goToNextTime
              : null,
          timeTheme: timeTheme,
          isLeft: false,
        ),
      ],
    );
  }

  Widget _buildTimeJumpButtons(Map<String, dynamic> timeTheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 처음으로
        if (_selectedTimeIndex > 2)
          _buildSmallNavButton(
            icon: Icons.first_page,
            onTap: () => setState(() => _selectedTimeIndex = 0),
            timeTheme: timeTheme,
          ),

        SizedBox(width: 8.w),

        // 끝으로
        if (_selectedTimeIndex < widget.availableTimes.length - 3)
          _buildSmallNavButton(
            icon: Icons.last_page,
            onTap: () => setState(() => _selectedTimeIndex = widget.availableTimes.length - 1),
            timeTheme: timeTheme,
          ),
      ],
    );
  }

  Widget _buildModernNavButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Map<String, dynamic> timeTheme,
    required bool isLeft,
  }) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
            colors: [
              (timeTheme['colors'][0] as Color).withOpacity(0.8),
              (timeTheme['colors'][1] as Color).withOpacity(0.6),
            ],
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          )
              : null,
          color: !isEnabled
              ? (AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[300])
              : null,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: (timeTheme['colors'][0] as Color).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey[500],
          size: 24.sp,
        ),
      ),
    ).animate(target: isEnabled ? 1 : 0)
        .scale(duration: 200.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSmallNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required Map<String, dynamic> timeTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: (timeTheme['colors'][0] as Color).withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16.r),
          color: (timeTheme['colors'][0] as Color).withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: timeTheme['iconColor'],
          size: 18.sp,
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildKeywordChips() {
    // 현재 선택된 시간의 hour 값을 전달 (기존 로직과 호환)
    final int currentHour = widget.availableTimes[_selectedTimeIndex].hour;
    final keywords = widget.getKeywordsForHour(currentHour);
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

  // 시간 포맷팅 함수
  String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 날짜 포맷팅 함수
  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}';
  }

  // 이전 시간으로 이동
  void _goToPreviousTime() {
    if (_selectedTimeIndex > 0) {
      setState(() {
        _selectedTimeIndex--;
      });
    }
  }

  // 다음 시간으로 이동
  void _goToNextTime() {
    if (_selectedTimeIndex < widget.availableTimes.length - 1) {
      setState(() {
        _selectedTimeIndex++;
      });
    }
  }
}