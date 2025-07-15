import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/_widgets.dart';

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

  final Map<String, Color> categoryColors = {
    '정치': Color(0xFF4A90E2),
    '사회': Color(0xFF27AE60),
    '연예': Color(0xFFE74C3C),
    '스포츠': Color(0xFFF39C12),
    'IT': Color(0xFF9B59B6),
    '경제': Color(0xFF1ABC9C),
    '국제': Color(0xFF34495E),
    '문화': Color(0xFFE67E22),
  };

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
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
                availableTimes: [
                  DateTime(2025, 1, 15, 0, 32),
                  DateTime(2025, 1, 15, 1, 30),
                  DateTime(2025, 1, 15, 2, 1),
                  DateTime(2025, 1, 15, 8, 1),
                  DateTime(2025, 1, 15, 16, 1),
                  DateTime(2025, 1, 15, 18, 1),
                  DateTime(2025, 1, 15, 19, 1),
                  DateTime(2025, 1, 15, 20, 1),
                  DateTime(2025, 1, 15, 21, 1),
                  DateTime(2025, 1, 15, 23, 1)
                ],
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
                    fontSize: 24.sp,
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
                _buildQuickDateChip('오늘', now),
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
                      lastDate: DateTime.now(),
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                        Navigator.of(context).pop();
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
    
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected 
              ? Color(0xFF3B82F6)
              : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected ? null : Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getDailySummaryData() {
    return {
      'topKeyword': '천국보다 아름다운',
      'topKeywordStats': '12회 등장 평균등수 3등',
      'topCategory': '연예',
      'topCategoryStats': '전체 40%',
      'topDiscussion': '갤럭시 S25',
      'topDiscussionStats': '댓글 1,847개 • 반응 3,291개',
      'insights': [
        {
          'icon': '🚀',
          'text': '연예계 이슈가 급부상하며 포켓몬 관련 밈이 대세로 자리잡았습니다.',
        },
        {
          'icon': '⏰',
          'text': '오후 9시경 검색량이 집중되며 IT 기기 관련 토론이 활발했습니다.',
        },
        {
          'icon': '📈',
          'text': '전체적으로 엔터테인먼트 콘텐츠에 대한 관심도가 크게 증가했습니다.',
        },
      ],
    };
  }

  List<Map<String, dynamic>> _getKeywordsForHour(int hour) {
    final baseKeywords = [
      {'keyword': '포켓몬 우유', 'category': '연예', 'change': 5},
      {'keyword': '갤럭시 S25', 'category': 'IT', 'change': -2},
      {'keyword': '크레딧카드 개코', 'category': '연예', 'change': 8},
      {'keyword': '파워에이드', 'category': '경제', 'change': 3},
      {'keyword': '소금 우유', 'category': '문화', 'change': -1},
      {'keyword': '김소현 복귀', 'category': '연예', 'change': 12},
      {'keyword': '링스틱', 'category': 'IT', 'change': 4},
      {'keyword': '투싹', 'category': '스포츠', 'change': -3},
      {'keyword': '갤럭시탭', 'category': 'IT', 'change': 6},
      {'keyword': '새마음', 'category': '사회', 'change': 1},
    ];

    return baseKeywords;
  }
}