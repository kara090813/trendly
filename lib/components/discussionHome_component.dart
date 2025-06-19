import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trendly/widgets/circleButton_widget.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../widgets/sortingToggle_widget.dart'; // 추가: SortPopupWidget 임포트

class DiscussionHomeComponent extends StatefulWidget {
  const DiscussionHomeComponent({super.key});

  @override
  State<DiscussionHomeComponent> createState() =>
      _DiscussionHomeComponentState();
}

class _DiscussionHomeComponentState extends State<DiscussionHomeComponent> {
  final ApiService _apiService = ApiService();
  bool _showActiveOnly = false; // 실시간만 보기 토글
  String _searchQuery = ''; // 검색어
  bool _isSearchVisible = false; // 검색바 표시 여부
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // 페이징 관련
  int _currentPage = 1;
  final int _pageSize = 15;
  int _totalPages = 1;

  // 데이터 상태 관리
  List<DiscussionRoom> _hotRooms = []; // HOT 토론방 (상단 표시용)
  List<DiscussionRoom> _displayedRooms = []; // 현재 표시중인 토론방들
  List<DiscussionRoom> _allRooms = []; // 전체 토론방 (페이징용)
  Map<int, String> _roomCategories = {}; // 토론방 ID를 키로 하는 카테고리 맵
  
  // 상태 변수
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isPopularSort = true; // 정렬 방식 (true: 인기순, false: 최신순)
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDiscussionRooms();
    
    // 검색 컨트롤러 리스너 추가
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
      _applyFiltersAndSearch();
    });
    
    // 스크롤 컨트롤러 리스너는 페이징에서 불필요하므로 제거
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscussionRooms() async {
    setState(() {
      if (_isLoading) {
        _isLoading = true;
      } else {
        _isRefreshing = true;
      }
      _error = null;
      _currentPage = 1;
    });

    try {
      // 활성화된 토론방 로드
      final activeRooms = await _apiService.getActiveDiscussionRooms();
      
      // 랜덤 토론방 로드 (페이징용)
      final randomRooms = await _apiService.getRandomDiscussionRooms(30);
      
      // 전체 토론방 합치기
      final allRooms = [...activeRooms, ...randomRooms];
      
      // 카테고리 정보 로드
      await _loadCategoriesForRooms(allRooms);
      
      // HOT 토론방 추출 (인기순 상위 4개)
      final hotRooms = List<DiscussionRoom>.from(allRooms)
        ..sort((a, b) {
          final aTotal = (a.commentCount ?? 0) + 
                         (a.positiveCount ?? 0) + 
                         (a.neutralCount ?? 0) + 
                         (a.negativeCount ?? 0);
          final bTotal = (b.commentCount ?? 0) + 
                         (b.positiveCount ?? 0) + 
                         (b.neutralCount ?? 0) + 
                         (b.negativeCount ?? 0);
          return bTotal.compareTo(aTotal);
        });

      if (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 600));
      }

      if (mounted) {
        setState(() {
          _allRooms = allRooms;
          _hotRooms = hotRooms.take(4).toList();
          _updateDisplayedRooms();
          
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '토론방 정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  // 페이지 데이터 업데이트
  void _updateDisplayedRooms() {
    final filteredRooms = _getFilteredRooms();
    _totalPages = (filteredRooms.length / _pageSize).ceil();
    if (_totalPages == 0) _totalPages = 1;
    
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    _displayedRooms = filteredRooms.skip(startIndex).take(_pageSize).toList();
  }

  // 페이지 변경 처리
  void _onPageChanged(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
      _updateDisplayedRooms();
    });
  }

  // 필터 및 검색 적용
  void _applyFiltersAndSearch() {
    setState(() {
      _currentPage = 1;
      _updateDisplayedRooms();
    });
  }

  // 필터링된 토론방 목록 반환
  List<DiscussionRoom> _getFilteredRooms() {
    List<DiscussionRoom> filtered = List.from(_allRooms);
    
    // 실시간/히스토리 필터
    if (_showActiveOnly) {
      // 실시간: isClosed가 false인 것들
      filtered = filtered.where((room) => !room.isClosed).toList();
    } else {
      // 히스토리: isClosed가 true인 것들
      filtered = filtered.where((room) => room.isClosed).toList();
    }
    
    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((room) {
        final keyword = room.keyword.toLowerCase();
        final category = _getCategoryForRoom(room).toLowerCase();
        return keyword.contains(_searchQuery) || category.contains(_searchQuery);
      }).toList();
    }
    
    // 정렬 적용
    if (_isPopularSort) {
      // 인기순 정렬 (댓글 + 반응 수 기준)
      filtered.sort((a, b) {
        final aTotal = (a.commentCount ?? 0) + 
                       (a.positiveCount ?? 0) + 
                       (a.neutralCount ?? 0) + 
                       (a.negativeCount ?? 0);
        final bTotal = (b.commentCount ?? 0) + 
                       (b.positiveCount ?? 0) + 
                       (b.neutralCount ?? 0) + 
                       (b.negativeCount ?? 0);
        return bTotal.compareTo(aTotal);
      });
    } else {
      // 최신순 정렬
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return filtered;
  }

  // 토론방 목록의 카테고리 정보 로드 (최적화)
  Future<void> _loadCategoriesForRooms(List<DiscussionRoom> rooms) async {
    // 각 토론방의 마지막 키워드 ID 수집
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
      // 한 번의 API 호출로 모든 키워드 정보 가져오기
      final keywords = await _apiService.getKeywordsByIds(keywordIds);

      // 키워드 ID → 카테고리 매핑
      final Map<int, String> keywordCategories = {};
      for (var keyword in keywords) {
        keywordCategories[keyword.id] = keyword.category;
      }

      // 토론방 ID → 카테고리 매핑 업데이트
      final Map<int, String> tempCategories = {};
      roomToKeywordMap.forEach((roomId, keywordId) {
        tempCategories[roomId] = keywordCategories[keywordId] ?? '기타';
      });

      // 상태 업데이트
      if (mounted) {
        setState(() {
          _roomCategories = tempCategories;
        });
      }
    } catch (e) {
      print('카테고리 정보 일괄 로드 실패: $e');
      // 오류 발생 시 기본값으로 설정
      final Map<int, String> defaultCategories = {};
      roomToKeywordMap.keys.forEach((roomId) {
        defaultCategories[roomId] = '기타';
      });

      if (mounted) {
        setState(() {
          _roomCategories = defaultCategories;
        });
      }
    }
  }


  // 토론방의 카테고리 정보 가져오기
  String _getCategoryForRoom(DiscussionRoom room) {
    // 카테고리 정보가 있으면 반환
    if (_roomCategories.containsKey(room.id)) {
      return _roomCategories[room.id]!;
    }
    return '카테고리 없음';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : Stack(
        children: [
          // 메인 콘텐츠
          Opacity(
            opacity: _isRefreshing ? 0.3 : 1.0,
            child: CustomScrollView(
              controller: _scrollController,
              physics: _isRefreshing
                  ? NeverScrollableScrollPhysics()
                  : BouncingScrollPhysics(),
              slivers: [
                // AppBar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 8,
                  expandedHeight: 0,
                  toolbarHeight: 54.h,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.getContainerColor(context),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: AppTheme.isDark(context)
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SafeArea(child: _buildHeader()),
                  ),
                ),
                
                // HOT 토론방 섹션
                SliverToBoxAdapter(
                  child: _buildHotSection(),
                ),
                
                // 간단한 필터 토글
                SliverToBoxAdapter(
                  child: _buildSimpleFilter(),
                ),
                
                // 메인 토론방 리스트
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildFeedItem(_displayedRooms[index], index);
                    },
                    childCount: _displayedRooms.length,
                  ),
                ),
                
                // 페이지네이션
                SliverToBoxAdapter(
                  child: _buildPagination(),
                ),
              ],
            ),
          ),

          // 새로고침 오버레이
          if (_isRefreshing)
            Center(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppTheme.isDark(context)
                      ? Color(0xFF21202C).withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.isDark(context)
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50.w,
                      height: 50.w,
                      child: CircularProgressIndicator(
                        color: Color(0xFF19B3F6),
                        strokeWidth: 3.w,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "새로고침 중...",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF19B3F6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadDiscussionRooms,
              child: Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  // 헤더 + 버튼 (우측 정렬) - 다크모드 지원 추가
  Widget _buildHeaderWithButton(String title, String buttonText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: AppTheme.getTextColor(context),
            ),
          ),
          _buildCustomButton(buttonText),
        ],
      ),
    );
  }

  // 커스텀 버튼 (뉴모픽 효과) - 다크모드 지원 추가
  Widget _buildCustomButton(String text) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$text 기능은 아직 준비중입니다')));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? Color(0xFF2A2A36)
              : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: AppTheme.isDark(context)
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              offset: Offset(-1, -1),
              blurRadius: 3,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.white,
              offset: Offset(-1, -1),
              blurRadius: 3,
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: Offset(2, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Color(0xFF19B3F6),
            ),
          ],
        ),
      ),
    );
  }

  // HOT 토론방 섹션
  Widget _buildHotSection() {
    if (_hotRooms.isEmpty) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.only(top: 20.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFF6B35),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'HOT 토론방',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 160.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _hotRooms.length,
              itemBuilder: (context, index) {
                return _buildHotCard(_hotRooms[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  // HOT 카드 위젯
  Widget _buildHotCard(DiscussionRoom room, int index) {
    final gradients = [
      [Color(0xFFFF6B35), Color(0xFFFF8E53)],
      [Color(0xFF19B3F6), Color(0xFF4FC3F7)],
      [Color(0xFF9C27B0), Color(0xFFBA68C8)],
      [Color(0xFF4CAF50), Color(0xFF81C784)],
    ];
    
    final gradient = gradients[index % gradients.length];
    
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/discussion/${room.id}'),
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.whatshot,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  room.keyword,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  _getCategoryForRoom(room),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${room.commentCount ?? 0}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${(room.positiveCount ?? 0) + (room.neutralCount ?? 0) + (room.negativeCount ?? 0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 간단한 필터 토글 + 정렬 기능
  Widget _buildSimpleFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            '토론방',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Spacer(),
          // 정렬 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                _isPopularSort = !_isPopularSort;
              });
              _applyFiltersAndSearch();
            },
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.isDark(context) 
                  ? Colors.grey[800]
                  : Colors.grey[100],
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppTheme.isDark(context) 
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPopularSort ? Icons.trending_up : Icons.schedule,
                    size: 16.sp,
                    color: AppTheme.isDark(context) 
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _isPopularSort ? '인기순' : '최신순',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.isDark(context) 
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 필터 토글
          Container(
            decoration: BoxDecoration(
              color: AppTheme.isDark(context) 
                ? Colors.grey[800]
                : Colors.grey[100],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterButton('실시간', _showActiveOnly),
                _buildFilterButton('히스토리', !_showActiveOnly),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showActiveOnly = text == '실시간';
        });
        _applyFiltersAndSearch();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF19B3F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected 
              ? Colors.white 
              : (AppTheme.isDark(context) 
                  ? Colors.grey[400] 
                  : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  // 한줄 레이아웃 피드 아이템 (가시성 개선)
  Widget _buildFeedItem(DiscussionRoom room, int index) {
    final String category = _getCategoryForRoom(room);
    final int totalReactions = (room.positiveCount ?? 0) + 
                               (room.neutralCount ?? 0) + 
                               (room.negativeCount ?? 0);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.isDark(context) 
            ? Colors.grey[700]! 
            : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/discussion/${room.id}'),
          borderRadius: BorderRadius.circular(12.r),
          splashColor: Color(0xFF19B3F6).withOpacity(0.1),
          highlightColor: Color(0xFF19B3F6).withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // 키워드명 (확장 가능)
                Expanded(
                  flex: 3,
                  child: Text(
                    room.keyword,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 카테고리
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.isDark(context) 
                      ? Color(0xFF3A3A48)
                      : Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppTheme.isDark(context) 
                        ? Colors.grey[600]!
                        : Colors.grey[300]!,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.isDark(context) 
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 댓글/좋아요 통계
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 15.sp,
                      color: AppTheme.isDark(context) 
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${room.commentCount ?? 0}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.isDark(context) 
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 15.sp,
                      color: AppTheme.isDark(context) 
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '$totalReactions',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.isDark(context) 
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: 8.w),
                
                // 클릭 힌트 아이콘
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.sp,
                  color: Color(0xFF19B3F6).withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 간단한 페이지네이션 위젯
  Widget _buildPagination() {
    if (_totalPages <= 1) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이전 버튼
          IconButton(
            onPressed: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
            icon: Icon(
              Icons.chevron_left,
              color: _currentPage > 1 
                ? Color(0xFF19B3F6) 
                : (AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
          
          // 페이지 정보
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context) 
                ? Colors.grey[800]
                : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$_currentPage / $_totalPages',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ),
          
          // 다음 버튼
          IconButton(
            onPressed: _currentPage < _totalPages ? () => _onPageChanged(_currentPage + 1) : null,
            icon: Icon(
              Icons.chevron_right,
              color: _currentPage < _totalPages 
                ? Color(0xFF19B3F6) 
                : (AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // 검색 버튼
          CircleButtonWidget(
            onTap: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: _isSearchVisible ? Icons.close : Icons.search,
            color: _isSearchVisible ? Colors.grey[600]! : Color(0xFF19B3F6),
            context: context,
            iconSize: 20.sp,
          ),
          
          SizedBox(width: 12.w),
          
          Expanded(
            child: _isSearchVisible
                ? Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppTheme.isDark(context) 
                        ? Colors.grey[800]
                        : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppTheme.isDark(context) 
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '토론방 검색...',
                        hintStyle: TextStyle(
                          color: AppTheme.isDark(context) 
                            ? Colors.grey[500]
                            : Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18.sp,
                          color: AppTheme.isDark(context) 
                            ? Colors.grey[500]
                            : Colors.grey[600],
                        ),
                      ),
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : Center(
                    child: AutoSizeText(
                      '토론방',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(context),
                      ),
                      maxLines: 1,
                    ),
                  ),
          ),
          
          SizedBox(width: 12.w),
          
          // 새로고침 버튼
          CircleButtonWidget(
            onTap: () {
              if (!_isRefreshing) {
                _loadDiscussionRooms();
              }
            },
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            context: context,
            iconSize: 20.sp,
          ),
        ],
      ),
    );
  }
}