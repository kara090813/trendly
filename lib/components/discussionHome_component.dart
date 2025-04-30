import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';

class DiscussionHomeComponent extends StatefulWidget {
  const DiscussionHomeComponent({super.key});

  @override
  State<DiscussionHomeComponent> createState() =>
      _DiscussionHomeComponentState();
}

class _DiscussionHomeComponentState extends State<DiscussionHomeComponent> {
  final ApiService _apiService = ApiService();
  String _selectedTab = '실시간';
  String _sortOption = '인기순';
  bool _isExpanded = false;

  // 데이터 상태 관리
  List<DiscussionRoom> _activeRooms = []; // 실시간 토론방
  List<DiscussionRoom> _historicRooms = []; // 히스토리 토론방
  Map<int, String> _roomCategories = {}; // 토론방 ID를 키로 하는 카테고리 맵
  // 상태 변수 수정 - 클래스 멤버 변수 부분에 추가/수정
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false; // 추가: 더보기 로딩 상태
  String? _error;
  final int _initialCardCount = 4; // 초기 카드 수 (그대로 유지)
  final int _loadMoreCount = 4; // 추가: 한번에 더 불러올 카드 수
  int _displayCount = 4; // 추가: 현재 표시 중인 카드 수

  @override
  void initState() {
    super.initState();
    _displayCount = _initialCardCount; // 초기 표시 개수 설정
    _loadDiscussionRooms();
  }

  Future<void> _loadDiscussionRooms() async {
    setState(() {
      if (_isLoading) {
        // 초기 로딩인 경우
        _isLoading = true;
      } else {
        // 새로고침인 경우
        _isRefreshing = true;
      }
      _error = null;
    });

    try {
      // 활성화된 토론방 목록 로드
      final activeRooms = await _apiService.getActiveDiscussionRooms();

      // 히스토리 토론방은 랜덤하게 4개만 가져오기
      final historicRooms =
          await _apiService.getRandomDiscussionRooms(_initialCardCount);

      // 새로고침 시 약간의 지연 추가 (로딩 애니메이션이 보이도록)
      if (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 600));
      }

      // 모든 토론방의 카테고리 정보 로드 (최적화된 방식으로)
      await _loadCategoriesForRooms([...activeRooms, ...historicRooms]);

      if (mounted) {
        setState(() {
          _activeRooms = activeRooms;
          _historicRooms = historicRooms;
          _isLoading = false;
          _isRefreshing = false; // 새로고침 완료
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '토론방 정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
          _isRefreshing = false; // 새로고침 완료
        });
      }
    }
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

  // 정렬 기능 (추천순, 최신순)
  List<DiscussionRoom> _getSortedRooms() {
    if (_selectedTab == '실시간') {
      if (_activeRooms.isEmpty) return [];

      if (_sortOption == '인기순') {
        // 댓글 수 + 감정 반응 수(긍정+중립+부정) 기준으로 정렬
        return List.from(_activeRooms)
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
      } else {
        // 최신순 정렬 (생성일 기준)
        return List.from(_activeRooms)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } else {
      // 히스토리 탭 - 이미 랜덤하게 가져왔으므로 추가 정렬 없음
      return _historicRooms;
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
                    // 메인 콘텐츠 부분
                    Opacity(
                      opacity: _isRefreshing ? 0.3 : 1.0,
                      child: CustomScrollView(
                        physics: _isRefreshing
                            ? NeverScrollableScrollPhysics()
                            : BouncingScrollPhysics(),
                        slivers: [
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
                                          color: Colors.white.withOpacity(0.18),
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
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
                          SliverList(
                            delegate: SliverChildListDelegate([
                              // Top container for main discussion section
                              Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.getContainerColor(context),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(24.r),
                                    bottomRight: Radius.circular(24.r),
                                  ),
                                  boxShadow: AppTheme.isDark(context)
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 40.h),
                                    _buildToggleTabs(),
                                    SizedBox(height: 12.h),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info,
                                            size: 18.sp,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '타인에 대한 비방글은 삭제될 수 있습니다',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 탭에 따라 다른 헤더 표시
                                          _selectedTab == '실시간'
                                              ? _buildSortControl()
                                              : _buildHeaderWithButton(
                                                  '', '전체보기'),
                                          SizedBox(height: 15.h),

                                          // 토론방 카드 목록
                                          ..._buildDiscussionCards(),

                                          // 실시간 탭일 때만 펼쳐보기 버튼 표시
                                          if (_selectedTab == '실시간' &&
                                              _getSortedRooms().length >
                                                  _initialCardCount)
                                            _buildExpandButton(),

                                          SizedBox(height: 20.h),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),

                              // Bottom container for favorites and participated discussions
                              Container(
                                padding: EdgeInsets.only(bottom: 20.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.getContainerColor(context),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24.r),
                                    topRight: Radius.circular(24.r),
                                  ),
                                  boxShadow: AppTheme.isDark(context)
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, -3),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, -3),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          16.w, 16.h, 14.w, 0),
                                      child: _buildHeaderWithButton(
                                          '즐겨찾기한 토론방', '더보기'),
                                    ),
                                    SizedBox(height: 15.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: _buildFavoriteCard(),
                                    ),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(16.w, 0, 14.w, 0),
                                      child: _buildHeaderWithButton(
                                          '내가 참여한 토론방', '더보기'),
                                    ),
                                    SizedBox(height: 15.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: _buildParticipatedCard(),
                                    ),
                                    SizedBox(height: 10.h),
                                  ],
                                ),
                              ),
                            ]),
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
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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

  // 정렬 컨트롤 - 텍스트와 드롭다운 버튼
  Widget _buildSortControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 전체 영역에 GestureDetector 적용하여 텍스트와 버튼 모두 터치 가능하게 함
        GestureDetector(
          onTap: () {
            _showSortOptions(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
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
                  _sortOption,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                SizedBox(width: 8.w),
                // 버튼 크기 증가
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-1, -1),
                        blurRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(2, 2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 24.sp,
                      color: Color(0xFF19B3F6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 헤더 + 버튼 (우측 정렬)
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
              color: Color(0xFF4A4A4A),
            ),
          ),
          _buildCustomButton(buttonText),
        ],
      ),
    );
  }

  // 커스텀 버튼 (뉴모픽 효과)
  Widget _buildCustomButton(String text) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$text 기능은 아직 준비중입니다')));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
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
                color: Color(0xFF4A4A4A),
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

  // 정렬 옵션 팝업 메뉴
  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Container(
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption('인기순'),
                Divider(),
                _buildSortOption('최신순'),
              ],
            ),
          ),
        );
      },
    );
  }

  // 정렬 옵션 버튼
  Widget _buildSortOption(String option) {
    return InkWell(
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          option,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight:
                _sortOption == option ? FontWeight.bold : FontWeight.normal,
            color:
                _sortOption == option ? Color(0xFF19B3F6) : Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }

  // 토론방 카드 목록 생성 함수 수정
  List<Widget> _buildDiscussionCards() {
    final List<DiscussionRoom> rooms = _getSortedRooms();

    if (rooms.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(20.h),
          alignment: Alignment.center,
          child: Text(
            '${_selectedTab == '실시간' ? '활성화된' : '종료된'} 토론방이 없습니다.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        )
      ];
    }

    // 현재 표시할 항목 수 (최대 길이보다 크지 않도록)
    int displayCount =
        _displayCount > rooms.length ? rooms.length : _displayCount;

    // 히스토리 탭에서는 항상 초기 개수만 표시
    if (_selectedTab != '실시간') {
      displayCount =
          _initialCardCount > rooms.length ? rooms.length : _initialCardCount;
    }

    // 결과 위젯 리스트
    List<Widget> cardWidgets = [];

    // 실제 카드 추가
    for (int i = 0; i < displayCount; i++) {
      cardWidgets.add(
        _discussionCard(
          room: rooms[i],
          isEmpty: (rooms[i].commentCount ?? 0) == 0,
        ),
      );
    }

    // 로딩 중인 경우 스켈레톤 카드 추가
    if (_isLoadingMore) {
      for (int i = 0; i < _loadMoreCount; i++) {
        cardWidgets.add(_buildSkeletonCard());
      }
    }

    return cardWidgets;
  }

// 스켈레톤 카드 위젯 (로딩 시 표시)
  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h, right: 0.w),
      height: 140.h, // 일반 카드와 비슷한 높이
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 메인 콘텐츠 영역
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 스켈레톤
                  Container(
                    width: 200.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // 카테고리 스켈레톤
                  Container(
                    width: 160.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // 구분선
                  Divider(color: Colors.grey[200], thickness: 1.2),
                  SizedBox(height: 12.h),

                  // 반응 바 스켈레톤
                  Container(
                    width: double.infinity,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(
            color: Colors.grey[200],
            thickness: 3,
            width: 20, // Divider 자체의 너비 (공간 차지)
          ),
          // 오른쪽 입장 버튼 스켈레톤
          Container(
            width: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    final List<DiscussionRoom> rooms = _getSortedRooms();
    final bool hasMoreToShow = _displayCount < rooms.length;
    final bool hasShownMore = _displayCount > _initialCardCount;

    // 테마 관련 변수
    final bool isDark = AppTheme.isDark(context);
    final Color primaryColor = Color(0xFF19B3F6);
    final Color bgColor = isDark ? Color(0xFF2D2D3A) : Colors.white;
    final Color separatorColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    // 접기 버튼만 표시 (모두 펼쳤을 때)
    if (!hasMoreToShow && hasShownMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: _buildButton(
          text: '접기',
          icon: Icons.keyboard_arrow_up_rounded,
          onPressed: () {
            setState(() {
              _displayCount = _initialCardCount;
            });
          },
          isCollapse: true,
        ),
      );
    }
    // 접기 + 더보기 버튼 모두 표시
    else if (hasShownMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: _buildSplitButton(
                  text: '접기',
                  icon: Icons.keyboard_arrow_up_rounded,
                  onPressed: () {
                    setState(() {
                      _displayCount = _initialCardCount;
                    });
                  },
                  isLeft: true,
                  isCollapse: true,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 6.w),
                child: _buildSplitButton(
                  text: '더보기',
                  icon: Icons.keyboard_arrow_down_rounded,
                  onPressed: _isLoadingMore ? null : () => _loadMoreItems(),
                  isLoading: _isLoadingMore,
                  isLeft: false,
                ),
              ),
            ),
          ],
        ),
      );
    }
    // 더보기 버튼만 표시 (초기 상태)
    else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: _buildButton(
          text: '더보기',
          icon: Icons.keyboard_arrow_down_rounded,
          onPressed: _isLoadingMore ? null : () => _loadMoreItems(),
          isLoading: _isLoadingMore,
        ),
      );
    }
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isCollapse = false,
  }) {
    final bool isDark = AppTheme.isDark(context);
    final Color primaryColor = Color(0xFF19B3F6);
    final Color accentColor = Color(0xFFE74C3C);
    final Color bgColor = isDark ? Color(0xFF2D2D3A) : Colors.white;
    final Color textColor = isCollapse ? accentColor : primaryColor;

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(width: 8.w),
                isLoading
                    ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
                    : Icon(
                  icon,
                  size: 20.sp,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isLeft = true,
    bool isCollapse = false,
  }) {
    final bool isDark = AppTheme.isDark(context);
    final Color primaryColor = Color(0xFF19B3F6);
    final Color accentColor = Color(0xFFE74C3C);
    final Color bgColor = isDark ? Color(0xFF2D2D3A) : Colors.white;
    final Color separatorColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color textColor = isCollapse ? accentColor : primaryColor;

    BorderRadius borderRadius = isLeft
        ? BorderRadius.only(
      topLeft: Radius.circular(12.r),
      bottomLeft: Radius.circular(12.r),
      topRight: Radius.circular(4.r),
      bottomRight: Radius.circular(4.r),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(4.r),
      bottomLeft: Radius.circular(4.r),
      topRight: Radius.circular(12.r),
      bottomRight: Radius.circular(12.r),
    );

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Stack(
            children: [
              // 텍스트 중앙
              Positioned.fill(
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),

              // 왼쪽 또는 오른쪽 아이콘 + 구분선
              if (isLeft)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      SizedBox(width: 14.w),
                      Icon(
                        icon,
                        color: textColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        height: 24.h,
                        width: 1,
                        color: separatorColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                )
              else
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Container(
                        height: 24.h,
                        width: 1,
                        color: separatorColor.withOpacity(0.5),
                      ),
                      SizedBox(width: 12.w),
                      isLoading
                          ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                          : Icon(
                        icon,
                        color: textColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 14.w),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 더보기 항목 로드 메서드 추가
  Future<void> _loadMoreItems() async {
    // 이미 로딩 중인 경우 중복 방지
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // 로딩 애니메이션을 위한 짧은 지연
    await Future.delayed(Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        // 추가 항목 표시 (최대 _loadMoreCount개)
        final List<DiscussionRoom> rooms = _getSortedRooms();
        final int maxItems = rooms.length;
        final int newCount = _displayCount + _loadMoreCount;
        _displayCount = newCount > maxItems ? maxItems : newCount;
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
          ),
          Expanded(
            child: Center(
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
          // 알림 아이콘을 리프레시 아이콘으로 변경
          _buildCircleButton(
            onTap: () {
              if (!_isRefreshing) {
                _loadDiscussionRooms();
              }
            },
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(8.w),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  Widget _buildToggleTabs() {
    final double totalWidth = 180.w;
    final double buttonWidth = totalWidth / 2;
    final double buttonHeight = 32.h;

    return SizedBox(
      width: totalWidth,
      height: buttonHeight + 4.h, // 튀어나온 부분 고려한 높이
      child: Stack(
        clipBehavior: Clip.none, // 버튼이 배경보다 튀어나올 수 있도록 함
        children: [
          // 오목한 파란색 배경
          Positioned(
            top: 2.h, // 튀어나온 버튼 고려해서 약간 아래로
            child: Container(
              width: totalWidth,
              height: buttonHeight,
              decoration: BoxDecoration(
                color: Color(0xFF1CB3F8),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  // 오목한 효과를 주는 그림자
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // 애니메이션 흰색 버튼 (튀어나온 효과)
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: _selectedTab == '실시간' ? 0 : buttonWidth,
            top: 0,
            // 상단에 위치하여 튀어나온 효과 표현
            child: Container(
              width: buttonWidth,
              height: buttonHeight + 4.h, // 살짝 더 큰 높이로 튀어나옴
              decoration: BoxDecoration(
                color: AppTheme.getToggleButtonColor(context),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  // 튀어나온 효과를 주는 그림자
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // 터치 영역과 선택되지 않은 텍스트들
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = '실시간';
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        '실시간',
                        style: AppTheme.isDark(context)
                            ? TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: _selectedTab == '실시간'
                                    ? Colors.white
                                    : Colors.black,
                              )
                            : TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: _selectedTab == '실시간'
                                    ? Colors.black
                                    : Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = '히스토리';
                        _isExpanded = false; // 히스토리 탭으로 전환 시 항상 접힌 상태로
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        '히스토리',
                        style: AppTheme.isDark(context)
                            ? TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: _selectedTab == '히스토리'
                                    ? Colors.white
                                    : Colors.black,
                              )
                            : TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: _selectedTab == '히스토리'
                                    ? Colors.black
                                    : Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _discussionCard({required DiscussionRoom room, bool isEmpty = false}) {
    return Stack(
      children: [
        // Main card
        Container(
          margin: EdgeInsets.only(bottom: 20.h, right: 0.w),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppTheme.isDark(context)
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(1, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(1, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -1),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: 18.w, left: 18.w, bottom: 18.w, right: 90.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 키워드 타이틀
                AutoSizeText(
                  room.keyword,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: AppTheme.getTextColor(context)),
                  maxLines: 1,
                  minFontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                // 카테고리 및 댓글 정보
                Text(
                  '${_getCategoryForRoom(room)} | 댓글 (${room.commentCount ?? 0})',
                  style: TextStyle(
                      color: AppTheme.isDark(context)
                          ? Color(0xFFD8D8D8)
                          : Colors.grey[700],
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4.h),
                Divider(color: Color(0xFFE0DDDD), thickness: 1.2),
                SizedBox(height: 4.h),
                isEmpty ? _buildEmptyCommentMessage() : _buildReactionBar(room),
              ],
            ),
          ),
        ),

        // Entrance button
        Positioned(
          top: 0,
          bottom: 20.h,
          right: 0,
          child: Container(
            width: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(-3, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(20.r),
              ),
              child: Material(
                color: AppTheme.getCardColor(context),
                child: InkWell(
                  onTap: () {
                    context.push('/discussion/${room.id}');
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_right,
                          size: 34.sp,
                          color: const Color(0xFF00AEEF),
                        ),
                        Text(
                          '입장',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: AppTheme.isDark(context)
                                ? Colors.white
                                : Color(0xFF404040),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 즐겨찾기 토론방 카드 (임시 데모용)
  Widget _buildFavoriteCard() {
    // 미구현 기능으로 임시 카드 표시
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '즐겨찾기 기능은 준비 중입니다',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 참여한 토론방 카드 (임시 데모용)
  Widget _buildParticipatedCard() {
    // 미구현 기능으로 임시 카드 표시
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '참여 기록 기능은 준비 중입니다',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 빈 댓글 메시지
  Widget _buildEmptyCommentMessage() {
    return Container(
      height: 38.h,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18.sp,
            color:
                AppTheme.isDark(context) ? Color(0xFFD8D8D8) : Colors.grey[500],
          ),
          SizedBox(width: 6.w),
          Text(
            '아직 의견이 없어요! 첫 의견을 남겨주세요!',
            style: TextStyle(
              color: AppTheme.isDark(context)
                  ? Color(0xFFD8D8D8)
                  : Colors.grey[500],
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  // 반응 바
  Widget _buildReactionBar(DiscussionRoom room) {
    // 반응 수치 계산
    final int totalReactions = (room.positiveCount ?? 0) +
        (room.neutralCount ?? 0) +
        (room.negativeCount ?? 0);

    double positiveRatio =
        totalReactions > 0 ? (room.positiveCount ?? 0) / totalReactions : 0.33;
    double neutralRatio =
        totalReactions > 0 ? (room.neutralCount ?? 0) / totalReactions : 0.34;
    double negativeRatio =
        totalReactions > 0 ? (room.negativeCount ?? 0) / totalReactions : 0.33;

    // 비율 표시 형식으로 변환
    String positivePercent = '${(positiveRatio * 100).round()}%';
    String neutralPercent = '${(neutralRatio * 100).round()}%';
    String negativePercent = '${(negativeRatio * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 반응 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Container(
            height: 8.h,
            child: Row(
              children: [
                _reactionSegment(positiveRatio, const Color(0xFF00AEEF)),
                _reactionSegment(neutralRatio, Colors.grey.shade400),
                _reactionSegment(negativeRatio, const Color(0xFFFF5A5F)),
              ],
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // 반응 라벨
        Row(
          children: [
            _reactionLabel('긍정', positivePercent, const Color(0xFF00AEEF)),
            SizedBox(width: 16.w),
            _reactionLabel('중립', neutralPercent, Colors.grey.shade600),
            SizedBox(width: 16.w),
            _reactionLabel('부정', negativePercent, const Color(0xFFFF5A5F)),
          ],
        ),
      ],
    );
  }

  Widget _reactionSegment(double value, Color color) {
    return Expanded(
      flex: (value * 100).toInt(),
      child: Container(
        color: color,
      ),
    );
  }

  Widget _reactionLabel(String text, String percentage, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '$text $percentage',
          style: TextStyle(
            fontSize: 12.sp,
            color:
                AppTheme.isDark(context) ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

enum PillDirection { left, right }
