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
  Map<int, String> _roomCategories = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
  // 검색 및 필터링
  String _searchQuery = '';
  String _selectedCategory = '전체';
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = ['전체'];
  
  // 페이징 관련
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

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
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 실시간 탭에서는 모든 데이터를 한번에 로드하므로 무한 스크롤 불필요
    // 필요시 여기에 추가 로직 구현
  }

  Future<void> _loadLiveRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      // 활성화된 토론방 모두 가져오기
      final activeRooms = await _apiService.getActiveDiscussionRooms();
      
      // 카테고리 정보 로드
      await _loadCategoriesForRooms(activeRooms);
      
      // 카테고리 목록 추출
      final categorySet = <String>{};
      for (var room in activeRooms) {
        final category = _roomCategories[room.id] ?? '기타';
        categorySet.add(category);
      }
      
      // 전체를 맨 앞에 배치하고 나머지는 정렬
      final sortedCategories = categorySet.toList()..sort();
      final finalCategories = ['전체', ...sortedCategories];

      if (mounted) {
        setState(() {
          _allLiveRooms = activeRooms;
          _categories = finalCategories;
          _isLoading = false;
        });
        _applyFilters();
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

  void _applyFilters() {
    List<DiscussionRoom> filtered = List.from(_allLiveRooms);
    
    // 카테고리 필터
    if (_selectedCategory != '전체') {
      filtered = filtered.where((room) {
        final category = _roomCategories[room.id] ?? '기타';
        return category == _selectedCategory;
      }).toList();
    }
    
    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) {
        return room.keyword.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    setState(() {
      _filteredRooms = filtered;
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  Future<void> _loadCategoriesForRooms(List<DiscussionRoom> rooms) async {
    final Map<int, int> roomToKeywordMap = {};
    final List<int> keywordIds = [];

    for (var room in rooms) {
      if (room.keywordIdList.isNotEmpty) {
        final lastKeywordId = room.keywordIdList.last;
        roomToKeywordMap[room.id] = lastKeywordId;
        keywordIds.add(lastKeywordId);
      }
    }

    if (keywordIds.isEmpty) return;

    try {
      final keywords = await _apiService.getKeywordsByIds(keywordIds);

      final Map<int, String> keywordCategories = {};
      for (var keyword in keywords) {
        keywordCategories[keyword.id] = keyword.category;
      }

      final Map<int, String> tempCategories = Map.from(_roomCategories);
      roomToKeywordMap.forEach((roomId, keywordId) {
        tempCategories[roomId] = keywordCategories[keywordId] ?? '기타';
      });

      if (mounted) {
        setState(() {
          _roomCategories = tempCategories;
        });
      }
    } catch (e) {
      print('카테고리 정보 일괄 로드 실패: $e');
    }
  }

  String _getCategoryForRoom(DiscussionRoom room) {
    return _roomCategories[room.id] ?? '기타';
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
    if (category == '전체') return _allLiveRooms.length;
    return _allLiveRooms.where((room) {
      final roomCategory = _roomCategories[room.id] ?? '기타';
      return roomCategory == category;
    }).length;
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
              itemCount: _filteredRooms.length,
              separatorBuilder: (context, index) => Container(
                height: 0.5,
                color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
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
                    ? 'LIVE ${_allLiveRooms.length}'
                    : 'LIVE ${_filteredRooms.length}/${_allLiveRooms.length}',
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Text(
                  '최신순',
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
        ],
      ),
    );
  }

  Widget _buildCommunityListItem(DiscussionRoom room) {
    final category = _getCategoryForRoom(room);
    final categoryColor = _getCategoryColor(category);
    final totalReactions = (room.positiveCount ?? 0) + (room.neutralCount ?? 0) + (room.negativeCount ?? 0);
    
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
                            _getTimeAgo(room.createdAt),
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
                                '${room.commentCount ?? 0}',
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