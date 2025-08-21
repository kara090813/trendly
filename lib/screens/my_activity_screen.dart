import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../providers/_providers.dart';
import '../services/api_service.dart';
import '../models/freezed/discussion_room_model.dart';
import '../models/freezed/comment_model.dart';

class MyActivityScreen extends StatefulWidget {
  final String initialTab;
  
  const MyActivityScreen({
    Key? key,
    required this.initialTab,
  }) : super(key: key);

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late String _currentTab;
  final ApiService _apiService = ApiService();
  
  final Map<String, int> _tabIndexMap = {
    'rooms': 0,
    'comments': 1,
    'likes': 2,
  };
  
  final Map<String, String> _tabTitleMap = {
    'rooms': '참여한 토론방',
    'comments': '작성한 댓글',
    'likes': '좋아요한 댓글',
  };
  

  // 데이터 상태
  List<DiscussionRoom>? _discussion_rooms;
  List<Comment>? _myComments;
  List<Comment>? _likedComments;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _tabIndexMap[widget.initialTab] ?? 0,
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
        final newTab = _tabIndexMap.keys.elementAt(_tabController.index);
        setState(() {
          _currentTab = newTab;
        });
        _animationController.forward(from: 0);
      }
    });

    // 모든 데이터를 한번에 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
      _animationController.forward();
    });
  }

  // 모든 데이터를 한번에 로드하는 메서드
  Future<void> _loadAllData() async {
    final preferences = Provider.of<UserPreferenceProvider>(context, listen: false);
    
    setState(() => _isLoadingData = true);
    
    try {
      // 세 가지 데이터를 병렬로 로드
      await Future.wait([
        _loadDiscussionRooms(preferences),
        _loadMyComments(preferences),
        _loadLikedComments(preferences),
      ]);
      
      // 모든 데이터 로드 완료 후 UI 업데이트
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('🚨 전체 데이터 로드 오류: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadDiscussionRooms(UserPreferenceProvider preferences) async {
    try {
      // 댓글을 작성한 토론방 + 감정을 표시한 토론방을 모두 포함
      final commentedRooms = preferences.commentedRooms.toSet();
      final sentimentRooms = preferences.roomSentiments.keys.toSet();
      final allRoomIds = commentedRooms.union(sentimentRooms).toList();
      
      if (allRoomIds.isNotEmpty) {
        final rooms = await _apiService.getDiscussionRoomsByIds(allRoomIds);
        _discussion_rooms = rooms;
      } else {
        _discussion_rooms = [];
      }
    } catch (e) {
      // 토론방 로드 오류
      print('🚨 토론방 로드 오류: $e');
      print('🔍 요청한 Room IDs: ${preferences.commentedRooms.toSet().union(preferences.roomSentiments.keys.toSet()).toList()}');
      _discussion_rooms = [];
    }
  }

  Future<void> _loadMyComments(UserPreferenceProvider preferences) async {
    try {
      final commentIds = preferences.commentIds;
      if (commentIds.isNotEmpty) {
        final comments = await _apiService.getCommentsByIds(commentIds);
        _myComments = comments;
      } else {
        _myComments = [];
      }
    } catch (e) {
      // 댓글 로드 오류
      print('🚨 댓글 로드 오류: $e');
      print('🔍 요청한 Comment IDs: ${preferences.commentIds}');
      _myComments = [];
    }
  }

  Future<void> _loadLikedComments(UserPreferenceProvider preferences) async {
    try {
      final likedCommentIds = preferences.getLikedComments();
      if (likedCommentIds.isNotEmpty) {
        final comments = await _apiService.getCommentsByIds(likedCommentIds);
        _likedComments = comments;
      } else {
        _likedComments = [];
      }
    } catch (e) {
      // 좋아요 댓글 로드 오류
      print('🚨 좋아요 댓글 로드 오류: $e');
      print('🔍 요청한 Liked Comment IDs: ${preferences.getLikedComments()}');
      _likedComments = [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferenceProvider>(
      builder: (context, preferences, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: AppTheme.getContainerColor(context),
            elevation: 4,
            shadowColor: AppTheme.isDark(context) 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
                size: 20.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              _tabTitleMap[_currentTab] ?? '내 활동',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.h),
              child: Container(
                color: AppTheme.getContainerColor(context),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: AppTheme.primaryBlue,
                  indicatorWeight: 3.0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: '토론방'),
                    Tab(text: '댓글'),
                    Tab(text: '좋아요'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRoomsTab(preferences),
              _buildCommentsTab(preferences),
              _buildLikesTab(preferences),
            ],
          ),
        );
      },
    );
  }
  

  Widget _buildRoomsTab(UserPreferenceProvider preferences) {
    if (_isLoadingData) {
      return _buildLoadingState();
    }

    if (_discussion_rooms == null) {
      return _buildErrorState('토론방 정보를 불러오는 중 오류가 발생했습니다');
    }
    
    if (_discussion_rooms!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.forum_outlined,
        title: '참여한 토론방이 없습니다',
        subtitle: '토론방에 댓글을 작성하거나 감정을 표시하면 여기에 표시됩니다',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _discussion_rooms = null;
          _myComments = null;
          _likedComments = null;
        });
        await _loadAllData();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: _discussion_rooms!.length,
        itemBuilder: (context, index) {
          final room = _discussion_rooms![index];
          final sentiment = preferences.roomSentiments[room.id];
          return _buildRoomCard(room, sentiment, index);
        },
      ),
    );
  }

  Widget _buildCommentsTab(UserPreferenceProvider preferences) {
    if (_isLoadingData) {
      return _buildLoadingState();
    }

    if (_myComments == null) {
      return _buildErrorState('댓글 정보를 불러오는 중 오류가 발생했습니다');
    }
    
    if (_myComments!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: '작성한 댓글이 없습니다',
        subtitle: '토론에 참여하여 의견을 남겨보세요',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _discussion_rooms = null;
          _myComments = null;
          _likedComments = null;
        });
        await _loadAllData();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: _myComments!.length,
        itemBuilder: (context, index) {
          final comment = _myComments![index];
          return _buildCommentCard(comment, index);
        },
      ),
    );
  }

  Widget _buildLikesTab(UserPreferenceProvider preferences) {
    if (_isLoadingData) {
      return _buildLoadingState();
    }

    if (_likedComments == null) {
      return _buildErrorState('좋아요 댓글 정보를 불러오는 중 오류가 발생했습니다');
    }
    
    if (_likedComments!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.thumb_up_outlined,
        title: '좋아요한 댓글이 없습니다',
        subtitle: '마음에 드는 댓글에 좋아요를 눌러보세요',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _discussion_rooms = null;
          _myComments = null;
          _likedComments = null;
        });
        await _loadAllData();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: _likedComments!.length,
        itemBuilder: (context, index) {
          final comment = _likedComments![index];
          return _buildLikedCommentCard(comment, index);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: Offset(0.8, 0.8));
  }

  Widget _buildRoomCard(DiscussionRoom room, String? sentiment, int index) {
    final timeAgo = _getTimeAgo(room.updated_at ?? room.created_at);
    final statusColor = room.is_closed ? Colors.grey : Colors.green;
    final statusText = room.is_closed ? '종료됨' : '진행중';
    
    return GestureDetector(
      onTap: () => context.push('/discussion/${room.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.getContainerColor(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.isDark(context) 
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey[200]!.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.isDark(context)
                  ? Colors.black.withOpacity(0.6)
                  : Colors.grey.withOpacity(0.35),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (제목, 상태)
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.forum,
                    color: AppTheme.primaryBlue,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.keyword,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (sentiment != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getSentimentColor(sentiment).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSentimentIcon(sentiment),
                          color: _getSentimentColor(sentiment),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _getSentimentText(sentiment),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _getSentimentColor(sentiment),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
             
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment, int index) {
    final timeAgo = _getTimeAgo(comment.created_at);
    final isSubComment = comment.is_sub_comment;
    
    return GestureDetector(
      onTap: () {
        if (isSubComment && comment.parent != null) {
          context.push('/comment/${comment.parent}');
        } else {
          context.push('/discussion/${comment.discussion_room}');
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.getContainerColor(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.isDark(context) 
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey[200]!.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.isDark(context)
                  ? Colors.black.withOpacity(0.6)
                  : Colors.grey.withOpacity(0.35),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isSubComment 
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    isSubComment ? Icons.subdirectory_arrow_right : Icons.chat_bubble,
                    color: isSubComment ? Colors.orange : Colors.green,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getRoomKeywordInfo(comment.discussion_room),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Text(
                                snapshot.data ?? '토론방 #${comment.discussion_room}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
                                ),
                              ),
                              if (isSubComment) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                  child: Text(
                                    '답글',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 좋아요/싫어요 표시
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (comment.like_count > 0) ...[
                      _buildStatChip(Icons.thumb_up_outlined, '${comment.like_count}', Colors.green),
                      SizedBox(width: 4.w),
                    ],
                    if (comment.dislike_count > 0)
                      _buildStatChip(Icons.thumb_down_outlined, '${comment.dislike_count}', Colors.red),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // 댓글 내용
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.isDark(context) 
                  ? Colors.grey[800]?.withOpacity(0.3)
                  : Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                comment.comment,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
                  height: 1.4,
                ),
              ),
            ),
            
            if (comment.sub_comment_count > 0) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 12.sp,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '답글 ${comment.sub_comment_count}개',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLikedCommentCard(Comment comment, int index) {
    final timeAgo = _getTimeAgo(comment.created_at);
    final isSubComment = comment.is_sub_comment;
    
    return GestureDetector(
      onTap: () {
        if (isSubComment && comment.parent != null) {
          context.push('/comment/${comment.parent}');
        } else {
          context.push('/discussion/${comment.discussion_room}');
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.getContainerColor(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.isDark(context) 
              ? Colors.grey[800]!.withOpacity(0.3)
              : Colors.grey[200]!.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.isDark(context)
                  ? Colors.black.withOpacity(0.6)
                  : Colors.grey.withOpacity(0.35),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.thumb_up,
                    color: Colors.orange,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FutureBuilder<String>(
                            future: _getRoomKeywordInfo(comment.discussion_room),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? '토론방 #${comment.discussion_room}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
                                ),
                              );
                            },
                          ),
                          if (isSubComment) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Text(
                                '답글',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 좋아요/싫어요 표시
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatChip(Icons.thumb_up_outlined, '${comment.like_count}', Colors.green),
                    if (comment.dislike_count > 0) ...[
                      SizedBox(width: 4.w),
                      _buildStatChip(Icons.thumb_down_outlined, '${comment.dislike_count}', Colors.red),
                    ],
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // 댓글 내용
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Text(
                comment.comment,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.isDark(context) ? AppTheme.darkText : AppTheme.lightText,
                  height: 1.4,
                ),
              ),
            ),
            
            if (comment.sub_comment_count > 0) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 12.sp,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '답글 ${comment.sub_comment_count}개',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }


  // 헬퍼 메서드들
  Widget _buildLoadingState() {
    final isDark = AppTheme.isDark(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.08),
                          offset: const Offset(-4, -4),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
                strokeWidth: 3,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1000.ms),
            
            SizedBox(height: 24.h),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.getContainerColor(context),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Text(
                '데이터를 불러오는 중...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final isDark = AppTheme.isDark(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(6, 6),
                          blurRadius: 12,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.08),
                          offset: const Offset(-6, -6),
                          blurRadius: 12,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(6, 6),
                          blurRadius: 12,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-6, -6),
                          blurRadius: 12,
                        ),
                      ],
              ),
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.withOpacity(0.1),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40.sp,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
            ).animate().scale(begin: const Offset(0, 0), duration: 400.ms, curve: Curves.bounceOut),
            
            SizedBox(height: 24.h),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppTheme.getContainerColor(context),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          offset: const Offset(-4, -4),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            count,
            style: TextStyle(
              fontSize: 13.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  

  Future<String> _getRoomKeywordInfo(int discussionRoomId) async {
    try {
      final room = await _apiService.getDiscussionRoomById(discussionRoomId);
      return room.keyword; // 키워드명만 반환
    } catch (e) {
      return '토론방 #$discussionRoomId';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      final months = difference.inDays ~/ 30;
      return '${months}개월 전';
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

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
      default:
        return Colors.orange;
    }
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Icons.thumb_up;
      case 'negative':
        return Icons.thumb_down;
      case 'neutral':
      default:
        return Icons.thumbs_up_down;
    }
  }

  String _getSentimentText(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return '긍정';
      case 'negative':
        return '부정';
      case 'neutral':
      default:
        return '중립';
    }
  }

}