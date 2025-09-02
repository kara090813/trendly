import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/_widgets.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../funcs/category_colors.dart';
import 'package:intl/intl.dart';

class TimeMachineTabComponent extends StatefulWidget {
  const TimeMachineTabComponent({Key? key}) : super(key: key);

  @override
  State<TimeMachineTabComponent> createState() =>
      _TimeMachineTabComponentState();
}

class _TimeMachineTabComponentState extends State<TimeMachineTabComponent> 
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  late AnimationController _floatingController;
  
  CapsuleModel? _capsuleData;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();
  final Set<String> _unavailableDates = {};

  // Use centralized category colors for consistency
  final Map<String, Color> categoryColors = CategoryColors.allCategoryColors;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _loadCapsuleData();
  }
  
  Future<void> _loadCapsuleData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final capsule = await _apiService.getCapsule(dateStr);
      setState(() {
        _capsuleData = capsule;
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // 해당 날짜의 캡슐이 존재하지 않을 경우 빈 데이터로 처리
      if (errorMessage.contains('해당 날짜의 캡슐이 존재하지 않습니다')) {
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
        _unavailableDates.add(dateStr);
        
        // 빈 캡슐 데이터 생성
        setState(() {
          _capsuleData = null; // null로 설정하여 데이터 없음 상태 표시
          _isLoading = false;
          _errorMessage = null; // 에러 메시지는 제거 (정상적인 상태로 처리)
        });
        return;
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }
  
  void _selectPreviousAvailableDate() async {
    DateTime previousDate = _selectedDate.subtract(const Duration(days: 1));
    final firstDate = DateTime(2020);
    
    // 사용 가능한 날짜를 찾을 때까지 이전 날짜로 이동
    while (previousDate.isAfter(firstDate)) {
      final dateStr = DateFormat('yyyy-MM-dd').format(previousDate);
      if (!_unavailableDates.contains(dateStr)) {
        setState(() {
          _selectedDate = previousDate;
        });
        _loadCapsuleData();
        return;
      }
      previousDate = previousDate.subtract(const Duration(days: 1));
    }
    
    // 사용 가능한 날짜를 찾지 못한 경우
    setState(() {
      _errorMessage = '사용 가능한 데이터가 없습니다.';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
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
        
        // 플로팅 오브 효과 (최적화)
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
        
        if (_isLoading)
          _buildLoadingWidget()
        else if (_errorMessage != null)
          _buildErrorWidget()
        else if (_capsuleData == null)
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // 히어로 섹션 (기존과 동일)
              SliverToBoxAdapter(
                child: TimeMachineHeroSection(
                  selectedDate: _selectedDate,
                  onDateTap: _selectDate,
                  summaryData: _getDailySummaryData(),
                ),
              ),
              
              // 데이터 없음 UI
              SliverToBoxAdapter(
                child: _buildNoDataWidget(),
              ),
            ],
          )
        else
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
            // 히어로 섹션
            SliverToBoxAdapter(
              child: TimeMachineHeroSection(
                selectedDate: _selectedDate,
                onDateTap: _selectDate,
                summaryData: _getDailySummaryData(),
              ),
            ),
            
            // 메트릭 섹션
            SliverToBoxAdapter(
              child: TimeMachineMetricsSection(
                summaryData: _getDailySummaryData(),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.03, end: 0, duration: 600.ms),
            ),
            
            // 트렌드 섹션  
            SliverToBoxAdapter(
              child: TimeMachineTrendsSection(
                categoryColors: categoryColors,
                getKeywordsForHour: _getKeywordsForHour,
                availableTimes: _getAvailableTimes(),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.03, end: 0, duration: 600.ms),
            ),

            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 20.h),
            ),
          ],
        ),
        
      ],
    );
  }

  Future<void> _selectDate() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModernDatePicker(),
    );
  }
  
  Widget _buildModernDatePicker() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    
    return Container(
      height: 0.7.sh,
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E293B) : Colors.white,
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
                Text(
                  '날짜 선택',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          // 빠른 선택 버튼들
          Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickDateChip('어제', now.subtract(Duration(days: 1))),
                _buildQuickDateChip('3일 전', now.subtract(Duration(days: 3))),
                _buildQuickDateChip('1주일 전', now.subtract(Duration(days: 7))),
                _buildQuickDateChip('1개월 전', now.subtract(Duration(days: 30))),
              ],
            ),
          ),
          
          // 캘린더
          Expanded(
            child: Container(
              margin: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode 
                    ? [Color(0xFF334155), Color(0xFF1E293B)]
                    : [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF3B82F6),
                        onPrimary: Colors.white,
                        surface: Colors.transparent,
                        onSurface: isDarkMode ? Colors.white : Colors.black,
                      ),
                      textTheme: TextTheme(
                        bodyMedium: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().subtract(const Duration(days: 1)),
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                        Navigator.of(context).pop();
                        _loadCapsuleData();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 300.ms)
      .fadeIn();
  }
  
  Widget _buildQuickDateChip(String label, DateTime date) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedDate.year == date.year && 
                      _selectedDate.month == date.month && 
                      _selectedDate.day == date.day;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final isUnavailable = _unavailableDates.contains(dateStr);
    
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          if (isUnavailable) {
            // 사용할 수 없는 날짜는 선택 불가
            return;
          }
          setState(() {
            _selectedDate = date;
          });
          Navigator.of(context).pop();
          _loadCapsuleData();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isUnavailable 
              ? Colors.grey.withOpacity(0.3)
              : (isSelected 
                  ? Color(0xFF3B82F6)
                  : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected ? null : Border.all(
              color: isUnavailable 
                ? Colors.grey.withOpacity(0.5)
                : (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isUnavailable 
                  ? Colors.grey
                  : (isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getDailySummaryData() {
    if (_capsuleData == null) {
      if (_isLoading) {
        return {
          'topKeyword': '로딩 중...',
          'topKeywordStats': '데이터를 불러오는 중입니다',
          'topCategory': '기타',
          'topCategoryStats': '전체 0%',
          'topDiscussion': '데이터 없음',
          'topDiscussionStats': '데이터 없음',
          'insights': [
            {
              'icon': '⏳',
              'text': '데이터를 불러오는 중입니다...',
            },
          ],
        };
      } else {
        // 로딩이 끝났는데 데이터가 없는 경우
        return {
          'topKeyword': '데이터 없음',
          'topKeywordStats': '해당 날짜의 데이터가 없습니다',
          'topCategory': '없음',
          'topCategoryStats': '전체 0%',
          'topDiscussion': '데이터 없음',
          'topDiscussionStats': '데이터 없음',
          'insights': [
            {
              'icon': '📊',
              'text': '해당 날짜의 키워드 데이터가 없습니다.',
            },
          ],
        };
      }
    }
    
    final top3 = _capsuleData!.top3Keywords;
    if (top3.isEmpty) {
      return {
        'topKeyword': '데이터 없음',
        'topKeywordStats': '해당 날짜의 데이터가 없습니다',
        'topCategory': '기타',
        'topCategoryStats': '전체 0%',
        'topDiscussion': '데이터 없음',
        'topDiscussionStats': '데이터 없음',
        'insights': [
          {
            'icon': '📊',
            'text': '해당 날짜의 키워드 데이터가 없습니다.',
          },
        ],
      };
    }
    
    final topKeyword = top3.first;
    return {
      'topKeyword': topKeyword.keyword,
      'topKeywordStats': '${topKeyword.appearanceCount}회 등장 평균등수 ${topKeyword.avgRank.toStringAsFixed(1)}등',
      'topCategory': '트렌드',
      'topCategoryStats': '전체 ${(topKeyword.score).toStringAsFixed(1)}%',
      'topDiscussion': topKeyword.keyword,
      'topDiscussionStats': '점수 ${topKeyword.score.toStringAsFixed(1)}',
      'top3_keywords': top3.map((keyword) => {
        'keyword': keyword.keyword,
        'appearance_count': keyword.appearanceCount,
        'avg_rank': keyword.avgRank,
        'score': keyword.score,
        'last_keyword_id': keyword.lastKeywordId,
      }).toList(),
      'insights': [
        {
          'icon': '🚀',
          'text': '${topKeyword.keyword}가 가장 인기 있는 키워드로 ${topKeyword.appearanceCount}회 등장했습니다.',
        },
        {
          'icon': '📈',
          'text': '상위 3개 키워드의 평균 점수는 ${(top3.map((k) => k.score).reduce((a, b) => a + b) / top3.length).toStringAsFixed(1)}입니다.',
        },
        {
          'icon': '⏰',
          'text': '${_capsuleData!.hourlyKeywords.length}개의 시간대에서 키워드 데이터가 수집되었습니다.',
        },
      ],
    };
  }

  List<Map<String, dynamic>> _getKeywordsForHour(int hour) {
    if (_capsuleData == null) {
      return [];
    }
    
    // 시간대별 키워드 찾기
    final targetTime = '${hour.toString().padLeft(2, '0')}:00';
    final hourlyData = _capsuleData!.hourlyKeywords
        .where((h) => h.time.startsWith(targetTime.substring(0, 2)))
        .toList();
    
    if (hourlyData.isEmpty) {
      return [];
    }
    
    // 첫 번째 시간대 데이터 사용
    final keywords = hourlyData.first.keywords;
    
    // SimpleKeyword 모델을 Map 형태로 변환
    return keywords.asMap().entries.map((entry) {
      final index = entry.key;
      final simpleKeyword = entry.value;
      
      return {
        'keyword': simpleKeyword.keyword,
        'category': simpleKeyword.category,
        'rank': simpleKeyword.rank,
        'id': simpleKeyword.id,
        'type2': simpleKeyword.type2,
        'change': (index % 2 == 0) ? (index + 1) : -(index + 1), // 임시 변화량
      };
    }).take(10).toList();
  }
  
  List<DateTime> _getAvailableTimes() {
    if (_capsuleData == null) {
      return [];
    }
    
    return _capsuleData!.hourlyKeywords.map((hourly) {
      final timeParts = hourly.time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour, minute);
    }).toList();
  }
  
  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48.w,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            '데이터를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? '알 수 없는 오류가 발생했습니다',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.red.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadCapsuleData,
            child: Text('다시 시도'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingWidget() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              '데이터를 불러오는 중...',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoDataWidget() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 100.h), // 상단 마진을 60에서 20으로 줄임
      child: Container(
        width: double.infinity, // 전체 너비 사용
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 50.h), // padding 조정
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Color(0xFF1F2937), Color(0xFF111827)]
                : [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6B7280).withOpacity(0.2),
                    Color(0xFF4B5563).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.calendar_view_day_outlined,
                size: 40.w,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // 제목
            Text(
              '데이터가 없습니다',
              style: TextStyle(
                fontSize: 23.sp,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // 설명
            Text(
              '해당 날짜의 키워드 데이터를\n찾을 수 없습니다',
              style: TextStyle(
                fontSize: 15.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}