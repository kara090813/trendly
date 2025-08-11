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

  String _getCompactTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간';
    } else {
      return '${difference.inDays}일';
    }
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

  // HOT 토론방 히어로 섹션 - 통일된 스타일
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
                      "인기 토론방",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "가장 핫한 토론에 참여하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // HOT 인디케이터
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B35).withOpacity(0.3),
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
                      'HOT 10',
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

  Widget _buildTopThreeSection() {
    if (_hotRooms.length < 3) return SizedBox.shrink();
    
    final topThree = _hotRooms.take(3).toList();
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP 3 섹션 타이틀
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
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
                  "TOP 3",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 14.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "스와이프",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideX(begin: -0.05, end: 0, duration: 600.ms),
          
          SizedBox(height: 20.h),
          
          SizedBox(
            height: 180.h, // 높이 조정
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: topThree.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: _buildTopCard(topThree[index], index),
                );
              },
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTopCard(DiscussionRoom room, int index) {
    final isDark = AppTheme.isDark(context);
    final rankColors = [
      [Color(0xFFFFD700), Color(0xFFFFA500)], // 골드 그라디언트
      [Color(0xFFC0C0C0), Color(0xFF9E9E9E)], // 실버 그라디언트
      [Color(0xFFCD7F32), Color(0xFF8B4513)], // 브론즈 그라디언트
    ];
    
    final rankGradient = rankColors[index];
    final textColor = isDark ? Colors.white : Colors.black87;
    final category = room.category ?? '기타';
    final categoryColor = CategoryColors.getCategoryColor(category);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        border: Border.all(
          color: rankGradient[0].withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: rankGradient[0].withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/discussion/${room.id}'),
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            children: [
              // 상단 영역: 순위 배지 + 키워드
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      rankGradient[0].withOpacity(0.1),
                      rankGradient[0].withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    // 순위 배지
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: rankGradient,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rankGradient[0].withOpacity(0.4),
                            blurRadius: 8,
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
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // 키워드 + 카테고리
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.keyword,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6.r),
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
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.local_fire_department,
                                size: 12.sp,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'HOT',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 하단 영역: 감정 반응 + 통계
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: [
                      // 감정 반응 심플 버전
                      _buildCompactSentimentBar(room),
                      
                      Spacer(),
                      
                      // 통계 정보
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat(
                            icon: Icons.chat_bubble_outline,
                            value: '${room.comment_count ?? 0}',
                            color: textColor.withOpacity(0.6),
                          ),
                          _buildMiniStat(
                            icon: Icons.people_outline,
                            value: '${_getTotalReactions(room)}',
                            color: textColor.withOpacity(0.6),
                          ),
                          _buildMiniStat(
                            icon: Icons.access_time,
                            value: _getCompactTime(room.updated_at ?? room.created_at),
                            color: textColor.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSentimentBar(DiscussionRoom room) {
    final isDark = AppTheme.isDark(context);
    
    final positive = room.positive_count ?? 0;
    final neutral = room.neutral_count ?? 0;
    final negative = room.negative_count ?? 0;
    final total = positive + neutral + negative;
    
    if (total == 0) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          '아직 참여자가 없습니다',
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    final positivePercent = (positive / total * 100).round();
    final neutralPercent = (neutral / total * 100).round();
    final negativePercent = (negative / total * 100).round();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSentimentChip('😊', positivePercent, Colors.green),
            _buildSentimentChip('😐', neutralPercent, Colors.grey),
            _buildSentimentChip('😔', negativePercent, Colors.red),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.r),
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          child: Row(
            children: [
              if (positive > 0)
                Expanded(
                  flex: positive,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.r),
                        bottomLeft: Radius.circular(2.r),
                        topRight: neutral == 0 && negative == 0 ? Radius.circular(2.r) : Radius.zero,
                        bottomRight: neutral == 0 && negative == 0 ? Radius.circular(2.r) : Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (neutral > 0)
                Expanded(
                  flex: neutral,
                  child: Container(color: Colors.grey),
                ),
              if (negative > 0)
                Expanded(
                  flex: negative,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(2.r),
                        bottomRight: Radius.circular(2.r),
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

  Widget _buildSentimentChip(String emoji, int percent, Color color) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 16.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: color,
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
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 미니멀 헤더
          Text(
            "다른 인기 토론",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 500.ms),
          
          SizedBox(height: 16.h),
          
          // 리스트 카드들
          ...remaining.asMap().entries.map((entry) {
            final index = entry.key + 4;
            final room = entry.value;
            return _buildModernCompactCard(room, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildModernCompactCard(DiscussionRoom room, int rank) {
    final isDark = AppTheme.isDark(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final category = room.category;
    final categoryColor = CategoryColors.getCategoryColor(category);
    
    final positive = room.positive_count ?? 0;
    final neutral = room.neutral_count ?? 0;
    final negative = room.negative_count ?? 0;
    final total = positive + neutral + negative;
    
    Color dominantColor = Colors.grey;
    String dominantEmoji = '😐';
    if (total > 0) {
      if (positive >= neutral && positive >= negative) {
        dominantColor = Colors.green;
        dominantEmoji = '😊';
      } else if (negative >= positive && negative >= neutral) {
        dominantColor = Colors.red;
        dominantEmoji = '😔';
      }
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [
            Color(0xFF2D3748),
            Color(0xFF1A202C),
          ] : [
            Colors.white,
            Color(0xFFF7FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: dominantColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: dominantColor.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/discussion/${room.id}'),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                // 왼쪽: 순위 + 감정 아이콘
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [
                        dominantColor.withOpacity(0.3),
                        dominantColor.withOpacity(0.1),
                      ] : [
                        dominantColor.withOpacity(0.15),
                        dominantColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        dominantEmoji,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xFF2D3748) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: dominantColor,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                color: dominantColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // 중앙: 제목 + 카테고리
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        room.keyword,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
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
                          SizedBox(width: 8.w),
                          Icon(Icons.forum, size: 10.sp, color: textColor.withOpacity(0.4)),
                          SizedBox(width: 3.w),
                          Text(
                            '${room.comment_count ?? 0}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: textColor.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.favorite, size: 10.sp, color: textColor.withOpacity(0.4)),
                          SizedBox(width: 3.w),
                          Text(
                            '${_getTotalReactions(room)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: textColor.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 오른쪽: 시간 + 화살표
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getCompactTime(room.updated_at ?? room.created_at),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textColor.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.sp,
                      color: dominantColor.withOpacity(0.6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: (rank - 4) * 100))
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}