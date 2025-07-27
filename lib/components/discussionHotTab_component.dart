import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../models/_models.dart';
import '../funcs/category_colors.dart';
import '../widgets/discussionReaction_widget.dart';

class DiscussionHotTabComponent extends StatefulWidget {
  const DiscussionHotTabComponent({super.key});

  @override
  State<DiscussionHotTabComponent> createState() => _DiscussionHotTabComponentState();
}

class _DiscussionHotTabComponentState extends State<DiscussionHotTabComponent> 
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<DiscussionRoom> _hotRooms = [];
  Map<int, String> _roomCategories = {};
  bool _isLoading = true;
  String? _error;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadHotRooms();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _loadHotRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 인기 토론방 10개 가져오기
      final hotRooms = await _apiService.getHotDiscussionRooms();
      
      // 카테고리 정보 로드
      await _loadCategoriesForRooms(hotRooms);

      if (mounted) {
        setState(() {
          _hotRooms = hotRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '인기 토론방 정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategoriesForRooms(List<DiscussionRoom> rooms) async {
    final Map<int, int> roomToKeywordMap = {};
    final List<int> keywordIds = [];

    for (var room in rooms) {
      if (room.keyword_id_list.isNotEmpty) {
        final lastKeywordId = room.keyword_id_list.last;
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

      final Map<int, String> tempCategories = {};
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

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
  }
  
  int _getUniqueParticipants(DiscussionRoom room) {
    // 댓글 수와 반응 수를 기반으로 참여자 수 추정
    // 실제로는 백엔드에서 고유 사용자 수를 제공해야 함
    final comments = room.comment_count ?? 0;
    final reactions = _getTotalReactions(room);
    
    // 대략적인 추정: 댓글 작성자 + 반응만 한 사용자 (중복 고려)
    // 댓글 작성자의 70%가 반응도 했다고 가정
    final estimatedParticipants = comments + (reactions * 0.3).round();
    return estimatedParticipants > 0 ? estimatedParticipants : 0;
  }


  int _getTotalReactions(DiscussionRoom room) {
    final positive = room.positive_count ?? 0;
    final neutral = room.neutral_count ?? 0;
    final negative = room.negative_count ?? 0;
    return positive + neutral + negative;
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
            ElevatedButton(onPressed: _loadHotRooms, child: Text('다시 시도')),
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
          onRefresh: _loadHotRooms,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // 히어로 섹션
              SliverToBoxAdapter(
                child: _buildHotDiscussionHeader(),
              ),
              
              // 상위 3개 토론방 스와이프 섹션
              SliverToBoxAdapter(
                child: _buildTopThreeSection(),
              ),
              
              // 4-10위 리스트 섹션
              SliverToBoxAdapter(
                child: _buildRemainingSection(),
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

  // HOT 토론방 히어로 섹션 - TimeMachine 스타일
  Widget _buildHotDiscussionHeader() {
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
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department,
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
                      "HOT 토론방",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "실시간 인기 토론을 확인하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
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

  Widget _buildTopThreeSection() {
    if (_hotRooms.length < 3) return SizedBox.shrink();
    
    final topThree = _hotRooms.take(3).toList();
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "TOP 3 토론방",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "실시간 최고 인기 토론",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          Container(
            height: 280.h,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              itemCount: topThree.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                  child: _buildTopCard(topThree[index], index),
                );
              },
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildTopCard(DiscussionRoom room, int index) {
    final isDark = AppTheme.isDark(context);
    final rankColors = [
      Color(0xFFFFB300), // 1등 - 골드 (더 진한 노란색)
      Color(0xFFE0E0E0), // 2등 - 실버  
      Color(0xFFD4824B), // 3등 - 브론즈
    ];
    
    final rankColor = rankColors[index];
    final cardColor = isDark ? Color(0xFF232B38) : Colors.white;
    final darkerCardColor = isDark ? Color(0xFF232B38) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? rankColor.withOpacity(0.4) : rankColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: isDark ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [darkerCardColor, cardColor],
            ) : null,
            color: isDark ? null : Colors.white,
            border: Border.all(
              color: rankColor.withOpacity(0.5),
              width: 1.w,
            ),
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
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              colors: [
                                rankColor.withOpacity(0.9),
                                rankColor,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: rankColor.withOpacity(0.4),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            room.keyword,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // 인용문 스타일 댓글
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark 
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: textColor.withOpacity(0.6),
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              room.comment_summary != null && room.comment_summary!.isNotEmpty 
                                ? room.comment_summary!
                                : '아직 토론이 활발하지 않아요. 첫 번째 의견을 남겨보세요!',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 12.sp,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // 반응 프로그레스바
                    _buildReactionProgressBar(room),
                    SizedBox(height: 12.h),
                    // 통계 정보
                    Row(
                      children: [
                        Icon(Icons.comment, size: 14.sp, color: textColor.withOpacity(0.6)),
                        SizedBox(width: 4.w),
                        Text('${room.comment_count ?? 0}', 
                          style: TextStyle(fontSize: 12.sp, color: textColor.withOpacity(0.6))),
                        SizedBox(width: 16.w),
                        Icon(Icons.group, size: 14.sp, color: textColor.withOpacity(0.6)),
                        SizedBox(width: 4.w),
                        Text('${_getUniqueParticipants(room)}', 
                          style: TextStyle(fontSize: 12.sp, color: textColor.withOpacity(0.6))),
                        Spacer(),
                        Text(_getRelativeTime(room.updated_at ?? room.created_at), 
                          style: TextStyle(fontSize: 12.sp, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildReactionProgressBar(DiscussionRoom room) {
    final isDark = AppTheme.isDark(context);
    final textColor = isDark ? Colors.white : Colors.black;
    
    final positive = room.positive_count ?? 0;
    final neutral = room.neutral_count ?? 0;
    final negative = room.negative_count ?? 0;
    final total = positive + neutral + negative;
    
    if (total == 0) {
      return Column(
        children: [
          Text(
            '아직 참여자가 없어요',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      );
    }
    
    final positivePercent = ((positive / total) * 100).round();
    final neutralPercent = ((neutral / total) * 100).round();
    final negativePercent = ((negative / total) * 100).round();
    
    // 자연스러운 색상
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
              fontSize: 11.sp, 
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
              fontSize: 11.sp, 
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
              fontSize: 11.sp, 
              fontWeight: FontWeight.w500
            )),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: isDark ? Colors.grey[800] : Colors.grey[200],
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
                        topLeft: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                        topRight: neutral == 0 && negative == 0 ? Radius.circular(4.r) : Radius.zero,
                        bottomRight: neutral == 0 && negative == 0 ? Radius.circular(4.r) : Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (neutral > 0)
                Expanded(
                  flex: neutral,
                  child: Container(
                    color: neutralColor,
                  ),
                ),
              if (negative > 0)
                Expanded(
                  flex: negative,
                  child: Container(
                    decoration: BoxDecoration(
                      color: negativeColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4.r),
                        bottomRight: Radius.circular(4.r),
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

  Widget _buildRemainingSection() {
    if (_hotRooms.length <= 3) return SizedBox.shrink();
    
    final remaining = _hotRooms.skip(3).toList();
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "4-10위 랭킹",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "인기 상승 토론방",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 리스트 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
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
                  ...remaining.asMap().entries.map((entry) {
                    final index = entry.key + 4; // 4등부터 시작
                    final room = entry.value;
                    final isLast = entry.key == remaining.length - 1;
                    return _buildCompactCard(room, index, isLast);
                  }).toList(),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildCompactCard(DiscussionRoom room, int rank, bool isLast) {
    final isDark = AppTheme.isDark(context);
    final cardColor = isDark ? Color(0xFF232B38) : Colors.white;
    final darkerCardColor = isDark ? Color(0xFF232B38) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final category = room.category;
    final categoryColor = CategoryColors.getCategoryColor(category);
    
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
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // 1번줄: 키워드명 ----- 랭크원
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.keyword,
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
                          colors: isDark ? [
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
                SizedBox(height: 8.h),
                // 카테고리 태그
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // 2번줄: 프로그레스바
                _buildCompactReactionBar(room),
                SizedBox(height: 12.h),
                // 3번줄: 댓글 공감 ---- N분전
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, size: 12.sp, color: textColor.withOpacity(0.6)),
                        SizedBox(width: 4.w),
                        Text('${room.comment_count ?? 0}', 
                          style: TextStyle(fontSize: 11.sp, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 12.sp, color: textColor.withOpacity(0.6)),
                        SizedBox(width: 4.w),
                        Text('${_getTotalReactions(room)}', 
                          style: TextStyle(fontSize: 11.sp, color: textColor.withOpacity(0.6))),
                      ],
                    ),
                    Spacer(),
                    Text(
                      _getRelativeTime(room.updated_at ?? room.created_at),
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
    ).animate(delay: Duration(milliseconds: isLast ? 0 : rank * 150))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCompactReactionBar(DiscussionRoom room) {
    final isDark = AppTheme.isDark(context);
    final textColor = isDark ? Colors.white : Colors.black;
    
    final positive = room.positive_count ?? 0;
    final neutral = room.neutral_count ?? 0;
    final negative = room.negative_count ?? 0;
    final total = positive + neutral + negative;
    
    if (total == 0) {
      return Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[300],
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
}