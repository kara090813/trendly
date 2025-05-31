import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../widgets/_widgets.dart';

class KeywordHistoryTabComponent extends StatefulWidget {
  const KeywordHistoryTabComponent({Key? key}) : super(key: key);

  @override
  State<KeywordHistoryTabComponent> createState() => _KeywordHistoryTabComponentState();
}

class _KeywordHistoryTabComponentState extends State<KeywordHistoryTabComponent> {
  String _selectedTimePeriod = '주간'; // 기본값: 주간

  // 키워드 히스토리 스냅샷 데이터 (같은 키워드의 다른 날짜별 기록)
  final List<Map<String, dynamic>> _keywordSnapshots = [
    {
      'date': '2025.02.13',
      'rank': 1,
      'category': '연예',
      'peakTime': '21:30',
      'summary': '포켓몬빵 우유맛 출시로 SNS 화제',
      'isWeekPeak': true, // 주간 최고 순위 여부
    },
    {
      'date': '2025.02.10',
      'rank': 3,
      'category': '연예',
      'peakTime': '14:20',
      'summary': '포켓몬빵 재출시 소식으로 관심 급증',
      'isWeekPeak': false,
    },
    {
      'date': '2025.01.28',
      'rank': 7,
      'category': '연예',
      'peakTime': '19:45',
      'summary': '유튜버 먹방 영상으로 화제 재점화',
      'isWeekPeak': false,
    },
    {
      'date': '2025.01.15',
      'rank': 2,
      'category': '연예',
      'peakTime': '16:10',
      'summary': '연예인 SNS 인증샷으로 트렌드 확산',
      'isWeekPeak': true,
    },
    {
      'date': '2024.12.24',
      'rank': 5,
      'category': '연예',
      'peakTime': '11:30',
      'summary': '크리스마스 특집 상품 출시 발표',
      'isWeekPeak': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(height: 16.h),
        _buildKeywordSelector(),
        SizedBox(height: 16.h),
        _buildPeriodSelector(),
        SizedBox(height: 16.h),
        _buildHistoryGraph(),
        SizedBox(height: 16.h),
        _buildKeywordSnapshots(),
        SizedBox(height: 40.h),
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
          HistoryTitleWidget(
            title: "순위 변화 그래프",
            icon: Icons.trending_up,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFF10B981),  // 에메랄드 (긍정적 변화)
            darkIconBackground: Color(0xFF22C55E),
          ),

          SizedBox(height: 16.h),

          Container(
            height: 280.h,
            padding: EdgeInsets.all(12.w),
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

  // 키워드 히스토리 스냅샷 리스트
  Widget _buildKeywordSnapshots() {
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
          HistoryTitleWidget(
            title: "순위 기록 타임라인",
            icon: Icons.timeline_rounded,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFF8B5CF6),
            darkIconBackground: Color(0xFF7C3AED),
          ),

          SizedBox(height: 16.h),

          // 스냅샷 카드 리스트
          Column(
            children: _keywordSnapshots.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> snapshot = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == _keywordSnapshots.length - 1 ? 0 : 12.h
                ),
                child: _buildSnapshotCard(snapshot, index),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  // 개별 스냅샷 카드
  Widget _buildSnapshotCard(Map<String, dynamic> snapshot, int index) {
    final Color rankColor = _getRankColor(snapshot['rank']);
    final bool isWeekPeak = snapshot['isWeekPeak'] ?? false;

    // 일간 선택시 날짜 대신 시간만 표시
    final bool isDaily = _selectedTimePeriod == '일간';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 해당 날짜의 키워드 상세 페이지로 이동
          context.pushNamed(
            'keywordDetail',
            pathParameters: {'id': '1'}, // 실제 키워드 ID
            queryParameters: {'date': snapshot['date']}, // 특정 날짜
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.isDark(context)
                ? Color(0xFF2A2A36)
                : Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isWeekPeak
                  ? rankColor.withOpacity(0.3)
                  : (AppTheme.isDark(context)
                  ? Colors.grey[700]!.withOpacity(0.3)
                  : Colors.grey[300]!.withOpacity(0.5)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 순위, 날짜/시간, 카테고리, 피크 (심플한 디자인)
              Row(
                children: [
                  // 순위 뱃지 (유일한 강조 요소)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: rankColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${snapshot['rank']}위',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 날짜 또는 시간 (일반 텍스트)
                  if (isDaily)
                    Text(
                      snapshot['peakTime'],
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    )
                  else
                    Text(
                      snapshot['date'],
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),

                  // 일간이 아닐 때만 시간 추가 표시 (일반 텍스트)
                  if (!isDaily) ...[
                    SizedBox(width: 8.w),
                    Text(
                      snapshot['peakTime'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],

                  Spacer(),

                  // 카테고리 (작은 태그)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.isDark(context)
                          ? Colors.grey[700]!.withOpacity(0.5)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      snapshot['category'],
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),
                  ),

                  // 주간 피크 표시 (작은 뱃지)
                  if (isWeekPeak) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'PEAK',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(width: 8.w),

                  // 화살표 아이콘
                  Icon(
                    Icons.chevron_right,
                    size: 16.sp,
                    color: AppTheme.isDark(context)
                        ? Colors.grey[500]
                        : Colors.grey[400],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // 하단: 요약 정보 (일반 텍스트)
              Text(
                snapshot['summary'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.isDark(context)
                      ? Colors.grey[300]
                      : Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 150))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  // 정보 칩 위젯 (컴팩트 버전)
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10.sp,
            color: color,
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 순위에 따른 색상 반환
  Color _getRankColor(int rank) {
    if (rank == 1) return Color(0xFFFF2D55); // 1위는 빨간색
    if (rank <= 3) return Color(0xFFFF6B35); // 2-3위는 주황색
    if (rank <= 5) return Color(0xFF19B3F6); // 4-5위는 파란색
    return AppTheme.isDark(context) ? Colors.grey[500]! : Colors.grey[600]!; // 나머지는 회색
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

    // Y축을 뒤집기 위한 함수 (실제 순위 1-10을 차트용 10-1로 변환)
    double convertRank(double rank) => 11 - rank;

    // 선택된 시간 주기에 따라 다른 데이터 표시
    if (_selectedTimePeriod == '일간') {
      // x축이 시간 (0-24시), Y축은 변환된 순위
      spots = [
        FlSpot(0, convertRank(8)),
        FlSpot(3, convertRank(5)),
        FlSpot(6, convertRank(3)),
        FlSpot(9, convertRank(1)),
        FlSpot(12, convertRank(2)),
        FlSpot(15, convertRank(6)),
        FlSpot(18, convertRank(4)),
        FlSpot(21, convertRank(2)),
        FlSpot(24, convertRank(7)),
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
        FlSpot(0, convertRank(8)),
        FlSpot(1, convertRank(5)),
        FlSpot(2, convertRank(3)),
        FlSpot(3, convertRank(1)),
        FlSpot(4, convertRank(4)),
        FlSpot(5, convertRank(7)),
        FlSpot(6, convertRank(2)),
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
        FlSpot(1, convertRank(10)),
        FlSpot(5, convertRank(8)),
        FlSpot(10, convertRank(5)),
        FlSpot(15, convertRank(1)),
        FlSpot(20, convertRank(3)),
        FlSpot(25, convertRank(8)),
        FlSpot(30, convertRank(2)),
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
        FlSpot(1, convertRank(9)),
        FlSpot(3, convertRank(6)),
        FlSpot(5, convertRank(4)),
        FlSpot(7, convertRank(1)),
        FlSpot(9, convertRank(3)),
        FlSpot(11, convertRank(2)),
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

    // y축 설정 (변환된 값으로 1~10, 실제로는 10~1)
    double minY = 1;
    double maxY = 10;

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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // 등록된 라벨이 있으면 표시
                if (xAxisLabels.containsKey(value)) {
                  return Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Text(
                      xAxisLabels[value]!,
                      style: TextStyle(
                        color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                // 변환된 값을 다시 실제 순위로 변환해서 표시
                if (value == value.roundToDouble() && value >= 1 && value <= 10) {
                  final int actualRank = (11 - value).toInt();
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Text(
                      actualRank.toString(),
                      style: TextStyle(
                        color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 35,
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
                // 변환된 Y값을 다시 실제 순위로 변환
                final int actualRank = (11 - spot.y).toInt();

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
                  "$xLabel: ${actualRank}위",
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
                // 변환된 값을 실제 순위로 변환
                final int actualRank = (11 - spot.y).toInt();

                // 순위가 1위일 때 특별 강조
                if (actualRank == 1) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Color(0xFFFF2D55),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                // 상위권 강조 (1-3위)
                else if (actualRank <= 3) {
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