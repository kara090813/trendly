import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';

class DiscussionHistoryTabComponent extends StatefulWidget {
  const DiscussionHistoryTabComponent({super.key});

  @override
  State<DiscussionHistoryTabComponent> createState() => _DiscussionHistoryTabComponentState();
}

class _DiscussionHistoryTabComponentState extends State<DiscussionHistoryTabComponent> 
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<DiscussionRoom> _allHistoryRooms = [];
  List<DiscussionRoom> _filteredRooms = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  late AnimationController _floatingController;
  
  // 검색 및 필터링 상태
  String _searchQuery = '';
  String _selectedCategory = '전체';
  String _selectedPeriod = '전체';
  String _sortOption = 'newest'; // newest, oldest, popular, active
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = ['전체'];
  Map<String, int> _categoryCounts = {};
  
  // 페이징
  int _currentPage = 1;
  final int _pageSize = 50; // 대량 데이터를 위해 증가
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  
  
  // 고급 필터
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showAdvancedFilters = false;
  RangeValues _commentRange = RangeValues(0, 1000);
  RangeValues _participantRange = RangeValues(0, 500);

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadHistoryData();
    _scrollController.addListener(_onScroll);
    
    _searchController.addListener(() {
      _debounceSearch();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  // 검색 디바운싱
  void _debounceSearch() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
    _applyFilters();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
      _allHistoryRooms = [];
      _filteredRooms = [];
    });

    try {
      // 병렬로 데이터 로드
      final results = await Future.wait([
        _loadCategories(),
        _loadHistoryRooms(),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '히스토리 데이터를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      // Mock 카테고리 데이터 (실제로는 API 호출)
      final categories = ['정치', '경제', '사회', '문화', '스포츠', '국제', '과학', '기타'];
      final counts = {
        '전체': 2847,
        '정치': 456,
        '경제': 378,
        '사회': 623,
        '문화': 234,
        '스포츠': 189,
        '국제': 345,
        '과학': 167,
        '기타': 455,
      };
      
      setState(() {
        _categories = ['전체', ...categories];
        _categoryCounts = counts;
      });
    } catch (e) {
      print('카테고리 로드 실패: $e');
    }
  }


  Future<void> _loadHistoryRooms() async {
    try {
      // Mock 데이터 생성 (실제로는 API 호출)
      final List<DiscussionRoom> mockRooms = [];
      final keywords = [
        '대통령 탄핵', '비트코인 급락', '아이돌 논란', '월드컵 경기', '인공지능 발전',
        '부동산 정책', '코로나 백신', '기후변화', '우크라이나 전쟁', '메타버스',
        '주 52시간', '최저임금', '4차 산업혁명', '전기차 시대', '우주 개발',
        '넷플릭스 오징어게임', 'K-POP 월드투어', '배달음식 규제', '카카오톡 장애',
        '삼성 반도체', 'LG 배터리', '현대차 수소차', '네이버 웹툰', '쿠팡 물류',
      ];
      
      final categories = ['정치', '경제', '사회', '문화', '스포츠', '국제', '과학'];
      
      for (int i = 0; i < 100; i++) { // 처음에 100개 로드
        final createdAt = DateTime.now().subtract(Duration(days: i + 1));
        final closedAt = createdAt.add(Duration(hours: 12 + (i % 20)));
        
        mockRooms.add(DiscussionRoom(
          id: 3000 + i,
          keyword: keywords[i % keywords.length] + (i > 24 ? ' ${i ~/ 25 + 1}' : ''),
          keyword_id_list: [100 + i],
          is_closed: true,
          created_at: createdAt,
          updated_at: closedAt,
          closed_at: closedAt,
          comment_count: 15 + (i % 200),
          comment_summary: '활발한 토론이 진행되었습니다. 다양한 의견이 교환되었고...',
          positive_count: 20 + (i % 50),
          neutral_count: 15 + (i % 30),
          negative_count: 10 + (i % 25),
          sentiment_snapshot: [],
          category: categories[i % categories.length],
        ));
      }
      
      setState(() {
        _allHistoryRooms = mockRooms;
        _filteredRooms = List.from(mockRooms);
        _hasMoreData = mockRooms.length >= _pageSize;
      });
    } catch (e) {
      throw Exception('히스토리 룸 로드 실패: $e');
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMoreData || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
      
      // Mock 추가 데이터
      final List<DiscussionRoom> newRooms = [];
      final baseIndex = _allHistoryRooms.length;
      
      for (int i = 0; i < 50; i++) {
        final idx = baseIndex + i;
        final createdAt = DateTime.now().subtract(Duration(days: idx + 1));
        final closedAt = createdAt.add(Duration(hours: 12 + (idx % 20)));
        
        newRooms.add(DiscussionRoom(
          id: 3000 + idx,
          keyword: '과거 토론 ${idx + 1}',
          keyword_id_list: [100 + idx],
          is_closed: true,
          created_at: createdAt,
          updated_at: closedAt,
          closed_at: closedAt,
          comment_count: 5 + (idx % 100),
          comment_summary: '과거에 진행된 토론입니다.',
          positive_count: 10 + (idx % 30),
          neutral_count: 8 + (idx % 20),
          negative_count: 5 + (idx % 15),
          sentiment_snapshot: [],
          category: ['정치', '경제', '사회'][idx % 3],
        ));
      }
      
      if (mounted) {
        setState(() {
          _allHistoryRooms.addAll(newRooms);
          _currentPage++;
          _hasMoreData = _allHistoryRooms.length < 1000; // 최대 1000개
          _isLoadingMore = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<DiscussionRoom> filtered = List.from(_allHistoryRooms);
    
    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) =>
        room.keyword.toLowerCase().contains(_searchQuery) ||
        (room.comment_summary ?? '').toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    // 카테고리 필터
    if (_selectedCategory != '전체') {
      filtered = filtered.where((room) => room.category == _selectedCategory).toList();
    }
    
    // 기간 필터
    if (_selectedPeriod != '전체') {
      final now = DateTime.now();
      DateTime filterDate;
      
      switch (_selectedPeriod) {
        case '1주일':
          filterDate = now.subtract(Duration(days: 7));
          break;
        case '1개월':
          filterDate = now.subtract(Duration(days: 30));
          break;
        case '3개월':
          filterDate = now.subtract(Duration(days: 90));
          break;
        case '6개월':
          filterDate = now.subtract(Duration(days: 180));
          break;
        case '1년':
          filterDate = now.subtract(Duration(days: 365));
          break;
        default:
          filterDate = DateTime(2020);
      }
      
      filtered = filtered.where((room) =>
        room.created_at.isAfter(filterDate)
      ).toList();
    }
    
    // 날짜 범위 필터
    if (_startDate != null) {
      filtered = filtered.where((room) => room.created_at.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((room) => room.created_at.isBefore(_endDate!)).toList();
    }
    
    // 댓글 수 필터
    filtered = filtered.where((room) {
      final count = room.comment_count ?? 0;
      return count >= _commentRange.start && count <= _commentRange.end;
    }).toList();
    
    // 정렬
    switch (_sortOption) {
      case 'newest':
        filtered.sort((a, b) {
          final aDate = a.closed_at ?? a.updated_at ?? DateTime.now();
          final bDate = b.closed_at ?? b.updated_at ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
        break;
      case 'oldest':
        filtered.sort((a, b) {
          final aDate = a.closed_at ?? a.updated_at ?? DateTime.now();
          final bDate = b.closed_at ?? b.updated_at ?? DateTime.now();
          return aDate.compareTo(bDate);
        });
        break;
      case 'popular':
        filtered.sort((a, b) {
          final aTotal = (a.positive_count ?? 0) + (a.neutral_count ?? 0) + (a.negative_count ?? 0);
          final bTotal = (b.positive_count ?? 0) + (b.neutral_count ?? 0) + (b.negative_count ?? 0);
          return bTotal.compareTo(aTotal);
        });
        break;
      case 'active':
        filtered.sort((a, b) => (b.comment_count ?? 0).compareTo(a.comment_count ?? 0));
        break;
    }
    
    setState(() {
      _filteredRooms = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
            ),
            SizedBox(height: 16.h),
            Text(
              '히스토리 데이터를 불러오는 중...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadHistoryData,
              child: Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB74D),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

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
                          (index == 0 ? Color(0xFFFFB74D) : Color(0xFF9C27B0))
                              .withOpacity(0.2),
                          (index == 0 ? Color(0xFFFFB74D) : Color(0xFF9C27B0))
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
        
        RefreshIndicator(
          onRefresh: _loadHistoryData,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              // 히어로 섹션
              SliverToBoxAdapter(
                child: _buildHistoryHeader(),
              ),
              
              // 검색 및 필터 섹션
              SliverToBoxAdapter(
                child: _buildSearchAndFilterSection(),
              ),
              
              // 토론방 리스트 섹션
              SliverToBoxAdapter(
                child: _buildHistoryList(),
              ),
              
              // 하단 여백
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFB74D).withOpacity(0.3),
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
                      "토론 히스토리",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "과거 토론 ${_filteredRooms.length}개를 탐색하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // 고급 필터 토글
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _showAdvancedFilters ? Color(0xFFFFB74D) : (isDark ? Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Color(0xFFFFB74D).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAdvancedFilters = !_showAdvancedFilters;
                    });
                  },
                  child: Icon(
                    Icons.tune,
                    color: _showAdvancedFilters ? Colors.white : Color(0xFFFFB74D),
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }


  Widget _buildSearchAndFilterSection() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 24.h),
      child: Column(
        children: [
          // 섹션 헤더 (Live 탭 스타일)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "토론 검색",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor(context),
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
                // 필터 버튼
                InkWell(
                  onTap: _showFilterModal,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _hasActiveFilters() 
                          ? Color(0xFFFFB74D).withOpacity(0.1)
                          : (isDark ? Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _hasActiveFilters()
                            ? Color(0xFFFFB74D).withOpacity(0.3)
                            : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 14.sp,
                          color: _hasActiveFilters()
                              ? Color(0xFFFFB74D)
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '필터',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _hasActiveFilters()
                                ? Color(0xFFFFB74D)
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        if (_hasActiveFilters()) ...[
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFB74D),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _getActiveFilterCount().toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Padding(
            padding: EdgeInsets.only(left: 40.w, right: 24.w),
            child: Text(
              _hasActiveFilters() 
                  ? '${_getActiveFilterCount()}개의 필터가 적용되었습니다'
                  : '토론 제목으로 검색하고, 필터 버튼을 눌러 상세 조건을 설정하세요',
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // 검색바 (심플하게)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '토론 제목 검색...',
                prefixIcon: Icon(Icons.search, color: Color(0xFFFFB74D), size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey, size: 18.sp),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _applyFilters();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14.sp,
              ),
            ),
          ),
          
          // 활성 필터 표시
          if (_hasActiveFilters()) ...[
            SizedBox(height: 12.h),
            Container(
              height: 32.h,
              margin: EdgeInsets.only(left: 24.w),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedCategory != '전체')
                    _buildActiveFilterChip(
                      Icons.category_outlined,
                      _selectedCategory,
                      () {
                        setState(() {
                          _selectedCategory = '전체';
                        });
                        _applyFilters();
                      },
                    ),
                  if (_selectedPeriod != '전체')
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: _buildActiveFilterChip(
                        Icons.calendar_today_outlined,
                        _selectedPeriod,
                        () {
                          setState(() {
                            _selectedPeriod = '전체';
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  if (_sortOption != 'newest')
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: _buildActiveFilterChip(
                        Icons.sort_outlined,
                        _getSortDisplayName(_sortOption),
                        () {
                          setState(() {
                            _sortOption = 'newest';
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.03, end: 0, duration: 600.ms);
  }

  Widget _buildFilterDropdown(String title, String value, List<String> items, 
      Function(String) onChanged, {IconData? icon}) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.expand_more,
            size: 18.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16.sp,
                      color: Color(0xFFFFB74D).withOpacity(0.8),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextColor(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          dropdownColor: isDark ? Color(0xFF1E293B) : Colors.white,
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != '전체' || 
           _selectedPeriod != '전체' || 
           _sortOption != 'newest';
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedCategory != '전체') count++;
    if (_selectedPeriod != '전체') count++;
    if (_sortOption != 'newest') count++;
    return count;
  }

  Widget _buildActiveFilterChip(IconData icon, String value, VoidCallback onRemove) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFB74D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(0xFFFFB74D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Color(0xFFFFB74D)),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB74D),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: Color(0xFFFFB74D),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    final bool isDark = AppTheme.isDark(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 0.7.sh,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // 헤더
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Text(
                    '필터 설정',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  Spacer(),
                  if (_hasActiveFilters())
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = '전체';
                          _selectedPeriod = '전체';
                          _sortOption = 'newest';
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text(
                        '초기화',
                        style: TextStyle(
                          color: Color(0xFFFFB74D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            
            // 필터 옵션들
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  _buildFilterSection(
                    '카테고리',
                    Icons.category_outlined,
                    _selectedCategory,
                    _categories,
                    (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  _buildFilterSection(
                    '기간',
                    Icons.calendar_today_outlined,
                    _selectedPeriod,
                    ['전체', '1주일', '1개월', '3개월', '6개월', '1년'],
                    (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  _buildFilterSection(
                    '정렬',
                    Icons.sort_outlined,
                    _getSortDisplayName(_sortOption),
                    ['최신순', '오래된순', '인기순', '활발한순'],
                    (value) {
                      setState(() {
                        _sortOption = _getSortOptionFromDisplay(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // 적용 버튼
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFB74D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '필터 적용',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, String selectedValue, 
      List<String> options, Function(String) onChanged) {
    final bool isDark = AppTheme.isDark(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: Color(0xFFFFB74D)),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFFFFB74D)
                      : (isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? Color(0xFFFFB74D)
                        : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getTextColor(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '고급 필터',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 날짜 범위 선택
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16.sp, color: Color(0xFFFFB74D)),
                        SizedBox(width: 8.w),
                        Text(
                          _startDate != null 
                              ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                              : '시작일',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text('~', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(false),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16.sp, color: Color(0xFFFFB74D)),
                        SizedBox(width: 8.w),
                        Text(
                          _endDate != null 
                              ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                              : '종료일',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // 댓글 수 범위
          Text(
            '댓글 수: ${_commentRange.start.round()} - ${_commentRange.end.round()}',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextColor(context),
            ),
          ),
          RangeSlider(
            values: _commentRange,
            min: 0,
            max: 1000,
            divisions: 50,
            activeColor: Color(0xFFFFB74D),
            onChanged: (RangeValues values) {
              setState(() {
                _commentRange = values;
              });
            },
            onChangeEnd: (RangeValues values) {
              _applyFilters();
            },
          ),
          
          SizedBox(height: 16.h),
          
          // 필터 초기화 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Color(0xFF374151) : Colors.grey[200],
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('필터 초기화', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFB74D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('적용', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.03, end: 0, duration: 400.ms);
  }

  Widget _buildHistoryList() {
    final bool isDark = AppTheme.isDark(context);
    
    if (_filteredRooms.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
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
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 리스트 아이템들 (헤더 제거)
          ...List.generate(_filteredRooms.length, (index) {
            final room = _filteredRooms[index];
            final isLast = index == _filteredRooms.length - 1 && !_isLoadingMore;
            return _buildSimpleHistoryItem(room, isLast, index);
          }),
          
          // 로딩 더보기
          if (_isLoadingMore)
            Container(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
                ),
              ),
            ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.03, end: 0, duration: 600.ms);
  }

  Widget _buildHistoryItem(DiscussionRoom room, bool isLast, int index) {
    final bool isDark = AppTheme.isDark(context);
    final String category = room.category ?? '기타';
    final Color categoryColor = _getCategoryColor(category);
    final int totalReactions = (room.positive_count ?? 0) + (room.neutral_count ?? 0) + (room.negative_count ?? 0);
    final String timeAgo = _getTimeAgo(room.closed_at ?? room.updated_at ?? DateTime.now());
    final String duration = _getDuration(room.created_at, room.closed_at ?? room.updated_at ?? DateTime.now());
    
    return Container(
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
          onTap: () => context.push('/discussion/${room.id}'),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 번째 줄: 카테고리 + 제목
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        room.keyword,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 종료 상태 표시
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '종료',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // 두 번째 줄: 요약 (있는 경우)
                if (room.comment_summary != null && room.comment_summary!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      room.comment_summary!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                // 세 번째 줄: 통계 정보
                Row(
                  children: [
                    _buildStatChip(
                      Icons.chat_bubble_outline,
                      '${room.comment_count ?? 0}',
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                    SizedBox(width: 12.w),
                    _buildStatChip(
                      Icons.people_outline,
                      '$totalReactions',
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                    SizedBox(width: 12.w),
                    _buildStatChip(
                      Icons.schedule_outlined,
                      duration,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                    Spacer(),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSimpleHistoryItem(DiscussionRoom room, bool isLast, int index) {
    final bool isDark = AppTheme.isDark(context);
    final String category = room.category ?? '기타';
    final Color categoryColor = _getCategoryColor(category);
    final int totalReactions = (room.positive_count ?? 0) + (room.neutral_count ?? 0) + (room.negative_count ?? 0);
    final String timeAgo = _getTimeAgo(room.closed_at ?? room.updated_at ?? DateTime.now());
    
    return Container(
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
          onTap: () => context.push('/discussion/${room.id}'),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                // 카테고리 컬러 인디케이터
                Container(
                  width: 3.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 카테고리 태그
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 토론방 제목
                Expanded(
                  child: Text(
                    room.keyword,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 통계 정보 (댓글 수)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 12.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${room.comment_count ?? 0}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: 12.w),
                
                // 시간
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // 화살표 아이콘
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.sp,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB74D).withOpacity(0.1), Color(0xFFFF9800).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.search_off_outlined,
              size: 48.sp,
              color: Color(0xFFFFB74D),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '다른 키워드나 필터 조건으로 검색해보세요',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFB74D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('필터 초기화'),
          ),
        ],
      ),
    );
  }

  // 헬퍼 메서드들
  Color _getCategoryColor(String category) {
    switch (category) {
      case '정치': return Color(0xFF2196F3);
      case '경제': return Color(0xFF4CAF50);
      case '사회': return Color(0xFFFF9800);
      case '문화': return Color(0xFF9C27B0);
      case '스포츠': return Color(0xFFF44336);
      case '국제': return Color(0xFF607D8B);
      case '과학': return Color(0xFF00BCD4);
      default: return Color(0xFF795548);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}년 전';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    
    if (duration.inDays > 0) {
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간';
    } else {
      return '${duration.inMinutes}분';
    }
  }

  String _getSortDisplayName(String sortOption) {
    switch (sortOption) {
      case 'newest': return '최신순';
      case 'oldest': return '오래된순';
      case 'popular': return '인기순';
      case 'active': return '활발한순';
      default: return '최신순';
    }
  }

  String _getSortOptionFromDisplay(String displayName) {
    switch (displayName) {
      case '최신순': return 'newest';
      case '오래된순': return 'oldest';
      case '인기순': return 'popular';
      case '활발한순': return 'active';
      default: return 'newest';
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = '전체';
      _selectedPeriod = '전체';
      _sortOption = 'newest';
      _startDate = null;
      _endDate = null;
      _commentRange = RangeValues(0, 1000);
      _participantRange = RangeValues(0, 500);
    });
    _applyFilters();
  }
}