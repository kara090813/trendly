import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../app_theme.dart';
import '../widgets/_widgets.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import 'package:intl/intl.dart';

class KeywordHistoryTabComponent extends StatefulWidget {
  const KeywordHistoryTabComponent({Key? key}) : super(key: key);

  @override
  State<KeywordHistoryTabComponent> createState() => _KeywordHistoryTabComponentState();
}

class _KeywordHistoryTabComponentState extends State<KeywordHistoryTabComponent> 
    with TickerProviderStateMixin {
  String _selectedTimePeriod = '주간'; // 기본값: 주간
  late AnimationController _floatingController;
  String _sortType = 'date'; // 정렬 타입: date(날짜순), rank(순위순)
  bool _sortAscending = false; // 정렬 방향: false(내림차순), true(오름차순)
  
  // API 관련 변수
  final ApiService _apiService = ApiService();
  List<Keyword> _keywordHistory = [];
  bool _isLoading = false;
  String _selectedKeyword = '포켓몬 우유'; // 기본 키워드
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    // 기본 키워드로 히스토리 로드
    _loadKeywordHistory();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  /// 키워드 히스토리 로드
  Future<void> _loadKeywordHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Keyword> history = await _apiService.getKeywordHistory(_selectedKeyword);
      setState(() {
        _keywordHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 키워드 히스토리에서 스냅샷 데이터 생성
  List<Map<String, dynamic>> get _keywordSnapshots {
    if (_keywordHistory.isEmpty) return [];
    
    return _keywordHistory.map((keyword) {
      final dateFormatter = DateFormat('yyyy.MM.dd');
      final timeFormatter = DateFormat('HH:mm');
      
      return {
        'date': dateFormatter.format(keyword.created_at),
        'rank': keyword.rank,
        'peakTime': timeFormatter.format(keyword.created_at),
        'isWeekPeak': _isWeekPeak(keyword), // 주간 최고 순위 여부
        'keywordId': keyword.id,
        'discussionRoomId': keyword.current_discussion_room,
      };
    }).toList();
  }

  /// 주간 최고 순위인지 확인
  bool _isWeekPeak(Keyword keyword) {
    final currentWeek = _getWeekNumber(keyword.created_at);
    final sameWeekKeywords = _keywordHistory.where((k) => 
      _getWeekNumber(k.created_at) == currentWeek
    ).toList();
    
    if (sameWeekKeywords.isEmpty) return false;
    
    final bestRank = sameWeekKeywords.map((k) => k.rank).reduce((a, b) => a < b ? a : b);
    return keyword.rank == bestRank;
  }

  /// 날짜로부터 주 번호 계산
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return (daysSinceStart / 7).floor();
  }

  /// 기간별 그래프 데이터 생성
  List<FlSpot> _generateGraphSpots() {
    if (_keywordHistory.isEmpty) return [];

    // Y축을 뒤집기 위한 함수 (실제 순위 1-10을 차트용 10-1로 변환)
    double convertRank(double rank) => 11 - rank;

    switch (_selectedTimePeriod) {
      case '일간':
        return _generateDailySpots(convertRank);
      case '주간':
        return _generateWeeklySpots(convertRank);
      case '월간':
        return _generateMonthlySpots(convertRank);
      case '전체':
        return _generateYearlySpots(convertRank);
      default:
        return [];
    }
  }

  /// 일간 데이터 생성 (최근 7일)
  List<FlSpot> _generateDailySpots(double Function(double) convertRank) {
    final now = DateTime.now();
    final Map<int, List<Keyword>> dailyGroups = {};

    // 최근 7일의 데이터만 필터링
    final recentKeywords = _keywordHistory.where((k) {
      final daysDiff = now.difference(k.created_at).inDays;
      return daysDiff >= 0 && daysDiff < 7;
    }).toList();

    // 일별로 그룹화
    for (var keyword in recentKeywords) {
      final daysAgo = now.difference(keyword.created_at).inDays;
      dailyGroups[daysAgo] ??= [];
      dailyGroups[daysAgo]!.add(keyword);
    }

    final List<FlSpot> spots = [];
    for (int day = 6; day >= 0; day--) {
      if (dailyGroups[day] != null && dailyGroups[day]!.isNotEmpty) {
        final bestRank = dailyGroups[day]!
            .map((k) => k.rank)
            .reduce((a, b) => a < b ? a : b);
        spots.add(FlSpot((6 - day).toDouble(), convertRank(bestRank.toDouble())));
      }
    }

    return spots;
  }

  /// 주간 데이터 생성 (최근 4주)
  List<FlSpot> _generateWeeklySpots(double Function(double) convertRank) {
    final Map<int, List<Keyword>> weeklyGroups = {};

    // 주별로 그룹화
    for (var keyword in _keywordHistory) {
      final week = _getWeekNumber(keyword.created_at);
      weeklyGroups[week] ??= [];
      weeklyGroups[week]!.add(keyword);
    }

    final List<FlSpot> spots = [];
    final sortedWeeks = weeklyGroups.keys.toList()..sort();
    
    // 최근 4주만 표시
    final recentWeeks = sortedWeeks.length > 4 ? sortedWeeks.sublist(sortedWeeks.length - 4) : sortedWeeks;
    
    for (int i = 0; i < recentWeeks.length; i++) {
      final week = recentWeeks[i];
      final keywords = weeklyGroups[week]!;
      final bestRank = keywords.map((k) => k.rank).reduce((a, b) => a < b ? a : b);
      spots.add(FlSpot(i.toDouble(), convertRank(bestRank.toDouble())));
    }

    return spots;
  }

  /// 월간 데이터 생성 (최근 12개월)
  List<FlSpot> _generateMonthlySpots(double Function(double) convertRank) {
    final Map<String, List<Keyword>> monthlyGroups = {};

    // 월별로 그룹화
    for (var keyword in _keywordHistory) {
      final monthKey = '${keyword.created_at.year}-${keyword.created_at.month.toString().padLeft(2, '0')}';
      monthlyGroups[monthKey] ??= [];
      monthlyGroups[monthKey]!.add(keyword);
    }

    final List<FlSpot> spots = [];
    final sortedMonths = monthlyGroups.keys.toList()..sort();
    
    // 최근 12개월만 표시
    final recentMonths = sortedMonths.length > 12 ? sortedMonths.sublist(sortedMonths.length - 12) : sortedMonths;
    
    for (int i = 0; i < recentMonths.length; i++) {
      final month = recentMonths[i];
      final keywords = monthlyGroups[month]!;
      final bestRank = keywords.map((k) => k.rank).reduce((a, b) => a < b ? a : b);
      spots.add(FlSpot(i.toDouble(), convertRank(bestRank.toDouble())));
    }

    return spots;
  }

  /// 연간 데이터 생성 (전체 기간)
  List<FlSpot> _generateYearlySpots(double Function(double) convertRank) {
    final Map<int, List<Keyword>> yearlyGroups = {};

    // 연도별로 그룹화
    for (var keyword in _keywordHistory) {
      final year = keyword.created_at.year;
      yearlyGroups[year] ??= [];
      yearlyGroups[year]!.add(keyword);
    }

    final List<FlSpot> spots = [];
    final sortedYears = yearlyGroups.keys.toList()..sort();
    
    for (int i = 0; i < sortedYears.length; i++) {
      final year = sortedYears[i];
      final keywords = yearlyGroups[year]!;
      final bestRank = keywords.map((k) => k.rank).reduce((a, b) => a < b ? a : b);
      spots.add(FlSpot(i.toDouble(), convertRank(bestRank.toDouble())));
    }

    return spots;
  }

  /// 기간별 X축 라벨 생성
  Map<double, String> _generateXAxisLabels() {
    final Map<double, String> labels = {};

    switch (_selectedTimePeriod) {
      case '일간':
        // 최근 7일
        for (int i = 0; i < 7; i++) {
          final date = DateTime.now().subtract(Duration(days: 6 - i));
          labels[i.toDouble()] = '${date.month}/${date.day}';
        }
        break;
      case '주간':
        // 최근 4주
        for (int i = 0; i < 4; i++) {
          labels[i.toDouble()] = '${i + 1}주';
        }
        break;
      case '월간':
        // 최근 12개월
        final now = DateTime.now();
        for (int i = 0; i < 12; i++) {
          final month = DateTime(now.year, now.month - 11 + i);
          labels[i.toDouble()] = '${month.month}월';
        }
        break;
      case '전체':
        // 전체 연도
        final years = _keywordHistory.map((k) => k.created_at.year).toSet().toList()..sort();
        for (int i = 0; i < years.length; i++) {
          labels[i.toDouble()] = '${years[i]}년';
        }
        break;
    }

    return labels;
  }

  /// 키워드 검색 다이얼로그 표시
  void _showKeywordSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    final bool isDark = AppTheme.isDark(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            '키워드 검색',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '검색할 키워드를 입력하세요',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '예: 포켓몬 우유',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Color(0xFF3B82F6),
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final keyword = searchController.text.trim();
                if (keyword.isNotEmpty) {
                  Navigator.of(context).pop();
                  _changeKeyword(keyword);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '검색',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 키워드 변경 및 히스토리 재로드
  void _changeKeyword(String keyword) {
    setState(() {
      _selectedKeyword = keyword;
    });
    _loadKeywordHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // 배경 그라데이션 애니메이션
        Positioned.fill(
          child: AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ]
                    : [
                        Color(0xFFF8FAFC),
                        Color(0xFFE0E7FF),
                        Color(0xFFF8FAFC),
                      ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        
        // 플로팅 오브 효과
        ...List.generate(2, (index) => 
          Positioned(
            top: 150.h + (index * 300.h),
            left: index.isEven ? -30.w : null,
            right: index.isOdd ? -30.w : null,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    index.isEven ? _floatingController.value * 20 : -_floatingController.value * 20,
                    _floatingController.value * 15,
                  ),
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (index == 0 ? Colors.blue : Colors.purple)
                              .withOpacity(0.2),
                          (index == 0 ? Colors.blue : Colors.purple)
                              .withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // 키워드 선택 섹션
            SliverToBoxAdapter(
              child: _buildKeywordSelector(),
            ),
            
            // 히스토리 그래프 섹션 (기간 선택기 포함)
            SliverToBoxAdapter(
              child: _buildHistoryGraph(),
            ),
            
            // 키워드 스냅샷 섹션
            SliverToBoxAdapter(
              child: _buildKeywordSnapshots(),
            ),
            
            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 100.h),
            ),
          ],
        ),
      ],
    );
  }


  // 키워드 선택기 - TimeMachine 히어로 스타일
  Widget _buildKeywordSelector() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 구조화된 타이틀
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "키워드 히스토리",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "키워드의 과거 순위 변화를 추적하고 분석하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 32.h),
          
          // 키워드 선택 카드
          GestureDetector(
            onTap: () {
              _showKeywordSearchDialog();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                      : [Colors.white, Color(0xFFF8FAFC)],
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
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedKeyword,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor(context),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "선택된 키워드",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF3B82F6),
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
              .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 800.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  // 그래프 내부 기간 선택기 - TimeMachine 스타일
  Widget _buildPeriodSelectorInGraph() {
    final bool isDark = AppTheme.isDark(context);
    final periods = ['일간', '주간', '월간', '전체'];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        height: 50.h,
        child: Row(
          children: periods.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final isSelected = period == _selectedTimePeriod;
            final isLast = index == periods.length - 1;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimePeriod = period;
                  });
                  // 기간 변경 시 UI만 업데이트 (데이터는 동일)
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ) : null,
                    color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent
                          : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected 
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 700.ms)
        .slideY(begin: 0.02, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  // 히스토리 그래프 - TimeMachine 스타일
  Widget _buildHistoryGraph() {
    final bool isDark = AppTheme.isDark(context);
    
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
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "순위 변화 그래프",
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
                    "키워드 순위 역사 추적",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 20.h),
          
          // 기간 선택기
          _buildPeriodSelectorInGraph(),
          
          SizedBox(height: 20.h),
          
          // 그래프 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 280.h,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Color(0xFF0F172A)
                          : Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: _buildDynamicLineChart(),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                          Color(0xFF3B82F6),
                          "키워드 순위"
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
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

  // 키워드 히스토리 스냅샷 리스트 - TimeMachine 스타일
  Widget _buildKeywordSnapshots() {
    final bool isDark = AppTheme.isDark(context);
    
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
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "순위 기록 타임라인",
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
                    "주요 순위 기록 목록",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 1000.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 스냅샷 리스트 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 스냅샷 카드 리스트 (5개 이하: 전체, 5개 이상: 상위 5개)
                  ..._getDisplaySnapshots().asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> snapshot = entry.value;
                    final isLast = index == _getDisplaySnapshots().length - 1;
                    return _buildSnapshotCard(snapshot, index, isLast && _keywordSnapshots.length <= 5);
                  }),
                  
                  // 전체보기 버튼 (5개 이상일 때만 표시)
                  if (_keywordSnapshots.length > 5)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showAllSnapshotsModal();
                          },
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  color: isDark ? Color(0xFFBB86FC) : Color(0xFF8B5CF6),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "전체 기록 보기",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Color(0xFFBB86FC) : Color(0xFF8B5CF6),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  "(총 ${_keywordSnapshots.length}개)",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Color(0xFFBB86FC).withOpacity(0.8) : Color(0xFF8B5CF6).withOpacity(0.8),
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
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 1200.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  // 날짜 포맷팅 함수
  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('.');
      if (parts.length >= 3) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2];

        if (_selectedTimePeriod == '주간') {
          // 주간에서는 연도 생략
          return '$month.$day';
        } else {
          // 다른 기간에서는 연도를 축약 형태로
          final shortYear = year.substring(2); // 2025 -> 25
          return "'$shortYear.$month.$day";
        }
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  // 개별 스냅샷 카드 - TimeMachine 스타일
  Widget _buildSnapshotCard(Map<String, dynamic> snapshot, int index, bool isLast) {
    final Color rankColor = _getRankColor(snapshot['rank']);
    final bool isWeekPeak = snapshot['isWeekPeak'] ?? false;
    final bool isDark = AppTheme.isDark(context);

    // 일간 선택시 날짜 대신 시간만 표시
    final bool isDaily = _selectedTimePeriod == '일간';

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 해당 날짜의 키워드 상세 페이지로 이동
            context.pushNamed(
              'keywordDetail',
              pathParameters: {'id': snapshot['keywordId'].toString()}, // 실제 키워드 ID
              queryParameters: {'date': snapshot['date']}, // 특정 날짜
            );
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Row(
            children: [
              // 순위 번호 - TimeMachine 스타일
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    snapshot['rank'].toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
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
                    Row(
                      children: [
                        // 일간: 시간만 텍스트로 표시
                        if (isDaily)
                          Text(
                            snapshot['peakTime'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor(context),
                            ),
                          )
                        // 주간/월간/전체: 날짜(텍스트) + 시간(태그)
                        else ...[
                          Text(
                            _formatDate(snapshot['date']),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF3B82F6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              snapshot['peakTime'],
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                        
                        Spacer(),
                        
                        // 주간 피크 표시
                        if (isWeekPeak)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'PEAK',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // 토론방 정보 표시
                    if (snapshot['discussionRoomId'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            size: 14.sp,
                            color: isDark ? Colors.blue[300] : Colors.blue[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '토론방 활성화',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.blue[300] : Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${snapshot['date']} ${snapshot['peakTime']}에 ${snapshot['rank']}위 기록',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 150))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  // 표시할 스냅샷 가져오기
  List<Map<String, dynamic>> _getDisplaySnapshots() {
    if (_keywordSnapshots.length <= 5) {
      // 5개 이하면 전체 표시 (날짜순)
      return _keywordSnapshots;
    } else {
      // 5개 이상이면 상위 5개 표시 (순위순, 동일 순위는 최신순)
      final sorted = List<Map<String, dynamic>>.from(_keywordSnapshots);
      sorted.sort((a, b) {
        // 먼저 순위로 정렬 (오름차순)
        final rankCompare = a['rank'].compareTo(b['rank']);
        if (rankCompare != 0) return rankCompare;
        
        // 순위가 같으면 날짜로 정렬 (내림차순 - 최신순)
        return b['date'].compareTo(a['date']);
      });
      return sorted.take(5).toList();
    }
  }
  
  // 전체보기 모달 표시
  void _showAllSnapshotsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllSnapshotsModal(),
    );
  }
  
  // 전체보기 모달 위젯
  Widget _buildAllSnapshotsModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: 0.85.sh,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            children: [
              // 핸들 바
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // 헤더
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '전체 순위 기록',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '총 ${_keywordSnapshots.length}개의 기록',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 정렬 옵션
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    // 날짜순 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (_sortType == 'date') {
                              _sortAscending = !_sortAscending;
                            } else {
                              _sortType = 'date';
                              _sortAscending = false;
                            }
                          });
                        },
                        child: Container(
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: _sortType == 'date' 
                                ? Color(0xFF8B5CF6) 
                                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
                            border: Border.all(
                              color: _sortType == 'date'
                                  ? Colors.transparent
                                  : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '날짜순',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _sortType == 'date'
                                        ? Colors.white
                                        : (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                                  ),
                                ),
                                if (_sortType == 'date') ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 순위순 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (_sortType == 'rank') {
                              _sortAscending = !_sortAscending;
                            } else {
                              _sortType = 'rank';
                              _sortAscending = false;
                            }
                          });
                        },
                        child: Container(
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: _sortType == 'rank' 
                                ? Color(0xFF8B5CF6) 
                                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(12.r)),
                            border: Border.all(
                              color: _sortType == 'rank'
                                  ? Colors.transparent
                                  : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '순위순',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _sortType == 'rank'
                                        ? Colors.white
                                        : (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.emoji_events_rounded,
                                  size: 16.sp,
                                  color: _sortType == 'rank'
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                                ),
                                if (_sortType == 'rank') ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
          
              // 리스트
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: _getSortedSnapshots().length,
                  itemBuilder: (context, index) {
                    final snapshot = _getSortedSnapshots()[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed(
                          'keywordDetail',
                          pathParameters: {'id': snapshot['keywordId'].toString()},
                          queryParameters: {'date': snapshot['date']},
                        );
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            // 순위
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: _getRankColor(snapshot['rank']),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Center(
                                child: Text(
                                  snapshot['rank'].toString(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // 내용
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _formatDate(snapshot['date']),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF3B82F6).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Text(
                                          snapshot['peakTime'],
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ),
                                      if (snapshot['isWeekPeak'] == true) ...[
                                        SizedBox(width: 8.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                                            ),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Text(
                                            'PEAK',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  if (snapshot['discussionRoomId'] != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.forum_rounded,
                                          size: 14.sp,
                                          color: isDark ? Colors.blue[300] : Colors.blue[600],
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '토론방 활성화 상태',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: isDark ? Colors.blue[300] : Colors.blue[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      '토론방 없음',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
                ),
              ),
            ],
          ),
        ).animate()
            .slideY(begin: 1, end: 0, duration: 300.ms)
            .fadeIn();
      },
    );
  }
  
  // 정렬된 스냅샷 가져오기
  List<Map<String, dynamic>> _getSortedSnapshots() {
    final sorted = List<Map<String, dynamic>>.from(_keywordSnapshots);
    
    if (_sortType == 'date') {
      // 날짜순 정렬
      if (_sortAscending) {
        // 오름차순 (과거 → 최신)
        sorted.sort((a, b) => a['date'].compareTo(b['date']));
      } else {
        // 내림차순 (최신 → 과거)
        sorted.sort((a, b) => b['date'].compareTo(a['date']));
      }
    } else {
      // 순위순 정렬
      sorted.sort((a, b) {
        int rankCompare;
        if (_sortAscending) {
          // 오름차순 (낮은 순위 → 높은 순위)
          rankCompare = b['rank'].compareTo(a['rank']);
        } else {
          // 내림차순 (높은 순위 → 낮은 순위)
          rankCompare = a['rank'].compareTo(b['rank']);
        }
        
        if (rankCompare != 0) return rankCompare;
        // 동일 순위는 항상 최신순
        return b['date'].compareTo(a['date']);
      });
    }
    
    return sorted;
  }

  // 순위에 따른 색상 반환 - TimeMachine 스타일
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700); // 금색
      case 2:
        return Color(0xFFC0C0C0); // 은색
      case 3:
        return Color(0xFFCD7F32); // 동색
      default:
        return Color(0xFF6B7280); // 회색
    }
  }


  // 동적 라인 차트 (실제 키워드 데이터 기반)
  Widget _buildDynamicLineChart() {
    // 로딩 상태 처리
    if (_isLoading) {
      return Container(
        height: 280.h,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
      );
    }

    // 에러 상태 처리
    if (_errorMessage != null) {
      return Container(
        height: 280.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                '데이터를 불러올 수 없습니다',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 데이터가 없을 때 처리
    if (_keywordHistory.isEmpty) {
      return Container(
        height: 280.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timeline_rounded,
                color: Colors.grey,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                '키워드 데이터가 없습니다',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 실제 데이터 기반으로 그래프 생성
    final List<FlSpot> spots = _generateGraphSpots();
    final Map<double, String> xAxisLabels = _generateXAxisLabels();

    if (spots.isEmpty) {
      return Container(
        height: 280.h,
        child: Center(
          child: Text(
            '선택한 기간에 해당하는 데이터가 없습니다',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // x축 최소/최대값 설정
    double minX = spots.isNotEmpty ? spots.first.x : 0;
    double maxX = spots.isNotEmpty ? spots.last.x : 1;

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
                Color(0xFF3B82F6),
                Color(0xFF1D4ED8),
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
                    color: Color(0xFFFFD700),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                // 상위권 강조 (1-3위)
                else if (actualRank <= 3) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Color(0xFF3B82F6),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                // 일반 점
                else {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Color(0xFF3B82F6).withOpacity(0.7),
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
                  Color(0xFF3B82F6).withOpacity(0.3),
                  Color(0xFF3B82F6).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}