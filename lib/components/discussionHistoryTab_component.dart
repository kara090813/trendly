import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
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
  
  // Infinite scroll state
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20; // API가 20개씩 반환
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  int _totalItems = 0;
  
  // Category and count management
  List<String> _categories = ['전체'];
  Map<String, int> _categoryCounts = {}; // 필터링된 카테고리별 개수
  int _totalHistoryCount = 0; // 전체 히스토리 개수 (타이틀용)
  
  
  // Removed timeline grouping for flat list display
  
  // Focus management for accessibility
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _searchFocusNode = FocusNode();
    
    _loadHistoryData();
    
    // 무한 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);
    
    _searchController.addListener(() {
      _debounceSearch();
    });
    
    // Add accessibility announcements for focus changes
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && mounted) {
        SemanticsService.announce(
          '검색창이 활성화되었습니다. 토론 제목으로 검색할 수 있습니다.',
          TextDirection.ltr,
        );
      }
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  String _generateCacheKey() {
    return _filterState.generateCacheKey();
  }
  
  void _processSearchResult(dynamic result, {bool fromCache = false, bool isLoadMore = false}) {
    List<DiscussionRoom> rooms;
    
    // API 응답 형태에 따라 처리
    if (result is Map<String, dynamic>) {
      // API 서비스가 이미 DiscussionRoom 객체를 반환하므로 그대로 사용
      rooms = (result['results'] as List<DiscussionRoom>);
      final totalItems = result['total_count'] ?? 0;
      final hasNext = result['has_next'] ?? false;
      
      setState(() {
        if (isLoadMore) {
          _allHistoryRooms.addAll(rooms);
          _filteredRooms.addAll(rooms);
        } else {
          _allHistoryRooms = rooms;
          _filteredRooms = List.from(rooms);
        }
        _totalItems = totalItems;
        _hasMoreData = hasNext;
        _isLoadingMore = false;
      });
    } else if (result is List) {
      // 기존 API 형태 (LiveTab과 같은 방식)
      rooms = result.cast<DiscussionRoom>();
      
      // API가 20개를 반환하므로, 반환된 개수가 20개 미만이면 더 이상 데이터가 없음
      final hasMore = rooms.length == _pageSize;
      
      setState(() {
        if (isLoadMore) {
          _allHistoryRooms.addAll(rooms);
          _filteredRooms.addAll(rooms);
        } else {
          _allHistoryRooms = rooms;
          _filteredRooms = List.from(rooms);
        }
        _hasMoreData = hasMore;
        _isLoadingMore = false;
      });
    }
  }

  // 무한 스크롤 리스너 (LiveTab 방식 참고)
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }
  
  // 추가 데이터 로드 (LiveTab 방식 참고)
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      _currentPage++;
      dynamic historyData;
      
      // 고급 필터가 있는지 확인
      final postFilters = _filterState.toPostFilters();
      final hasAdvancedFilters = postFilters.isNotEmpty;
      
      if (hasAdvancedFilters) {
        // POST 방식으로 고급 필터 적용
        historyData = await _apiService.getClosedDiscussionRoomsWithFilters(
          sort: _filterState.sortOption,
          page: _currentPage,
          category: _filterState.selectedCategory == '전체' ? 'all' : _filterState.selectedCategory,
          filters: postFilters,
        );
      } else {
        // GET 방식으로 기본 조회
        historyData = await _apiService.getClosedDiscussionRooms(
          sort: _filterState.sortOption,
          page: _currentPage,
          category: _filterState.selectedCategory == '전체' ? 'all' : _filterState.selectedCategory,
        );
      }
      
      // Cache the result
      final cacheKey = _generateCacheKey();
      await _cacheService.cacheHistoryData(cacheKey, historyData);
      
      _processSearchResult(historyData, isLoadMore: true);
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--; // 실패 시 페이지 되돌리기
        });
      }
    }
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
    // 검색 시 첫 페이지로 리셋
    _currentPage = 1;
    _hasMoreData = true;
    _isLoadingMore = false;
    
    // Check cache first
    final cacheKey = _generateCacheKey();
    final cachedResult = await _cacheService.getHistoryData(cacheKey);
    
    if (cachedResult != null) {
      setState(() {
        _allHistoryRooms.clear();
        _filteredRooms.clear();
      });
      _processSearchResult(cachedResult, fromCache: true);
      return;
    }
    
    // 검색 상태만 즉시 업데이트하고 데이터는 별도로 로드
    setState(() {
      _allHistoryRooms.clear();
      _filteredRooms.clear();
    });
    await _loadHistoryWithFilters();
  }


  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
      _isLoadingMore = false;
      _allHistoryRooms = [];
      _filteredRooms = [];
      _totalItems = 0;
    });

    try {
      // 병렬로 카테고리 목록, 전체 개수, 첫 페이지 데이터 로드
      final results = await Future.wait([
        _apiService.getDiscussionCategories(),
        _apiService.getClosedDiscussionTotalCount(),
        _loadHistoryWithFilters(),
        _preloadAggregations(),
      ]);
      
      final categories = results[0] as List<String>;
      final totalCount = results[1] as int;
      
      // 전체 히스토리 개수 설정
      _totalHistoryCount = totalCount;
      
      // 카테고리별 카운트 로드 (병렬 처리)
      await _loadCategoryCounts(categories);

      if (mounted) {
        // 실제 데이터가 있는 카테고리만 표시 - LiveTab 방식
        final categoriesWithData = CategoryColors.primaryCategories
            .where((category) => categories.contains(category) && (_categoryCounts[category] ?? 0) > 0)
            .toList();
        final finalCategories = ['전체', ...categoriesWithData];
        
        setState(() {
          _categories = finalCategories;
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
  
  /// 전체 히스토리 개수 로드 (타이틀용)
  Future<void> _loadTotalHistoryCount() async {
    try {
      final count = await _apiService.getClosedDiscussionTotalCount();
      if (mounted) {
        setState(() {
          _totalHistoryCount = count;
        });
      }
    } catch (e) {
      // 오류 시 기본값 사용
      if (mounted) {
        setState(() {
          _totalHistoryCount = 1000;
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
      Map<String, dynamic> historyData;
      
      // 고급 필터가 있는지 확인
      final postFilters = _filterState.toPostFilters();
      final hasAdvancedFilters = postFilters.isNotEmpty;
      
      final category = _filterState.selectedCategory == '전체' ? 'all' : _filterState.selectedCategory;
      
      print('Loading history with filters:');
      print('  - sort: ${_filterState.sortOption}');
      print('  - page: $_currentPage');
      print('  - category: $category (original: ${_filterState.selectedCategory})');
      print('  - hasAdvancedFilters: $hasAdvancedFilters');
      
      if (hasAdvancedFilters) {
        // POST 방식으로 고급 필터 적용
        historyData = await _apiService.getClosedDiscussionRoomsWithFilters(
          sort: _filterState.sortOption,
          page: _currentPage,
          category: category,
          filters: postFilters,
        );
      } else {
        // GET 방식으로 기본 조회
        historyData = await _apiService.getClosedDiscussionRooms(
          sort: _filterState.sortOption,
          page: _currentPage,
          category: category,
        );
      }
      
      // Cache the result
      final cacheKey = _generateCacheKey();
      await _cacheService.cacheHistoryData(cacheKey, historyData);
      
      _processSearchResult(historyData);
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error in _loadHistoryWithFilters: $e');
      // Fallback to existing API
      await _loadHistoryRoomsFallback();
    }
  }

  Future<void> _loadHistoryRoomsFallback() async {
    try {
      final historyData = await _apiService.getClosedDiscussionRooms(
        sort: _filterState.sortOption,
        page: _currentPage,
        category: _filterState.selectedCategory == '전체' ? 'all' : _filterState.selectedCategory,
      );
      
      // historyData는 Map<String, dynamic> 타입이므로 그대로 사용
      _processSearchResult(historyData);
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      throw Exception('히스토리 룸 로드 실패: $e');
    }
  }

  // _loadCategories 메서드는 이제 _loadHistoryData에 통합되어 제거됨

  /// 현재 필터 조건에 따른 카테고리별 개수 로드
  Future<void> _loadCategoryCounts(List<String> categories) async {
    try {
      // 현재 필터 상태에 따른 POST 필터 생성
      final postFilters = _filterState.toPostFilters();
      
      print('Loading category counts with filters: $postFilters');
      
      // 새로운 필터링된 카테고리 개수 API 호출
      final counts = await _apiService.getClosedDiscussionCategoryCounts(
        filters: postFilters.isNotEmpty ? postFilters : null,
      );
      
      print('Received category counts: $counts');
      
      if (mounted) {
        setState(() {
          _categoryCounts = counts;
        });
      }
    } catch (e) {
      print('Error loading category counts: $e');
      // 오류 시 빈 맵 사용 (0개 카테고리는 표시하지 않음)
      if (mounted) {
        setState(() {
          _categoryCounts = {'전체': _totalHistoryCount}; // 전체만 유지
        });
      }
    }
  }


  // Removed _loadMoreData as we're using pagination instead of infinite scroll

  // Removed timeline grouping function

  Future<void> _applyAdvancedFilters() async {
    print('🔍 Advanced filters applied: ${_filterState.toApiFilters()}');
    
    // 페이지와 로딩 상태 초기화
    _currentPage = 1;
    _hasMoreData = true;
    _isLoadingMore = false;
    
    // 필터 상태만 즉시 업데이트하고 데이터는 별도로 로드
    setState(() {});
    _loadFilteredHistoryRooms();
  }
  
  // 필터 변경시에만 토론방 데이터를 다시 로드 (LiveTab 방식)
  Future<void> _loadFilteredHistoryRooms() async {
    try {
      Map<String, dynamic> historyData;
      
      // 고급 필터가 있는지 확인
      final postFilters = _filterState.toPostFilters();
      final hasAdvancedFilters = postFilters.isNotEmpty;
      
      final category = _filterState.selectedCategory == '전체' ? 'all' : _filterState.selectedCategory;
      
      if (hasAdvancedFilters) {
        // POST 방식으로 고급 필터 적용
        historyData = await _apiService.getClosedDiscussionRoomsWithFilters(
          sort: _filterState.sortOption,
          page: _currentPage,
          category: category,
          filters: postFilters,
        );
      } else {
        // GET 방식으로 기본 조회
        historyData = await _apiService.getClosedDiscussionRooms(
          sort: _filterState.sortOption,
          page: _currentPage,
          category: category,
        );
      }
      
      // Cache the result
      final cacheKey = _generateCacheKey();
      await _cacheService.cacheHistoryData(cacheKey, historyData);
      
      // 카테고리 개수도 업데이트하고 0개인 카테고리는 필터링
      _apiService.getClosedDiscussionCategoryCounts(
        filters: postFilters,
      ).then((categoryCounts) {
        if (mounted) {
          // 실제 데이터가 있는 카테고리만 표시
          final categoriesWithData = CategoryColors.primaryCategories
              .where((category) => (categoryCounts[category] ?? 0) > 0)
              .toList();
          final finalCategories = ['전체', ...categoriesWithData];
          
          setState(() {
            _categoryCounts = categoryCounts;
            _categories = finalCategories;
          });
        }
      });
      
      if (mounted) {
        _processSearchResult(historyData);
        setState(() {
          _error = null; // 성공시 에러 초기화
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '히스토리 데이터를 불러오는 중 오류가 발생했습니다: $e';
        });
      }
    }
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
            _filterState = newFilter;
            _currentPage = 1;
            _hasMoreData = true;
            _isLoadingMore = false;
            
            // 필터 상태만 즉시 업데이트하고 데이터는 별도로 로드
            setState(() {});
            _loadFilteredHistoryRooms();
          },
          onReset: () {
            _filterState = const HistoryFilterState();
            _currentPage = 1;
            _hasMoreData = true;
            _isLoadingMore = false;
            
            // 필터 상태만 즉시 업데이트하고 데이터는 별도로 로드
            setState(() {});
            _loadFilteredHistoryRooms();
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
              
              
              // 하단 여백
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        ),
        
        // 스크롤 위로 가기 플로팅 버튼
        Positioned(
          bottom: 24.h,
          right: 24.w,
          child: _buildScrollToTopButton(),
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
                      '총 ${_totalHistoryCount}건',
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
                    if (_filterState.sortOption == value) return; // 같은 정렬이면 무시
                    
                    _filterState = _filterState.copyWith(sortOption: value);
                    _currentPage = 1;
                    _hasMoreData = true;
                    _isLoadingMore = false;
                    
                    // 정렬 상태만 즉시 업데이트하고 데이터는 별도로 로드
                    setState(() {});
                    _loadFilteredHistoryRooms();
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'newest',
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 18.sp),
                          SizedBox(width: 12.w),
                          Text('최신순'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'oldest',
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 18.sp),
                          SizedBox(width: 12.w),
                          Text('오래된순'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'popular',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, size: 18.sp),
                          SizedBox(width: 12.w),
                          Text('인기순'),
                        ],
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Color(0xFF2A2A36).withOpacity(0.6)
                        : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                            ? Colors.black.withOpacity(0.2)
                            : Color(0xFF6366F1).withOpacity(0.06),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 16.sp,
                          color: Color(0xFF6366F1),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _getSortDisplayName(_filterState.sortOption),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.sp,
                          color: AppTheme.getTextColor(context).withOpacity(0.5),
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
          
          // 카테고리 필터 (가로 스크롤) - LiveTab 스타일
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
                        if (_filterState.selectedCategory == category) return; // 같은 카테고리면 무시
                        
                        _filterState = _filterState.copyWith(selectedCategory: category);
                        _currentPage = 1;
                        _hasMoreData = true;
                        _isLoadingMore = false;
                        
                        // 필터 상태만 즉시 업데이트하고 데이터는 별도로 로드
                        setState(() {});
                        _loadFilteredHistoryRooms();
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], // History 탭용 보라색 그라데이션
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
    
    return Semantics(
      label: '토론방 검색',
      hint: '토론 제목으로 검색할 수 있습니다',
      textField: true,
      child: Container(
        margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: AnimatedBuilder(
          animation: _searchFocusNode,
          builder: (context, child) {
            final hasFocus = _searchFocusNode.hasFocus;
            return Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: isDark 
                  ? Color(0xFF2A2A36).withOpacity(0.6)
                  : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(
                  color: hasFocus 
                    ? Color(0xFF6366F1).withOpacity(0.6)
                    : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.black.withOpacity(0.3)
                      : Color(0xFF6366F1).withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  if (hasFocus)
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.15),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Search icon with animation
                  Container(
                    width: 52.w,
                    height: 52.h,
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.search_rounded,
                          color: hasFocus 
                            ? Color(0xFF6366F1)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: hasFocus ? 24.sp : 22.sp,
                        ),
                      ),
                    ),
                  ),
                  // TextField
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      autofillHints: const [AutofillHints.name],
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '토론 제목으로 검색',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(right: 8.w),
                      ),
                      onSubmitted: (value) {
                        // Announce search results to screen readers
                        final resultCount = _filteredRooms.length;
                        SemanticsService.announce(
                          '$resultCount개의 검색 결과가 있습니다',
                          TextDirection.ltr,
                        );
                      },
                      onChanged: (value) {
                        // Debounced search already handled by listener
                      },
                    ),
                  ),
                  // Action buttons container - 고정 너비로 오버플로 방지
                  Container(
                    width: 96.w, // 고정 너비: x버튼(44w) + 필터버튼(44w) + 여백(8w)
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Clear button - 애니메이션으로 나타나고 사라짐
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: _filterState.searchQuery.isNotEmpty ? 44.w : 0,
                          child: _filterState.searchQuery.isNotEmpty
                              ? Semantics(
                                  button: true,
                                  label: '검색어 지우기',
                                  hint: '검색 필드를 비웁니다',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        _searchController.clear();
                                        _filterState = _filterState.copyWith(searchQuery: '');
                                        _currentPage = 1;
                                        _hasMoreData = true;
                                        _isLoadingMore = false;
                                        
                                        // 검색 상태만 즉시 업데이트하고 데이터는 별도로 로드
                                        setState(() {});
                                        _loadFilteredHistoryRooms();
                                        
                                        SemanticsService.announce(
                                          '검색어가 지워졌습니다',
                                          TextDirection.ltr,
                                        );
                                        _searchFocusNode.requestFocus();
                                      },
                                      borderRadius: BorderRadius.circular(24.r),
                                      child: Container(
                                        width: 44.w,
                                        height: 44.h,
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: Duration(milliseconds: 150),
                                            child: Icon(
                                              Icons.clear_rounded,
                                              key: ValueKey('clear'),
                                              size: 20.sp,
                                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                        // 간격 조정
                        if (_filterState.searchQuery.isNotEmpty) SizedBox(width: 4.w),
                        // Filter button - 항상 표시
                        Semantics(
                          button: true,
                          label: '필터 옵션 열기',
                          hint: '추가 필터 옵션을 설정합니다',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showSimpleFilter,
                              borderRadius: BorderRadius.circular(24.r),
                              child: Container(
                                width: 44.w,
                                height: 44.h,
                                child: Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        size: 22.sp,
                                        color: _hasActiveFilters() 
                                          ? Color(0xFF10B981)
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      ),
                                      if (_hasActiveFilters())
                                        Positioned(
                                          right: 10.w,
                                          top: 10.h,
                                          child: Container(
                                            width: 6.w,
                                            height: 6.h,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            );
          },
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .slideY(begin: 0.03, end: 0, duration: 600.ms);
  }

  // Build flat history list like posts
  Widget _buildNaturalHistoryList() {
    final bool isDark = AppTheme.isDark(context);
    
    return SliverToBoxAdapter(
      child: Container(
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
        child: _filteredRooms.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  ..._filteredRooms.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final DiscussionRoom room = entry.value;
                    final isLast = index == _filteredRooms.length - 1;
                    return _buildFlatHistoryItem(room, index);
                  }),
                  // 추가 로딩 인디케이터 추가 (LiveTab 방식)
                  if (_isLoadingMore)
                    _buildLoadingMoreIndicator(),
                ],
              ),
      ).animate()
          .fadeIn(duration: 600.ms, delay: 600.ms)
          .slideY(begin: 0.03, end: 0, duration: 600.ms),
    );
  }

  // Create flat history item like a post
  Widget _buildFlatHistoryItem(DiscussionRoom room, int index) {
    final bool isDark = AppTheme.isDark(context);
    final String category = room.category ?? '기타';
    final Color categoryColor = CategoryColors.getCategoryColor(category);
    final int totalReactions = (room.positive_count ?? 0) + (room.neutral_count ?? 0) + (room.negative_count ?? 0);
    final bool isLast = index == _filteredRooms.length - 1;
    
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
                
                // 토론방 제목 (메인 컨텐츠)
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
                
                // 반응 수
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 12.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '$totalReactions',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: 12.w),
                
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

  // 추가 로딩 인디케이터 (LiveTab 방식 참고)
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        children: [
          // Animated search icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF6366F1).withOpacity(0.1 * value),
                        Color(0xFF6366F1).withOpacity(0.05 * value),
                        Colors.transparent,
                      ],
                      radius: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 48.sp,
                      color: Color(0xFF6366F1).withOpacity(0.6 + (0.4 * value)),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: 12.h),
          Text(
            _filterState.searchQuery.isNotEmpty 
              ? '"${_filterState.searchQuery}"에 대한 결과를 찾을 수 없습니다'
              : '다른 키워드나 카테고리로 검색해보세요',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextColor(context).withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          SizedBox(height: 24.h),
          // Suggestion chips
          if (_filterState.searchQuery.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildSuggestionChip('필터 초기화', Icons.refresh_rounded, () {
                  _filterState = const HistoryFilterState();
                  _searchController.clear();
                  _currentPage = 1;
                  _hasMoreData = true;
                  _isLoadingMore = false;
                  
                  // 필터 상태만 즉시 업데이트하고 데이터는 별도로 로드
                  setState(() {});
                  _loadFilteredHistoryRooms();
                }),
                _buildSuggestionChip('카테고리 변경', Icons.category_rounded, () {
                  // Scroll to category filter
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  );
                }),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label, IconData icon, VoidCallback onTap) {
    final bool isDark = AppTheme.isDark(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark 
              ? Color(0xFF2A2A36).withOpacity(0.4)
              : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Color(0xFF6366F1).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: Color(0xFF6366F1),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),
        ),
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
  

  String _getSortDisplayName(String sortOption) {
    switch (sortOption) {
      case 'newest': return '최신순';
      case 'oldest': return '오래된순';
      case 'popular': return '인기순';
      default: return '최신순';
    }
  }

  bool _hasActiveFilters() {
    return _filterState.selectedCategory != '전체' || 
           _filterState.sortOption != 'newest' ||
           _filterState.searchQuery.isNotEmpty;
  }
  
  // 스크롤 위로 가기 플로팅 버튼
  Widget _buildScrollToTopButton() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        // 스크롤 위치가 200 이상일 때만 표시
        final showButton = _scrollController.hasClients && 
                          _scrollController.offset > 200;
        
        return AnimatedOpacity(
          opacity: showButton ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: AnimatedScale(
            scale: showButton ? 1.0 : 0.8,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: showButton ? _scrollToTop : null,
                  borderRadius: BorderRadius.circular(28.r),
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 스크롤 위로 이동 기능
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }
  }
}