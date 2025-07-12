import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';

class DiscussionLiveTabComponent extends StatefulWidget {
  const DiscussionLiveTabComponent({super.key});

  @override
  State<DiscussionLiveTabComponent> createState() => _DiscussionLiveTabComponentState();
}

class _DiscussionLiveTabComponentState extends State<DiscussionLiveTabComponent> {
  final ApiService _apiService = ApiService();
  List<DiscussionRoom> _allLiveRooms = [];
  List<DiscussionRoom> _filteredRooms = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
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
      
      // 카테고리 목록 설정
      final sortedCategories = categories..sort();
      final finalCategories = ['전체', ...sortedCategories];
      
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
    setState(() {
      _selectedCategory = category;
    });
    _loadLiveRooms(); // 카테고리 변경시 새로 로드
  }
  
  void _onSortChanged(String sort) {
    setState(() {
      _sortOption = sort;
    });
    _loadLiveRooms(); // 정렬 변경시 새로 로드
  }


  // 카테고리 색상 팔레트
  final List<Color> _categoryColors = [
    Color(0xFF3B82F6), // 파랑
    Color(0xFF10B981), // 초록
    Color(0xFFF59E0B), // 주황
    Color(0xFF8B5CF6), // 보라
    Color(0xFFEF4444), // 빨강
    Color(0xFF6366F1), // 인디고
    Color(0xFF14B8A6), // 청록
    Color(0xFF0EA5E9), // 하늘
    Color(0xFFEC4899), // 분홍
    Color(0xFFF97316), // 주황2
    Color(0xFF84CC16), // 라임
    Color(0xFF06B6D4), // 시안
  ];

  Color _getCategoryColor(String category) {
    if (category == '전체') return Color(0xFF6B7280);
    
    // 카테고리명의 해시코드를 사용하여 색상 지정
    final colorIndex = category.hashCode.abs() % _categoryColors.length;
    return _categoryColors[colorIndex];
  }

  int _getCategoryCount(String category) {
    // API로부터 받은 카운트 사용, 없으면 0 반환
    return _categoryCounts[category] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
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

    return RefreshIndicator(
      onRefresh: _loadLiveRooms,
      child: Column(
        children: [
          // 라이브 인디케이터와 카테고리
          _buildLiveHeader(),
          
          // 카테고리 선택
          _buildCategorySelector(),
          
          // 정렬 옵션
          _buildSortingOptions(),
          
          // 리스트
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _filteredRooms.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => Container(
                height: 0.5,
                color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                if (index == _filteredRooms.length) {
                  return Container(
                    padding: EdgeInsets.all(16.h),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  );
                }
                return _buildCommunityListItem(_filteredRooms[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
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
                  _selectedCategory == '전체' 
                    ? 'LIVE ${_getCategoryCount('전체')}'
                    : 'LIVE ${_getCategoryCount(_selectedCategory)}/${_getCategoryCount('전체')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.search,
              color: AppTheme.getTextColor(context),
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 16.sp, color: AppTheme.getTextColor(context)),
              SizedBox(width: 8.w),
              Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 40.h,
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
                          color: isSelected 
                            ? _getCategoryColor(category).withOpacity(0.15)
                            : (AppTheme.isDark(context) ? Colors.grey[850] : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected 
                              ? _getCategoryColor(category)
                              : (AppTheme.isDark(context) ? Colors.grey[700]! : Colors.grey[300]!),
                            width: isSelected ? 1.5 : 1,
                          ),
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
                                  color: _getCategoryColor(category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected 
                                  ? _getCategoryColor(category)
                                  : AppTheme.getTextColor(context),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${_getCategoryCount(category)}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                  ? _getCategoryColor(category).withOpacity(0.8)
                                  : Colors.grey[500],
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
  
  Widget _buildSortingOptions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.sort, size: 16.sp, color: AppTheme.getTextColor(context)),
          SizedBox(width: 8.w),
          Text(
            '정렬',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Spacer(),
          PopupMenuButton<String>(
            onSelected: _onSortChanged,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'new',
                child: Text('최신순'),
              ),
              PopupMenuItem<String>(
                value: 'pop',
                child: Text('인기순'),
              ),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Text(
                    _sortOption == 'new' ? '최신순' : '인기순',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: AppTheme.getTextColor(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityListItem(DiscussionRoom room) {
    final category = room.category;
    final categoryColor = _getCategoryColor(category);
    final totalReactions = (room.positive_count ?? 0) + (room.neutral_count ?? 0) + (room.negative_count ?? 0);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/discussion/${room.id}'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // 카테고리 세로바
              Container(
                width: 3.w,
                height: 35.h, // 약 60% 높이
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1.5.r),
                ),
              ),
              SizedBox(width: 12.w),
              
              // 메인 컨텐츠
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.keyword,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getTextColor(context),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12.sp,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // 메타 정보
                      Row(
                        children: [
                          // 카테고리 태그
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // 작성 시간
                          Text(
                            _getTimeAgo(room.created_at),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          Spacer(),
                          // 통계 정보
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 12.sp, color: Colors.grey[400]),
                              SizedBox(width: 3.w),
                              Text(
                                '${room.comment_count ?? 0}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Icon(Icons.people_outline, size: 12.sp, color: Colors.grey[400]),
                              SizedBox(width: 3.w),
                              Text(
                                '${totalReactions}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
}