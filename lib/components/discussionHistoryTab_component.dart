import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../services/api_cache_service.dart';
import '../widgets/discussion_filter_widget.dart';
import '../models/filter_state_model.dart';
import '../funcs/category_colors.dart';

class DiscussionHistoryTabComponent extends StatefulWidget{
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
  // Removed _isLoadingMore as we use pagination
  String? _error;
  late AnimationController _floatingController;
  
  // Enhanced state management
  final ApiCacheService _cacheService = ApiCacheService();
  HistoryFilterState _filterState = HistoryFilterState();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  // Pagination state
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _itemsPerPage = 20; // Match LiveTab pattern
  bool _hasMoreData = true;
  int _totalPages = 1;
  int _totalItems = 0;
  
  // Advanced filtering - removed, now using simple filter only
  List<String> _categories = ['전체'];
  Map<String, int> _categoryCounts = {};
  
  // Performance tracking
  DateTime? _lastQueryTime;
  int _totalQueries = 0;
  
  // Removed timeline grouping for flat list display
  
  // Focus management for accessibility
  late FocusNode _paginationFocusNode;
  final TextEditingController _jumpPageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _paginationFocusNode = FocusNode();
    
    _loadHistoryData();
    
    _searchController.addListener(() {
      _debounceSearch();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _paginationFocusNode.dispose();
    _jumpPageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  String _generateCacheKey() {
    return _filterState.generateCacheKey();
  }
  
  void _processSearchResult(Map<String, dynamic> result, {bool fromCache = false}) {
    final rooms = (result['data'] as List<dynamic>)
        .map((json) => DiscussionRoom.fromJson(json))
        .toList();
    
    final pagination = result['pagination'] ?? {};
    final totalItems = pagination['total_items'] ?? 0;
    final totalPages = pagination['total_pages'] ?? 1;
    
    setState(() {
      _allHistoryRooms = rooms;
      _filteredRooms = List.from(rooms);
      _totalItems = totalItems;
      _totalPages = totalPages;
      _hasMoreData = _currentPage < _totalPages;
    });
    
    // No need to group rooms anymore
    
    // Cache hit logged internally
  }

  // Navigation methods for pagination
  Future<void> _goToPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    
    setState(() {
      _currentPage = page;
      _isLoading = true;
    });
    
    await _loadHistoryWithFilters();
    
    // Scroll to top for better UX
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _goToNextPage() async {
    if (_hasMoreData) {
      await _goToPage(_currentPage + 1);
    }
  }
  
  Future<void> _goToPreviousPage() async {
    if (_currentPage > 1) {
      await _goToPage(_currentPage - 1);
    }
  }
  
  Future<void> _goToFirstPage() async {
    await _goToPage(1);
  }
  
  Future<void> _goToLastPage() async {
    await _goToPage(_totalPages);
  }
  
  void _handleJumpToPage(String input) {
    final page = int.tryParse(input.trim());
    if (page != null && page >= 1 && page <= _totalPages) {
      _goToPage(page);
    } else {
      // Show error message for invalid page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('올바른 페이지 번호를 입력하세요 (1-$_totalPages)'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _jumpPageController.clear();
  }

  // Enhanced search with debouncing and caching
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final query = _searchController.text.trim();
        if (query != _filterState.searchQuery) {
          setState(() {
            _filterState = _filterState.copyWith(searchQuery: query);
          });
          _performSearch();
        }
      }
    });
  }

  Future<void> _performSearch() async {
    _totalQueries++;
    _lastQueryTime = DateTime.now();
    
    // Check cache first
    final cacheKey = _generateCacheKey();
    final cachedResult = await _cacheService.getHistoryData(cacheKey);
    
    if (cachedResult != null) {
      _processSearchResult(cachedResult, fromCache: true);
      return;
    }
    
    // Perform API search
    await _loadHistoryWithFilters();
  }


  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
      _allHistoryRooms = [];
      _filteredRooms = [];
      _totalItems = 0;
      _totalPages = 1;
    });

    try {
      // Parallel loading with enhanced error handling
      await Future.wait([
        _loadCategories(),
        _loadHistoryWithFilters(),
        _preloadAggregations(),
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


  Future<void> _preloadAggregations() async {
    try {
      // Preload commonly accessed aggregations
      await _cacheService.preloadStatistics();
    } catch (e) {
      // Aggregation preload failed silently
    }
  }

  Future<void> _loadHistoryWithFilters() async {
    try {
      final historyData = await _apiService.getHistoryWithAdvancedFilters(
        filters: _filterState.toApiFilters(),
        cursor: null, // Use null cursor for page-based
        limit: _itemsPerPage,
      );
      
      final rooms = (historyData['data'] as List<dynamic>)
          .map((json) => DiscussionRoom.fromJson(json))
          .toList();
      
      final pagination = historyData['pagination'] ?? {};
      final totalItems = pagination['total_items'] ?? 0;
      final totalPages = pagination['total_pages'] ?? 1;
      
      // Cache the result
      final cacheKey = _generateCacheKey();
      await _cacheService.cacheHistoryData(cacheKey, historyData);
      
      setState(() {
        _allHistoryRooms = rooms;
        _filteredRooms = List.from(rooms);
        _totalItems = totalItems;
        _totalPages = totalPages;
        _hasMoreData = _currentPage < _totalPages;
        _isLoading = false;
      });
      
      // No need to group rooms anymore
    } catch (e) {
      // Fallback to existing API
      await _loadHistoryRoomsFallback();
    }
  }

  Future<void> _loadHistoryRoomsFallback() async {
    try {
      final closedRooms = await _apiService.getClosedDiscussionRooms(
        sort: _filterState.sortOption,
        page: _currentPage,
        category: _filterState.selectedCategory == '전체' ? 'all' : _filterState.selectedCategory,
      );
      
      // Estimate total pages from returned data
      final estimatedTotal = closedRooms.length < _itemsPerPage 
          ? (_currentPage - 1) * _itemsPerPage + closedRooms.length
          : _currentPage * _itemsPerPage;
      final estimatedPages = (estimatedTotal / _itemsPerPage).ceil();
      
      setState(() {
        _allHistoryRooms = closedRooms;
        _filteredRooms = List.from(closedRooms);
        _totalItems = estimatedTotal;
        _totalPages = estimatedPages;
        _hasMoreData = closedRooms.length == _itemsPerPage;
        _isLoading = false;
      });
      
      // No need to group rooms anymore
    } catch (e) {
      throw Exception('히스토리 룸 로드 실패: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      // API에서 카테고리 목록 가져오기
      final categories = await _apiService.getDiscussionCategories();
      // 카테고리 목록 설정 - 정의된 순서대로 정렬
      final orderedCategories = CategoryColors.primaryCategories
          .where((category) => categories.contains(category))
          .toList();
      final finalCategories = ['전체', ...orderedCategories];
      
      // 카테고리별 카운트 로드 (병렬 처리)
      await _loadCategoryCounts(finalCategories);
      
      if (mounted) {
        setState(() {
          _categories = finalCategories;
        });
      }
    } catch (e) {
      // 카테고리 로드 실패 시 기본값 사용
    }
  }

  Future<void> _loadCategoryCounts(List<String> categories) async {
    final Map<String, int> counts = {};
    
    // 전체 카운트
    try {
      final totalCount = await _apiService.getDiscussionCount(isActive: false, category: 'all');
      counts['전체'] = totalCount;
    } catch (e) {
      counts['전체'] = 0;
    }
    
    // 병렬로 모든 카테고리의 카운트 로드
    final futures = <Future<void>>[];
    
    for (var category in categories) {
      if (category != '전체') {
        futures.add(
          _apiService.getDiscussionCount(isActive: false, category: category).then((count) {
            counts[category] = count;
          }).catchError((e) {
            counts[category] = 0;
          }),
        );
      }
    }
    
    await Future.wait(futures);
    
    if (mounted) {
      setState(() {
        _categoryCounts = counts;
      });
    }
  }


  // Removed _loadMoreData as we're using pagination instead of infinite scroll

  // Removed timeline grouping function

  void _applyAdvancedFilters() {
    // Reset to first page when applying new filters
    setState(() {
      _currentPage = 1;
    });
    
    // Server-side filtering for all datasets
    _loadHistoryWithFilters();
  }

  void _showSimpleFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => DiscussionFilterComponent(
          initialFilter: _filterState,
          onFilterChanged: (newFilter) {
            setState(() {
              _filterState = newFilter;
            });
            _applyAdvancedFilters();
          },
          onReset: () {
            setState(() {
              _filterState = const HistoryFilterState();
            });
            _applyAdvancedFilters();
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
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
            ElevatedButton(onPressed: _loadHistoryData, child: Text('다시 시도')),
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
                          (index == 0 ? Color(0xFF6366F1) : Color(0xFF8B5CF6))
                              .withOpacity(0.2),
                          (index == 0 ? Color(0xFF6366F1) : Color(0xFF8B5CF6))
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
            cacheExtent: 1000.0, // Increased cache for better performance
            slivers: [
              // 히어로 섹션
              SliverToBoxAdapter(
                child: _buildHistoryHeader(),
              ),
              
              // 타임라인 필터 섹션
              SliverToBoxAdapter(
                child: _buildTimelineFilterSection(),
              ),
              
              // 검색바
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              
              
              // 토론방 리스트 - Natural SliverList implementation
              _buildNaturalHistoryList(),
              
              // Pagination navigation
              SliverToBoxAdapter(
                child: _buildPaginationNavigation(),
              ),
              
              // Performance monitor (only in debug mode)
              if (kDebugMode)
                SliverToBoxAdapter(
                  child: _buildPerformanceMonitor(),
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
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.archive_rounded,
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
                      "HISTORY",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "종료된 토론 아카이브",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // 통계 정보
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insights,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '총 ${_categoryCounts['전체'] ?? 0}건',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
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

  Widget _buildTimelineFilterSection() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
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
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "게시글 목록",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor(context),
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
                // 정렬 옵션
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _filterState = _filterState.copyWith(sortOption: value);
                    });
                    _applyAdvancedFilters();
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'newest',
                      child: Text('최신순'),
                    ),
                    PopupMenuItem<String>(
                      value: 'oldest',
                      child: Text('오래된순'),
                    ),
                    PopupMenuItem<String>(
                      value: 'popular',
                      child: Text('인기순'),
                    ),
                    PopupMenuItem<String>(
                      value: 'active',
                      child: Text('활발한순'),
                    ),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort,
                          size: 14.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _getSortDisplayName(_filterState.sortOption),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Padding(
            padding: EdgeInsets.only(left: 40.w),
            child: Text(
              "종료된 토론방을 한눈에 탐색하세요",
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // 카테고리 필터 (가로 스크롤)
          Container(
            height: 40.h,
            margin: EdgeInsets.only(left: 24.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _filterState.selectedCategory;
                
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _filterState = _filterState.copyWith(selectedCategory: category);
                        });
                        _applyAdvancedFilters();
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ) : null,
                          color: isSelected ? null : (isDark ? Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected 
                              ? Colors.transparent
                              : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ] : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (category != '전체')
                              Container(
                                width: 6.w,
                                height: 6.w,
                                margin: EdgeInsets.only(right: 6.w),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : CategoryColors.getCategoryColor(category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected 
                                  ? Colors.white
                                  : AppTheme.getTextColor(context),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${_categoryCounts[category] ?? 0}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                  ? Colors.white.withOpacity(0.8)
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
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
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSearchBar() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
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
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '토론 제목으로 검색...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF6366F1),
            size: 20.sp,
          ),
          suffixIcon: _filterState.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18.sp),
                  color: Colors.grey,
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _filterState = _filterState.copyWith(searchQuery: '');
                    });
                    _applyAdvancedFilters();
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.tune,
                    size: 18.sp,
                    color: Color(0xFF10B981),
                  ),
                  tooltip: '토론방 필터',
                  onPressed: _showSimpleFilter,
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        style: TextStyle(
          color: AppTheme.getTextColor(context),
          fontSize: 14.sp,
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.03, end: 0, duration: 600.ms);
  }

  // Build flat history list like posts
  Widget _buildNaturalHistoryList() {
    if (_filteredRooms.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _filteredRooms.length) return null;
          
          final room = _filteredRooms[index];
          return _buildFlatHistoryItem(room, index);
        },
        childCount: _filteredRooms.length,
      ),
    );
  }

  // Create flat history item like a post
  Widget _buildFlatHistoryItem(DiscussionRoom room, int index) {
    final bool isDark = AppTheme.isDark(context);
    final String category = room.category ?? '기타';
    final Color categoryColor = CategoryColors.getCategoryColor(category);
    final int totalReactions = (room.positive_count ?? 0) + (room.neutral_count ?? 0) + (room.negative_count ?? 0);
    final String timeAgo = _getTimeAgo(room.closed_at ?? room.updated_at ?? DateTime.now());
    
    // Build semantic label for accessibility
    final semanticLabel = '토론방: ${room.keyword}, '
        '카테고리: $category, '
        '댓글 수: ${room.comment_count ?? 0}개, '
        '반응 수: $totalReactions개, '
        '종료 시점: $timeAgo';
    
    return RepaintBoundary(
      key: ValueKey('flat_history_item_${room.id}'),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Semantics(
          button: true,
          enabled: true,
          label: semanticLabel,
          hint: '토론방으로 이동하려면 두 번 탭하세요',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/discussion/${room.id}'),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                constraints: BoxConstraints(minHeight: 44.h),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with category and time
                    Row(
                      children: [
                        // Category tag
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        
                        Spacer(),
                        
                        // Time ago
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Title
                    Semantics(
                      header: true,
                      child: Text(
                        room.keyword,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Stats row
                    Row(
                      children: [
                        // Comments
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 16.sp,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '댓글 ${room.comment_count ?? 0}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: 16.w),
                        
                        // Reactions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16.sp,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '반응 $totalReactions',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        
                        Spacer(),
                        
                        // Arrow indicator
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.02, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  // Removed old timeline-based history item

  Widget _buildEmptyState() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
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
                colors: [Color(0xFF6366F1).withOpacity(0.1), Color(0xFF4F46E5).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.search_off_outlined,
              size: 48.sp,
              color: Color(0xFF6366F1),
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
            '다른 키워드나 카테고리로 검색해보세요',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 헬퍼 메서드들
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

  // Removed virtual scroll implementation in favor of natural pagination
  
  Widget _buildPerformanceMonitor() {
    if (!kDebugMode) return const SizedBox.shrink();
    
    final metrics = _cacheService.getMetrics();
    
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          _buildMetricRow('Total Items', _allHistoryRooms.length.toString()),
          _buildMetricRow('Filtered Items', _filteredRooms.length.toString()),
          _buildMetricRow('Pagination Mode', 'ENABLED'),
          _buildMetricRow('Cache Hits', metrics['cache_hits'].toString()),
          _buildMetricRow('Cache Hit Ratio', '${(metrics['hit_ratio'] * 100).toStringAsFixed(1)}%'),
          _buildMetricRow('Total Queries', _totalQueries.toString()),
          if (_lastQueryTime != null)
            _buildMetricRow('Last Query', '${DateTime.now().difference(_lastQueryTime!).inMilliseconds}ms ago'),
        ],
      ),
    );
  }
  
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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

  // Accessible pagination navigation component
  Widget _buildPaginationNavigation() {
    if (_totalPages <= 1) return SizedBox.shrink();
    
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      padding: EdgeInsets.all(16.w),
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
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Focus(
        focusNode: _paginationFocusNode,
        onKeyEvent: _handlePaginationKeyEvent,
        child: Column(
          children: [
            // Page information with live region for screen readers
            Semantics(
              liveRegion: true,
              label: '현재 $_currentPage페이지, 총 $_totalPages페이지 중 $_totalItems건',
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  '$_currentPage / $_totalPages 페이지 (총 $_totalItems건)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First page button
                _buildPaginationButton(
                  onPressed: _currentPage > 1 ? _goToFirstPage : null,
                  icon: Icons.first_page,
                  label: '첫 페이지',
                ),
                
                SizedBox(width: 8.w),
                
                // Previous page button
                _buildPaginationButton(
                  onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                  icon: Icons.chevron_left,
                  label: '이전 페이지',
                ),
                
                SizedBox(width: 16.w),
                
                // Page numbers
                ..._buildPageNumbers(),
                
                SizedBox(width: 16.w),
                
                // Next page button
                _buildPaginationButton(
                  onPressed: _hasMoreData ? _goToNextPage : null,
                  icon: Icons.chevron_right,
                  label: '다음 페이지',
                ),
                
                SizedBox(width: 8.w),
                
                // Last page button
                _buildPaginationButton(
                  onPressed: _hasMoreData ? _goToLastPage : null,
                  icon: Icons.last_page,
                  label: '마지막 페이지',
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Jump to page functionality
            _buildJumpToPage(),
            
            SizedBox(height: 8.h),
            
            // Accessibility guide
            _buildAccessibilityGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    final bool isDark = AppTheme.isDark(context);
    final bool isEnabled = onPressed != null;
    
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: Container(
        width: 44.w,
        height: 44.w,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              decoration: BoxDecoration(
                color: isEnabled 
                    ? (isDark ? Color(0xFF334155) : Color(0xFFF1F5F9))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    isEnabled ? 0.2 : 0.1
                  ),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: isEnabled
                    ? AppTheme.getTextColor(context)
                    : (isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final visiblePages = _calculateVisiblePages();
    final widgets = <Widget>[];
    
    for (int i = 0; i < visiblePages.length; i++) {
      final page = visiblePages[i];
      final isCurrentPage = page == _currentPage;
      
      widgets.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: _buildPageNumberButton(page, isCurrentPage),
        ),
      );
      
      // Add ellipsis if there's a gap
      if (i < visiblePages.length - 1 && visiblePages[i + 1] - page > 1) {
        widgets.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '...',
              style: TextStyle(
                color: AppTheme.getTextColor(context).withOpacity(0.5),
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildPageNumberButton(int page, bool isCurrentPage) {
    final bool isDark = AppTheme.isDark(context);
    
    return Semantics(
      button: true,
      selected: isCurrentPage,
      label: isCurrentPage ? '현재 페이지 $page' : '$page페이지로 이동',
      child: Container(
        width: 44.w,
        height: 44.w,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCurrentPage ? null : () => _goToPage(page),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentPage 
                    ? Color(0xFF6366F1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isCurrentPage 
                      ? Color(0xFF6366F1)
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isCurrentPage 
                        ? FontWeight.w700 
                        : FontWeight.w500,
                    color: isCurrentPage 
                        ? Colors.white
                        : AppTheme.getTextColor(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<int> _calculateVisiblePages() {
    const maxVisible = 5;
    final start = math.max(1, _currentPage - 2);
    final end = math.min(_totalPages, start + maxVisible - 1);
    
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _buildJumpToPage() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '페이지로 이동:',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextColor(context),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          Container(
            width: 80.w,
            child: Semantics(
              textField: true,
              label: '이동할 페이지 번호 입력',
              hint: '1부터 $_totalPages까지 입력 가능',
              child: TextField(
                controller: _jumpPageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: '페이지',
                  hintStyle: TextStyle(fontSize: 12.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w, 
                    vertical: 8.h,
                  ),
                ),
                onSubmitted: _handleJumpToPage,
              ),
            ),
          ),
          
          SizedBox(width: 8.w),
          
          Semantics(
            button: true,
            label: '입력한 페이지로 이동',
            child: ElevatedButton(
              onPressed: () => _handleJumpToPage(_jumpPageController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                minimumSize: Size(44.w, 44.h), // Minimum touch target
              ),
              child: Text(
                '이동',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityGuide() {
    final bool isDark = AppTheme.isDark(context);
    
    return Semantics(
      label: '페이지 네비게이션 키보드 단축키 안내',
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '키보드 단축키:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 4.h),
            _buildShortcutItem('←/→', '이전/다음 페이지'),
            _buildShortcutItem('Home/End', '첫/마지막 페이지'),
            _buildShortcutItem('Tab', '다음 요소로 이동'),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutItem(String keys, String description) {
    final bool isDark = AppTheme.isDark(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            description,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.getTextColor(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Handle keyboard events for pagination navigation
  KeyEventResult _handlePaginationKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          if (_currentPage > 1) {
            _goToPreviousPage();
          }
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.arrowRight:
          if (_hasMoreData) {
            _goToNextPage();
          }
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.home:
          _goToFirstPage();
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.end:
          _goToLastPage();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}