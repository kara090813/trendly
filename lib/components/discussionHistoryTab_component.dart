import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';

class DiscussionHistoryTabComponent extends StatefulWidget {
  const DiscussionHistoryTabComponent({super.key});

  @override
  State<DiscussionHistoryTabComponent> createState() => _DiscussionHistoryTabComponentState();
}

class _DiscussionHistoryTabComponentState extends State<DiscussionHistoryTabComponent> {
  final ApiService _apiService = ApiService();
  List<DiscussionRoom> _recentClosedRooms = [];
  List<DiscussionRoom> _hallOfFameRooms = [];
  bool _isLoading = true;
  String? _error;
  
  // 통계 데이터
  int _totalDiscussions = 2847;
  int _todayCreated = 23;
  int _activeDiscussions = 156;
  int _totalExplored = 1204;
  
  // 명예의 전당 데이터
  final Map<String, List<DiscussionRoom>> _hallOfFameData = {
    'popular': [], // 최고 인기 토론
    'intense': [], // 가장 치열한 토론
    'longLasting': [], // 장수 토론
  };

  @override
  void initState() {
    super.initState();
    _loadRecentClosedRooms();
    _loadHallOfFameData();
  }

  Future<void> _loadRecentClosedRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 랜덤 토론방에서 종료된 것들 가져오기
      final randomRooms = await _apiService.getRandomDiscussionRooms(50);
      final closedRooms = randomRooms.where((room) => room.is_closed).toList();
      
      // 최근 종료된 순으로 정렬
      closedRooms.sort((a, b) {
        final aDate = a.closed_at ?? a.updated_at;
        final bDate = b.closed_at ?? b.updated_at;
        
        // null 체크 후 비교
        if (bDate == null && aDate == null) return 0;
        if (bDate == null) return 1;
        if (aDate == null) return -1;
        
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _recentClosedRooms = closedRooms.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '히스토리 정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadHallOfFameData() async {
    try {
      // 각 카테고리별 데이터 로드 (실제로는 API 호출)
      final allRooms = await _apiService.getRandomDiscussionRooms(100);
      
      // 인기 토론 (공감 수 기준)
      final popularRooms = List<DiscussionRoom>.from(allRooms);
      popularRooms.sort((a, b) => 
        ((b.positive_count ?? 0) + (b.neutral_count ?? 0) + (b.negative_count ?? 0)).compareTo(
          (a.positive_count ?? 0) + (a.neutral_count ?? 0) + (a.negative_count ?? 0)));
      
      // 치열한 토론 (댓글 수 기준)  
      final intenseRooms = List<DiscussionRoom>.from(allRooms);
      intenseRooms.sort((a, b) => (b.comment_count ?? 0).compareTo(a.comment_count ?? 0));
      
      // 장수 토론 (지속 시간 기준)
      final longLastingRooms = List<DiscussionRoom>.from(allRooms);
      longLastingRooms.sort((a, b) {
        final aDuration = a.closed_at?.difference(a.created_at).inHours ?? 0;
        final bDuration = b.closed_at?.difference(b.created_at).inHours ?? 0;
        return bDuration.compareTo(aDuration);
      });
      
      if (mounted) {
        setState(() {
          _hallOfFameData['popular'] = popularRooms.take(20).toList();
          _hallOfFameData['intense'] = intenseRooms.take(20).toList();
          _hallOfFameData['longLasting'] = longLastingRooms.take(20).toList();
        });
      }
    } catch (e) {
      print('명예의 전당 데이터 로드 실패: $e');
    }
  }

  Future<void> _goToRandomRoom() async {
    try {
      final randomRooms = await _apiService.getRandomDiscussionRooms(1);
      if (randomRooms.isNotEmpty && mounted) {
        context.push('/discussion/${randomRooms.first.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('랜덤 토론방으로 이동할 수 없습니다: $e')),
        );
      }
    }
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
            ElevatedButton(onPressed: _loadRecentClosedRooms, child: Text('다시 시도')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadRecentClosedRooms();
        await _loadHallOfFameData();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 토론방 상세검색 섹션
            _buildSectionTitle('토론방 상세검색', '🔍', Color(0xFF6B73FF)),
            SizedBox(height: 16.h),
            _buildDetailedSearchSection(),
            
            SizedBox(height: 24.h),
            
            // 랜덤 토론방 탐색 섹션
            _buildSectionTitle('랜덤 토론방 탐색', '🎲', Color(0xFFFF8A65)),
            SizedBox(height: 16.h),
            _buildRandomExplorationSection(),
            
            SizedBox(height: 24.h),
            
            // 명예의 전당 섹션
            _buildSectionTitle('명예의 전당', '🏆', Color(0xFFFFB74D)),
            SizedBox(height: 16.h),
            _buildHallOfFameSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? emoji, Color color) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextColor(context),
          ),
        ),
        if (emoji != null) ...[
          SizedBox(width: 8.w),
          Text(
            emoji,
            style: TextStyle(fontSize: 18.sp),
          ),
        ],
      ],
    );
  }
  
  Widget _buildDetailedSearchSection() {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
          // 헤더 영역
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Color(0xFF6B73FF).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF6B73FF),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.search_outlined, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '토론방 검색',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '키워드, 날짜, 카테고리별 검색',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.getTextColor(context).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 콘텐츠 영역
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // 실시간 통계
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildCompactStat('전체', _totalDiscussions.toString(), Color(0xFF6B73FF)),
                      Container(width: 1.w, height: 30.h, color: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                      _buildCompactStat('오늘', _todayCreated.toString(), Color(0xFF00BFA5)),
                      Container(width: 1.w, height: 30.h, color: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                      _buildCompactStat('활성', _activeDiscussions.toString(), Color(0xFFFF5722)),
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // 검색 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('상세 검색 기능은 개발 중입니다')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6B73FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          '고급 검색하기',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
  
  Widget _buildModernStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(-1, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Color(0xFF667EEA), size: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  
  Widget _buildRandomExplorationSection() {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
          // 헤더 영역
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Color(0xFFFF8A65).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF8A65),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.explore_outlined, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '랜덤 탐색',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '새로운 토론을 발견해보세요',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.getTextColor(context).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 콘텐츠 영역
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // 오늘의 추천
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF8A65).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.star_outline, color: Color(0xFFFF8A65), size: 16.sp),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '오늘의 추천 토론',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '인공지능의 미래와 우리 사회',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildMetricChip('참여자 124명', Icons.people_outline, Color(0xFF00BFA5)),
                          SizedBox(width: 8.w),
                          _buildMetricChip('댓글 89개', Icons.chat_bubble_outline, Color(0xFFFF5722)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // 랜덤 탐색 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _goToRandomRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF8A65),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shuffle, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          '랜덤 탐색하기',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
  
  Widget _buildHallOfFameSection() {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
          // 헤더 영역
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Color(0xFFFFB74D).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB74D),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.emoji_events_outlined, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '명예의 전당',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '전설적인 토론들을 살펴보세요',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.getTextColor(context).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 콘텐츠 영역
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // 카테고리 목록
                _buildHallOfFameCategory(
                  '최고 인기',
                  '공감을 가장 많이 받은 토론',
                  Icons.favorite_outline,
                  Color(0xFFE91E63),
                  'popular',
                ),
                SizedBox(height: 12.h),
                _buildHallOfFameCategory(
                  '가장 치열',
                  '댓글이 가장 많았던 토론',
                  Icons.local_fire_department_outlined,
                  Color(0xFFFF5722),
                  'intense',
                ),
                SizedBox(height: 12.h),
                _buildHallOfFameCategory(
                  '최장 지속',
                  '가장 오래 계속된 토론',
                  Icons.schedule_outlined,
                  Color(0xFF2196F3),
                  'longLasting',
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHallOfFameItem(String emoji, String title, String description, String category, Color accentColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHallOfFameModal(category, title),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, -1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(-1, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: accentColor.withOpacity(0.25),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 2,
                        offset: Offset(0, -1),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 2,
                        offset: Offset(-1, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 20.sp,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: 16.sp, 
                  color: Colors.white.withOpacity(0.6)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showHallOfFameModal(String category, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHallOfFameModal(category, title),
    );
  }
  
  Widget _buildHallOfFameModal(String category, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discussions = (_hallOfFameData[category] ?? []).take(10).toList();
    
    return StatefulBuilder(
      builder: (context, setState) {
        String selectedPeriod = '전체';
        
        return Container(
          height: 0.85.sh,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF232B38) : Colors.white,
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
                  children: [
                    // 세로선과 타이틀
                    Container(
                      width: 4.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: _getCategoryIconColor(category),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'TOP 10 랭킹',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 기간 필터
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기간 선택',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark 
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodFilter('전체', selectedPeriod, (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          }),
                          _buildPeriodFilter('일간', selectedPeriod, (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          }),
                          _buildPeriodFilter('주간', selectedPeriod, (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          }),
                          _buildPeriodFilter('월간', selectedPeriod, (value) {
                            setState(() {
                              selectedPeriod = value;
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // 구분선
              Container(
                height: 1.h,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                color: isDark 
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              ),
              
              SizedBox(height: 20.h),
              
              // 리스트
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: discussions.length,
                  itemBuilder: (context, index) {
                    final discussion = discussions[index];
                    return _buildHallOfFameCard(discussion, index + 1, isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodFilter(String period, String selectedPeriod, Function(String) onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = period == selectedPeriod;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(period),
        child: Container(
          margin: EdgeInsets.all(2.w),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected 
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isSelected ? [
              BoxShadow(
                color: isDark 
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ] : [],
          ),
          child: Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.grey[300] : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHallOfFameCard(DiscussionRoom discussion, int rank, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF232B38) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            blurRadius: isDark ? 4 : 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            context.push('/discussion/${discussion.id}');
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 1번줄: 키워드명 ----- 랭크
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        discussion.keyword,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(-0.3, -0.3),
                          colors: rank <= 3 ? [
                            rank == 1 ? Color(0xFFFFB300) : rank == 2 ? Color(0xFFE0E0E0) : Color(0xFFD4824B),
                            rank == 1 ? Color(0xFFFFB300) : rank == 2 ? Color(0xFFE0E0E0) : Color(0xFFD4824B),
                          ] : isDark ? [
                            Colors.grey[500]!,
                            Colors.grey[600]!,
                          ] : [
                            Colors.grey[350]!,
                            Colors.grey[400]!,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // 2번줄: 프로그레스바
                _buildCompactReactionBarForModal(discussion, isDark),
                SizedBox(height: 12.h),
                // 3번줄: 댓글 공감 ---- N분전
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, size: 12.sp, color: textColor.withOpacity(0.6)),
                        SizedBox(width: 4.w),
                        Text('${discussion.comment_count ?? 0}', 
                          style: TextStyle(fontSize: 11.sp, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 12.sp, color: textColor.withOpacity(0.6)),
                        SizedBox(width: 4.w),
                        Text('${_getTotalReactionsForModal(discussion)}', 
                          style: TextStyle(fontSize: 11.sp, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                    Spacer(),
                    Text(
                      '${17 + (discussion.id % 60)}분 전',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textColor.withOpacity(0.5),
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

  Widget _buildCompactReactionBarForModal(DiscussionRoom room, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    
    // 테스트 데이터 사용 (실제 데이터가 0인 경우)
    var positive = room.positive_count ?? 0;
    var neutral = room.neutral_count ?? 0;
    var negative = room.negative_count ?? 0;
    
    // 실제 데이터가 없으면 테스트 데이터 사용
    if (positive == 0 && neutral == 0 && negative == 0) {
      positive = 16 + (room.id % 20);
      neutral = 27 + (room.id % 15);
      negative = 55 + (room.id % 10);
    }
    
    final total = positive + neutral + negative;
    
    if (total == 0) {
      return Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(3.r),
        ),
      );
    }
    
    final positivePercent = ((positive / total) * 100).round();
    final neutralPercent = ((neutral / total) * 100).round();
    final negativePercent = ((negative / total) * 100).round();
    
    // 자연스러운 색상 (컴팩트 버전)
    final positiveColor = isDark ? Color(0xFF389E0D) : Color(0xFF52C41A);
    final neutralColor = isDark ? Color(0xFF8C8C8C) : Color(0xFFA6A6A6);
    final negativeColor = isDark ? Color(0xFFFF4D4F) : Color(0xFFFF7875);
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: positiveColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text('긍정 $positivePercent%', style: TextStyle(
              color: textColor.withOpacity(0.8), 
              fontSize: 10.sp, 
              fontWeight: FontWeight.w500
            )),
            SizedBox(width: 12.w),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: neutralColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text('중립 $neutralPercent%', style: TextStyle(
              color: textColor.withOpacity(0.8), 
              fontSize: 10.sp, 
              fontWeight: FontWeight.w500
            )),
            SizedBox(width: 12.w),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: negativeColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text('부정 $negativePercent%', style: TextStyle(
              color: textColor.withOpacity(0.8), 
              fontSize: 10.sp, 
              fontWeight: FontWeight.w500
            )),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          height: 6.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          child: Row(
            children: [
              if (positive > 0)
                Expanded(
                  flex: positive,
                  child: Container(
                    decoration: BoxDecoration(
                      color: positiveColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3.r),
                        bottomLeft: Radius.circular(3.r),
                        topRight: neutral == 0 && negative == 0 ? Radius.circular(3.r) : Radius.zero,
                        bottomRight: neutral == 0 && negative == 0 ? Radius.circular(3.r) : Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (neutral > 0)
                Expanded(
                  flex: neutral,
                  child: Container(color: neutralColor),
                ),
              if (negative > 0)
                Expanded(
                  flex: negative,
                  child: Container(
                    decoration: BoxDecoration(
                      color: negativeColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(3.r),
                        bottomRight: Radius.circular(3.r),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  int _getTotalReactionsForModal(DiscussionRoom room) {
    var positive = room.positive_count ?? 0;
    var neutral = room.neutral_count ?? 0;
    var negative = room.negative_count ?? 0;
    
    // 실제 데이터가 없으면 테스트 데이터 사용
    if (positive == 0 && neutral == 0 && negative == 0) {
      positive = 45 + (room.id % 30);
      neutral = 20 + (room.id % 15);
      negative = 10 + (room.id % 20);
    }
    
    return positive + neutral + negative;
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'popular':
        return Color(0xFFFFB74D);
      case 'intense':
        return Color(0xFFFF8A65);
      case 'longLasting':
        return Color(0xFF64B5F6);
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryIconColor(String category) {
    switch (category) {
      case 'popular':
        return Color(0xFFE91E63); // 하트 아이콘 색상 (분홍)
      case 'intense':
        return Color(0xFFFF5722); // 불 아이콘 색상 (주황)
      case 'longLasting':
        return Color(0xFF2196F3); // 시계 아이콘 색상 (파란)
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildKeywordCard(String title, List<String> keywords, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...keywords.map((keyword) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                keyword,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFeaturedDiscussion() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(0xFFFF8A65).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFF8A65).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.star, color: Color(0xFFFF8A65), size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추천 토론방',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    Text(
                      '인공지능의 미래',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '활성',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.comment, size: 12.sp, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                '124개',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.favorite, size: 12.sp, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                '89개',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivity() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(0xFFFF8A65).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFF8A65).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.today, color: Color(0xFFFF8A65), size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                '오늘의 활동',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '23',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8A65),
                    ),
                  ),
                  Text(
                    '새 토론',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 30.h,
                color: Colors.grey.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    '156',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8A65),
                    ),
                  ),
                  Text(
                    '활성 토론',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 30.h,
                color: Colors.grey.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    '1.2K',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8A65),
                    ),
                  ),
                  Text(
                    '총 탐색',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 새로운 디자인용 헬퍼 메서드들
  Widget _buildCompactStat(String title, String value, Color color) {
    final isDark = AppTheme.isDark(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark 
                ? Colors.white.withOpacity(0.8)
                : Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMetricChip(String text, IconData icon, Color color) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark 
          ? color.withOpacity(0.2)
          : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
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
      ),
    );
  }


  Widget _buildHallOfFameCategory(String title, String description, IconData icon, Color color, String category) {
    final isDark = AppTheme.isDark(context);
    return InkWell(
      onTap: () => _showHallOfFameModal(category, title),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.getTextColor(context).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDark 
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }








}