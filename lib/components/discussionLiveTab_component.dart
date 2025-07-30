import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../funcs/category_colors.dart';

class DiscussionLiveTabComponent extends StatefulWidget {
  const DiscussionLiveTabComponent({super.key});

  @override
  State<DiscussionLiveTabComponent> createState() => _DiscussionLiveTabComponentState();
}

class _DiscussionLiveTabComponentState extends State<DiscussionLiveTabComponent> 
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<DiscussionRoom> _allLiveRooms = [];
  List<DiscussionRoom> _filteredRooms = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  late AnimationController _floatingController;
  
  // 검색 및 필터링
  String _searchQuery = '';
  String _selectedCategory = '전체';
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = ['전체'];
  Map<String, int> _categoryCounts = {}; // 카테고리별 카운트 저장
  
  // 페이징 관련
  int _currentPage = 1; // API가 0부터 시작
  final int _pageSize = 20; // API가 20개씩 반환
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  
  // 정렬 옵션
  String _sortOption = 'new'; // 'new' or 'pop'

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadLiveRooms();
    _scrollController.addListener(_onScroll);
    
    // 검색 컨트롤러 리스너 추가
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
      // TODO: 검색 기능 구현시 서버 API 호출
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
        _loadMoreRooms();
      }
    }
  }

  Future<void> _loadLiveRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
      _allLiveRooms = [];
      _filteredRooms = [];
    });

    try {
      // 병렬로 카테고리 목록, 전체 카운트, 첫 페이지 데이터 로드
      final results = await Future.wait([
        _apiService.getDiscussionCategories(),
        _apiService.getDiscussionCount(isActive: true, category: 'all'), // 전체 카운트 (category='all')
        _apiService.getActiveDiscussionRooms(
          sort: _sortOption,
          page: _currentPage,
          category: _selectedCategory == '전체' ? 'all' : _selectedCategory,
        ),
      ]);
      
      final categories = results[0] as List<String>;
      final totalCount = results[1] as int;
      final activeRooms = results[2] as List<DiscussionRoom>;
      
      // API가 20개를 반환하므로, 반환된 개수가 20개 미만이면 더 이상 데이터가 없음
      _hasMoreData = activeRooms.length == _pageSize;
      
      // 카테고리 목록 설정 - 정의된 순서대로 정렬
      final orderedCategories = CategoryColors.primaryCategories
          .where((category) => categories.contains(category))
          .toList();
      final finalCategories = ['전체', ...orderedCategories];
      
      // 전체 카운트를 먼저 저장
      _categoryCounts['전체'] = totalCount;
      
      // 나머지 카테고리별 카운트 로드 (병렬 처리)
      await _loadCategoryCounts(finalCategories);

      if (mounted) {
        setState(() {
          _categories = finalCategories;
          _allLiveRooms = activeRooms;
          _filteredRooms = activeRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '실시간 토론방 정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadCategoryCounts(List<String> categories) async {
    final Map<String, int> counts = Map.from(_categoryCounts); // 기존 카운트 복사 (전체 카운트 포함)
    
    // 병렬로 모든 카테고리의 카운트 로드 (전체는 이미 로드했으므로 제외)
    final futures = <Future<void>>[];
    
    for (var category in categories) {
      if (category != '전체') { // 전체는 이미 로드했으므로 스킵
        futures.add(
          _apiService.getDiscussionCount(isActive: true, category: category).then((count) {
            counts[category] = count;
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
  
  Future<void> _loadMoreRooms() async {
    if (!_hasMoreData || _isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      _currentPage++;
      final moreRooms = await _apiService.getActiveDiscussionRooms(
        sort: _sortOption,
        page: _currentPage,
        category: _selectedCategory == '전체' ? 'all' : _selectedCategory,
      );
      
      // API가 20개를 반환하므로, 반환된 개수가 20개 미만이면 더 이상 데이터가 없음
      _hasMoreData = moreRooms.length == _pageSize;
      
      if (mounted) {
        setState(() {
          _allLiveRooms.addAll(moreRooms);
          _filteredRooms.addAll(moreRooms);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--; // 실패시 페이지 번호 복구
        });
      }
    }
  }


  void _onCategoryChanged(String category) {
    if (_selectedCategory == category) return; // 같은 카테고리면 무시
    
    _selectedCategory = category;
    _currentPage = 1;
    _hasMoreData = true;
    _isLoadingMore = false;
    
    // 필터 상태만 즉시 업데이트하고 데이터는 별도로 로드
    setState(() {});
    _loadFilteredRooms();
  }
  
  void _onSortChanged(String sort) {
    if (_sortOption == sort) return; // 같은 정렬이면 무시
    
    _sortOption = sort;
    _currentPage = 1;
    _hasMoreData = true;
    _isLoadingMore = false;
    
    // 정렬 상태만 즉시 업데이트하고 데이터는 별도로 로드
    setState(() {});
    _loadFilteredRooms();
  }

  // 필터 변경시에만 토론방 데이터를 다시 로드
  Future<void> _loadFilteredRooms() async {
    try {
      final rooms = await _apiService.getActiveDiscussionRooms(
        sort: _sortOption,
        page: _currentPage,
        category: _selectedCategory == '전체' ? 'all' : _selectedCategory,
      );
      
      if (mounted) {
        setState(() {
          _allLiveRooms = rooms;
          _filteredRooms = rooms;
          _hasMoreData = rooms.length >= _pageSize;
          _error = null; // 성공시 에러 초기화
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '토론방 정보를 불러오는 중 오류가 발생했습니다: $e';
        });
      }
    }
  }



  int _getCategoryCount(String category) {
    // API로부터 받은 카운트 사용, 없으면 0 반환
    return _categoryCounts[category] ?? 0;
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
            ElevatedButton(onPressed: _loadLiveRooms, child: Text('다시 시도')),
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
        
        RefreshIndicator(
          onRefresh: _loadLiveRooms,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              // 히어로 섹션
              SliverToBoxAdapter(
                child: _buildLiveDiscussionHeader(),
              ),
              
              // 필터 섹션
              SliverToBoxAdapter(
                child: _buildFixedFilterSection(),
              ),
              
              // 토론방 리스트 섹션
              SliverToBoxAdapter(
                child: _buildOptimizedRoomsList(),
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

  // LIVE 토론방 히어로 섹션 - TimeMachine 스타일
  Widget _buildLiveDiscussionHeader() {
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
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.radio_button_checked,
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
                      "LIVE 토론방",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "실시간 진행 중인 토론에 참여하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // LIVE 인디케이터
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'LIVE ${_getCategoryCount('전체')}',
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



  
  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 고정 필터 섹션 (카테고리 + 정렬)
  Widget _buildFixedFilterSection() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 필터 (전체 너비 사용)
          Container(
            height: 40.h,
            margin: EdgeInsets.only(left: 24.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onCategoryChanged(category),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
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
                              color: Color(0xFF10B981).withOpacity(0.3),
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
                              '${_getCategoryCount(category)}',
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
    );
  }

  // 최적화된 토론방 리스트 (스크롤 가능하지만 데이터만 업데이트)
  Widget _buildOptimizedRoomsList() {
    final bool isDark = AppTheme.isDark(context);
    
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
      child: _filteredRooms.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // 리스트 헤더 (정렬 옵션 포함)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? Color(0xFF334155).withOpacity(0.3)
                      : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '토론방 목록',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      Spacer(),
                      PopupMenuButton<String>(
                        onSelected: _onSortChanged,
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'new',
                            child: Row(
                              children: [
                                Icon(Icons.schedule, size: 16.sp, color: Color(0xFF10B981)),
                                SizedBox(width: 8.w),
                                Text('최신순'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'pop',
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, size: 16.sp, color: Color(0xFF10B981)),
                                SizedBox(width: 8.w),
                                Text('인기순'),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sort,
                                size: 14.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _sortOption == 'new' ? '최신순' : '인기순',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 14.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 500))
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.02, end: 0, duration: 600.ms),
                
                // 토론방 아이템들
                ..._filteredRooms.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final DiscussionRoom room = entry.value;
                  final isLast = index == _filteredRooms.length - 1;
                  return _buildCompactPostItem(room, index * 50, isLast);
                }),
                if (_isLoadingMore)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  ),
              ],
            ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.03, end: 0, duration: 600.ms);
  }


  // 완전 컴팩트한 한 줄 토론방 아이템
  Widget _buildCompactPostItem(DiscussionRoom room, int delay, bool isLast) {
    final bool isDark = AppTheme.isDark(context);
    final String category = room.category ?? '기타';
    final Color categoryColor = CategoryColors.getCategoryColor(category);
    final int totalReactions = (room.positive_count ?? 0) + (room.neutral_count ?? 0) + (room.negative_count ?? 0);
    
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
    ).animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981).withOpacity(0.1), Color(0xFF059669).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.forum_outlined,
              size: 48.sp,
              color: Color(0xFF10B981),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '진행 중인 토론방이 없습니다',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '새로운 토론방이 시작되면 알려드릴게요',
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

}