import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';

class KeywordHistoryTabComponent extends StatefulWidget {
  const KeywordHistoryTabComponent({Key? key}) : super(key: key);

  @override
  State<KeywordHistoryTabComponent> createState() => _KeywordHistoryTabComponentState();
}

class _KeywordHistoryTabComponentState extends State<KeywordHistoryTabComponent> {
  String _selectedTimePeriod = '주간'; // 기본값: 주간

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(height: 16.h),
        _buildKeywordSelector(),
        SizedBox(height: 16.h),
        _buildPeriodSelector(),
        SizedBox(height: 16.h),
        _buildHistoryGraph(),
        SizedBox(height: 16.h),
        _buildPeakDates(),
        SizedBox(height: 16.h),
      ],
    );
  }

  // 설정 컨테이너 스타일 공통 함수
  Widget _buildSettingContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF252530)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Color(0xFF19B3F6).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? EdgeInsets.all(16.w),
      child: child,
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOutQuad);
  }

  // 키워드 선택기
  Widget _buildKeywordSelector() {
    return _buildSettingContainer(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF19B3F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(10.w),
            child: Icon(
              Icons.trending_up,
              color: Color(0xFF19B3F6),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "포켓몬 우유",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "키워드 히스토리",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          Spacer(),
          _buildButton(
            icon: Icons.search,
            label: "키워드 검색",
            onTap: () {
              // 키워드 검색 기능
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('키워드 검색 기능은 개발 중입니다')),
              );
            },
          ),
        ],
      ),
    );
  }

  // 기간 선택기
  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['일간', '주간', '월간', '전체'].map((period) {
          final isSelected = period == _selectedTimePeriod;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimePeriod = period;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF19B3F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  // 히스토리 그래프
  Widget _buildHistoryGraph() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF19B3F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.insert_chart,
                  color: Color(0xFF19B3F6),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "순위 변화 추이",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.isDark(context) ? Color(0xFF2A2A36) : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppTheme.isDark(context)
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  "낮을수록 상위권",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Container(
            height: 220.h,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF21202C)
                  : Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: _buildDynamicLineChart(),
          ),

          SizedBox(height: 12.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                  Color(0xFF19B3F6),
                  "키워드 순위"
              ),
            ],
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutQuad);
  }

  // 그래프 범례 아이템
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppTheme.isDark(context)
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 피크 타임 날짜 목록
  Widget _buildPeakDates() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF19B3F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.event_available,
                  color: Color(0xFF19B3F6),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "주요 피크 타임",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 날짜 칩 영역
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildDateChip("25.02.13", "3위", Color(0xFF19B3F6)),
              _buildDateChip("25.01.24", "10위", Color(0xFF34C759)),
              _buildDateChip("24.12.24", "1위", Color(0xFFFF2D55)),
              _buildDateChip("24.11.15", "5위", Color(0xFF8A42F8)),
            ],
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  // 날짜 칩
  Widget _buildDateChip(String date, String rank, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event,
            size: 16.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(
            date,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 버튼
  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? Color(0xFF19B3F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 동적 라인 차트 (x축 단위 조정 가능)
  Widget _buildDynamicLineChart() {
    // 데이터 포인트 정의 - 여기서는 x축을 시간 기준으로 설정
    List<FlSpot> spots = [];
    Map<double, String> xAxisLabels = {};

    // 선택된 시간 주기에 따라 다른 데이터 표시
    if (_selectedTimePeriod == '일간') {
      // x축이 시간 (0-24시)
      spots = [
        FlSpot(0, 12),
        FlSpot(3, 8),
        FlSpot(6, 5),
        FlSpot(9, 1),
        FlSpot(12, 3),
        FlSpot(15, 7),
        FlSpot(18, 4),
        FlSpot(21, 2),
        FlSpot(24, 6),
      ];
      xAxisLabels = {
        0: '0시',
        6: '6시',
        12: '12시',
        18: '18시',
        24: '24시',
      };
    } else if (_selectedTimePeriod == '주간') {
      // x축이 요일 (0-6, 월-일)
      spots = [
        FlSpot(0, 8),
        FlSpot(1, 5),
        FlSpot(2, 3),
        FlSpot(3, 1),
        FlSpot(4, 4),
        FlSpot(5, 7),
        FlSpot(6, 2),
      ];
      xAxisLabels = {
        0: '월',
        1: '화',
        2: '수',
        3: '목',
        4: '금',
        5: '토',
        6: '일',
      };
    } else if (_selectedTimePeriod == '월간') {
      // x축이 날짜 (1-30일)
      spots = [
        FlSpot(1, 15),
        FlSpot(5, 10),
        FlSpot(10, 5),
        FlSpot(15, 1),
        FlSpot(20, 3),
        FlSpot(25, 8),
        FlSpot(30, 2),
      ];
      xAxisLabels = {
        1: '1일',
        10: '10일',
        20: '20일',
        30: '30일',
      };
    } else {
      // 전체 - x축이 월 (1-12월)
      spots = [
        FlSpot(1, 12),
        FlSpot(3, 8),
        FlSpot(5, 5),
        FlSpot(7, 1),
        FlSpot(9, 4),
        FlSpot(11, 2),
      ];
      xAxisLabels = {
        1: '1월',
        4: '4월',
        7: '7월',
        10: '10월',
      };
    }

    // x축 최소/최대값 설정
    double minX = spots.first.x;
    double maxX = spots.last.x;

    // y축 설정 (순위이므로 낮을수록 좋음)
    double minY = 0;
    double maxY = 20;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.isDark(context)
                  ? Colors.grey.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppTheme.isDark(context)
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // 등록된 라벨이 있으면 표시
                if (xAxisLabels.containsKey(value)) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      xAxisLabels[value]!,
                      style: TextStyle(
                        color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12.sp,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                // 정수값만 표시
                if (value == value.roundToDouble() && value >= 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12.sp,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot touchedSpot) => AppTheme.isDark(context)
                ? Color(0xFF2A3142).withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            fitInsideHorizontally: true,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                String xLabel = '';

                // x축 라벨 결정
                if (_selectedTimePeriod == '일간') {
                  xLabel = '${spot.x.toInt()}시';
                } else if (_selectedTimePeriod == '주간') {
                  final days = ['월', '화', '수', '목', '금', '토', '일'];
                  xLabel = days[spot.x.toInt() % 7];
                } else if (_selectedTimePeriod == '월간') {
                  xLabel = '${spot.x.toInt()}일';
                } else {
                  xLabel = '${spot.x.toInt()}월';
                }

                return LineTooltipItem(
                  "$xLabel: ${spot.y.toInt()}위",
                  TextStyle(
                    color: AppTheme.isDark(context) ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Color(0xFF19B3F6),
                Color(0xFF1E90FF),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // 순위가 1위일 때 특별 강조
                if (spot.y == 1) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Color(0xFFFF2D55),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                // 상위권 강조 (1-3위)
                else if (spot.y <= 3) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Color(0xFF19B3F6),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                // 일반 점
                else {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Color(0xFF19B3F6).withOpacity(0.7),
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                }
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF19B3F6).withOpacity(0.3),
                  Color(0xFF19B3F6).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}