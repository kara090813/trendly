import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/_models.dart';
import '../services/api_service.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/_widgets.dart';
import '../widgets/profanity_filter_button.dart';
import '../widgets/comment_options_widget.dart';
import '../app_theme.dart';
import '../utils/profanity_filter_utils.dart';

class CommentRoomScreen extends StatefulWidget {
  final int commentRoomId;

  const CommentRoomScreen({
    Key? key,
    required this.commentRoomId,
  }) : super(key: key);

  @override
  State<CommentRoomScreen> createState() => _CommentRoomScreenState();
}

class _CommentRoomScreenState extends State<CommentRoomScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  // 상태 변수들
  bool _isLoading = true;
  bool _isCommentLoading = false;
  bool _isRefreshing = false;
  bool _isCommenting = false;
  bool _isPopularSort = true;

  // 댓글 반응 로컬 상태 관리 (좋아요/싫어요 즉시 UI 반영용)
  Map<int, CommentReaction> _commentReactions = {};

  // 클래스 변수에 추가
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  // 텍스트 컨트롤러
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 데이터 변수들
  Comment? _parentComment;
  List<Comment> _subComments = [];
  int _discussionRoomId = 0;

  // 페이징 관련 변수 추가
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreSubComments = true;
  bool _isLoadingMoreSubComments = false;

  DiscussionRoom? _discussionRoom;
  Keyword? _keyword;
  CommentReaction? _parentCommentReaction;

   

// 원본 댓글 반응 데이터 로드 메서드
  void _loadParentCommentReaction() async {
    if (_parentComment == null) return;

    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

    // 사용자가 좋아요/싫어요 한 상태 확인
    final String? reaction = provider.getCommentReaction(_parentComment!.id);

    if (mounted) {
      setState(() {
        _parentCommentReaction = CommentReaction(
          reactionType: reaction,
          likeCount: _parentComment!.like_count ?? 0,
          dislikeCount: _parentComment!.dislike_count ?? 0,
        );
      });
    }
  }

  // 사용자 정보 로드
  void _loadUserPreference() {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

    if (provider.nickname != null) {
      _idController.text = provider.nickname!;
    }

    if (provider.password != null) {
      _passwordController.text = provider.password!;
    }
  }

  // 댓글 반응 데이터 로드 메서드
  void _loadCommentReactions() async {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

    // 사용자가 좋아요/싫어요 한 댓글 정보 로드
    await provider.loadCommentReactions();

    // 댓글 목록에 대한 반응 상태 초기화
    if (mounted && _subComments.isNotEmpty) {
      setState(() {
        for (var comment in _subComments) {
          final String? reaction = provider.getCommentReaction(comment.id);
          if (reaction != null) {
            _commentReactions[comment.id] = CommentReaction(
              reactionType: reaction,
              likeCount: comment.like_count ?? 0,
              dislikeCount: comment.dislike_count ?? 0,
            );
          }
        }
      });
    }
  }

  // 1. _loadCommentData() 메서드 수정
  Future<void> _loadCommentData() async {
    // 상태 업데이트
    setState(() {
      if (_isLoading) {
        _isLoading = true;
      } else {
        _isRefreshing = true;
      }
    });

    try {
      // 부모 댓글 정보 가져오기
      final comment = await _fetchParentComment(widget.commentRoomId);
      await _loadSubComments(isPopular: _isPopularSort);

      // 토론방 및 키워드 정보 가져오기
      DiscussionRoom? discussionRoom;
      Keyword? keyword;


      if (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 600));
      }

      if (mounted) {
        setState(() {
          _parentComment = comment;
          _discussionRoomId = comment.discussion_room;
          _discussionRoom = discussionRoom;
          _keyword = keyword;
          _isLoading = false;
          _isRefreshing = false;
        });

        // 부모 댓글 정보가 로드된 후 좋아요 상태 로드
        _loadParentCommentReaction();
      }
    } catch (e) {
      print('댓글 정보 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        StylishToast.error(context, '댓글 정보를 불러오는 중 오류가 발생했습니다.');
      }
    }
  }

// 2. initState() 메서드에서 _loadParentCommentReaction() 호출 제거
  @override
  void initState() {
    super.initState();

    // 댓글 정보 로드
    _loadCommentData();

    // 빌드 후 콜백으로 사용자 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPreference();
      _loadCommentReactions();
      // _loadParentCommentReaction() 호출 제거 (이제 _loadCommentData() 내에서 호출됨)
    });
  }

  // 부모 댓글 가져오기 (실제 API 구현)
  Future<Comment> _fetchParentComment(int commentId) async {
    try {
      // 실제 API 호출을 통해 댓글 정보 가져오기
      return await _apiService.getCommentById(commentId);
    } catch (e) {
      print('부모 댓글 가져오기 오류: $e');
      // API 오류 시 예외를 상위로 전파
      rethrow;
    }
  }

  // 대댓글 로드 함수
  Future<void> _loadSubComments({bool isPopular = true}) async {
    setState(() {
      _isCommentLoading = true;
    });

    try {
      // 첫 페이지 대댓글 로드 (페이징 지원)
      _currentPage = 1;
      final paginatedResult = await _apiService.getSubComments(
        widget.commentRoomId,
        isPopular: isPopular,
        page: _currentPage,
        limit: _pageSize,
      );

      final subComments = paginatedResult.results;
      _hasMoreSubComments = paginatedResult.hasNext;

      if (mounted) {
        setState(() {
          _subComments = subComments;
          _isCommentLoading = false;
          // _hasMoreSubComments는 위에서 이미 설정됨

          // 댓글 반응 상태 초기화
          _updateLocalCommentReactions();
        });
      }
    } catch (e) {
      print('대댓글 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isCommentLoading = false;
        });
      }
    }
  }

  // 댓글 반응 상태 초기화
  void _updateLocalCommentReactions() {
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

    for (var comment in _subComments) {
      final String? reaction = provider.getCommentReaction(comment.id);
      if (reaction != null) {
        _commentReactions[comment.id] = CommentReaction(
          reactionType: reaction,
          likeCount: comment.like_count ?? 0,
          dislikeCount: comment.dislike_count ?? 0,
        );
      } else {
        // 반응이 없는 경우 초기 상태 설정
        _commentReactions[comment.id] = CommentReaction(
          reactionType: null,
          likeCount: comment.like_count ?? 0,
          dislikeCount: comment.dislike_count ?? 0,
        );
      }
    }
  }

  // 스크롤 이벤트 처리 (대댓글 페이징)
  void _onSubCommentScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMoreSubComments && _hasMoreSubComments) {
        _loadMoreSubComments();
      }
    }
  }

  // 추가 대댓글 로드
  Future<void> _loadMoreSubComments() async {
    if (!_hasMoreSubComments || _isLoadingMoreSubComments) return;

    setState(() {
      _isLoadingMoreSubComments = true;
    });

    try {
      _currentPage++;
      final paginatedResult = await _apiService.getSubComments(
        widget.commentRoomId,
        isPopular: _isPopularSort,
        page: _currentPage,
        limit: _pageSize,
      );

      if (mounted) {
        setState(() {
          _subComments.addAll(paginatedResult.results);
          _hasMoreSubComments = paginatedResult.hasNext;
          _isLoadingMoreSubComments = false;

          // 새로 추가된 댓글에 대한 반응 상태 초기화
          _updateLocalCommentReactions();
        });
      }
    } catch (e) {
      print('추가 대댓글 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoadingMoreSubComments = false;
          _currentPage--; // 실패시 페이지 번호 복구
        });
      }
    }
  }

  // 페이징된 대댓글 리스트 위젯
  Widget _buildPaginatedSubCommentsList() {
    // 차단된 댓글 필터링
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    final filteredComments = _subComments.where((comment) {
      return !provider.isCommentBlocked(comment.id);
    }).toList();

    return Column(
      children: [
        // 정렬 옵션
        _buildSortHeader(filteredComments.length),

        // 댓글 리스트
        if (_isCommentLoading && filteredComments.isEmpty)
          _buildLoadingIndicator()
        else if (filteredComments.isEmpty)
          _buildEmptyComments()
        else
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppTheme.getContainerColor(context),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: AppTheme.isDark(context)
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // 댓글 리스트
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      // 첫 번째 댓글 앞에는 구분선 없음
                      if (filteredComments.isNotEmpty) _buildCommentItem(filteredComments.first, isFirst: true),

                      // 두 번째 댓글부터는 구분선과 함께 표시
                      ...filteredComments.skip(1).map((comment) => _buildCommentItem(comment)),
                    ],
                  ),
                ),

                // 더 보기 버튼
                if (_hasMoreSubComments && !_isLoadingMoreSubComments)
                  _buildLoadMoreButton(),

                // 로딩 인디케이터
                if (_isLoadingMoreSubComments)
                  _buildLoadingMoreIndicator(),

                // 마지막 페이지 알림
                if (!_hasMoreSubComments && _subComments.isNotEmpty)
                  _buildEndOfListMessage(),

                SizedBox(height: 16.h),
              ],
            ),
          ),
      ],
    );
  }

  // 정렬 헤더
  Widget _buildSortHeader(int commentCount) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            '댓글 ${commentCount}개',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Spacer(),
          SortPopupWidget(
            isPopularSort: _isPopularSort,
            onSortChanged: (isPopular) {
              setState(() {
                _isPopularSort = isPopular;
                _currentPage = 1;
                _hasMoreSubComments = true;
                _subComments = [];
              });
              _loadSubComments(isPopular: isPopular);
            },
          ),
        ],
      ),
    );
  }


  // 로딩 인디케이터
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19B3F6)),
        ),
      ),
    );
  }

  // 빈 댓글
  Widget _buildEmptyComments() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.comment_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '아직 댓글이 없습니다',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 더 보기 버튼
  Widget _buildLoadMoreButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      child: OutlinedButton(
        onPressed: _loadMoreSubComments,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Color(0xFF19B3F6).withOpacity(0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          '댓글 더보기',
          style: TextStyle(
            color: Color(0xFF19B3F6),
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 로딩 더 보기
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(20.h),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19B3F6)),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '댓글을 불러오는 중...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 마지막 메시지
  Widget _buildEndOfListMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Text(
          '모든 댓글을 확인하셨습니다',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.isDark(context) ? Colors.grey[500] : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // 시간 포맷 함수
  String _formatTimeAgo(dynamic dateTimeInput) {
    try {
      DateTime dateTime;
      if (dateTimeInput is String) {
        dateTime = DateTime.parse(dateTimeInput);
      } else if (dateTimeInput is DateTime) {
        dateTime = dateTimeInput;
      } else {
        return '알 수 없음';
      }

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
    } catch (e) {
      return '알 수 없음';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF19B3F6)))
            : Column(
          children: [
            // 헤더 영역 - 항상 온전히 표시
            _buildHeaderSection(context),

            // 나머지 콘텐츠 영역
            Expanded(
              child: Stack(
                children: [
                  // 메인 콘텐츠 부분
                  Opacity(
                    opacity: _isRefreshing ? 0.3 : 1.0,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: _isRefreshing
                          ? NeverScrollableScrollPhysics()
                          : BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 원본 댓글 표시
                          _buildParentCommentSection(),
                          SizedBox(height: 12.h),

                          // 대댓글 헤더 경고 메시지
                          _buildWarningMessage(),
                          SizedBox(height: 4.h),

                          // 대댓글 섹션
                          _buildPaginatedSubCommentsList(),
                          SizedBox(height: 20.h),
                        ],
                      ),
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
            ),

            // 입력 영역
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  // 헤더 섹션
  Widget _buildHeaderSection(BuildContext context) {
    String title = "답글";
    String category = "카테고리";

    // 키워드 정보가 있으면 표시
    if (_keyword != null) {
      title = _keyword!.keyword;
      category = _keyword!.category;
    }
    // 키워드 정보가 없지만 부모 댓글이 있는 경우 닉네임 표시
    else if (_parentComment != null) {
      title = "${_parentComment!.nick}님의 댓글";
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 뒤로가기 버튼 - CircleButtonWidget 사용
          CircleButtonWidget(
            context: context,
            onTap: () => context.pop(),
            icon: Icons.chevron_left,
            color: Color(0xFF19B3F6),
            iconSize: 28.sp,
          ),

          SizedBox(width: 12.w),

          // 타이틀과 카테고리
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.isDark(context)
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 욕설 필터링 버튼
          ProfanityFilterButton(),
          SizedBox(width: 8.w),

          // 새로고침 버튼 - CircleButtonWidget 사용
          CircleButtonWidget(
            context: context,
            onTap: () {
              if (!_isRefreshing) {
                _loadCommentData();
              }
            },
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            iconSize: 22.sp,
          ),

        ],
      ),
    );
  }

  // 원본 댓글 섹션
  Widget _buildParentCommentSection() {
    if (_parentComment == null) return SizedBox.shrink();

    return Consumer<UserPreferenceProvider>(
      builder: (context, provider, child) {
        // 시간 포맷팅
        final String timeAgo = _formatTimeAgo(_parentComment!.created_at);

        // 필터링 적용
        String displayNickname = _parentComment!.nick;
        String displayComment = _parentComment!.comment;

        if (provider.isProfanityFilterEnabled) {
          displayNickname = ProfanityFilterUtils.filterText(_parentComment!.nick);
          displayComment = ProfanityFilterUtils.filterText(_parentComment!.comment);
        }

        // 좋아요/싫어요 상태 확인
        final reaction = _parentCommentReaction;
        final int likeCount = reaction?.likeCount ?? _parentComment!.like_count ?? 0;
        final int dislikeCount = reaction?.dislikeCount ?? _parentComment!.dislike_count ?? 0;
        final bool hasLiked = reaction?.reactionType == 'like';
        final bool hasDisliked = reaction?.reactionType == 'dislike';

        return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 닉네임 및 시간
            Row(
              children: [
                Text(
                  displayNickname,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.isDark(context)
                        ? Colors.grey[500]
                        : Colors.grey[500],
                  ),
                ),
                Spacer(),
                // 옵션 메뉴 버튼
                CommentOptionsWidget(
                  comment: _parentComment!,
                  discussionRoomId: _discussionRoomId,
                  isMyComment: provider.isMyComment(_parentComment!.id),
                  onDeleted: () {
                    // 원본 댓글 삭제 시 페이지 종료
                    context.pop();
                  },
                  onBlocked: () {
                    // 원본 댓글 차단 시 페이지 종료
                    context.pop();
                  },
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 댓글 내용
            Text(
              displayComment,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.4,
                color: AppTheme.isDark(context)
                    ? Colors.grey[300]
                    : Colors.black.withOpacity(0.85),
              ),
            ),

            SizedBox(height: 16.h),

            // 좋아요/싫어요 버튼 (수정된 부분)
            Row(
              children: [
                // 좋아요 버튼 - 애니메이션 버튼으로 교체
                _buildAnimatedReactionButton(
                  icon: hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  count: likeCount,
                  isActive: hasLiked,
                  activeColor: Color(0xFF19B3F6),
                  onTap: () => _handleParentLikeComment(hasLiked, hasDisliked),
                ),
                SizedBox(width: 6.w),

                // 싫어요 버튼 - 애니메이션 버튼으로 교체
                _buildAnimatedReactionButton(
                  icon: hasDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  count: dislikeCount,
                  isActive: hasDisliked,
                  activeColor: Color(0xFFE74C3C),
                  onTap: () => _handleParentDislikeComment(hasDisliked, hasLiked),
                ),
              ],
            ),
          ],
        ),
      ),
        );
      },
    );
  }
// 원본 댓글 좋아요 처리
  Future<void> _handleParentLikeComment(bool hasLiked, bool hasDisliked) async {
    if (_parentComment == null) return;

    final commentId = _parentComment!.id;

    // 현재 상태 백업
    final CommentReaction currentReaction = _parentCommentReaction ??
        CommentReaction(
          reactionType: null,
          likeCount: _parentComment!.like_count ?? 0,
          dislikeCount: _parentComment!.dislike_count ?? 0,
        );

    // 먼저 UI 업데이트 (즉시 반응 위해)
    setState(() {
      if (hasLiked) {
        // 이미 좋아요 -> 취소
        _parentCommentReaction = CommentReaction(
          reactionType: null,
          likeCount: currentReaction.likeCount - 1,
          dislikeCount: currentReaction.dislikeCount,
        );
      } else {
        // 좋아요 추가
        _parentCommentReaction = CommentReaction(
          reactionType: 'like',
          likeCount: currentReaction.likeCount + 1,
          // 싫어요 상태였다면 싫어요 카운트 감소
          dislikeCount: hasDisliked
              ? currentReaction.dislikeCount - 1
              : currentReaction.dislikeCount,
        );
      }
    });

    try {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

      // 이미 싫어요 상태인 경우, 백그라운드에서 싫어요 취소 API 호출
      if (hasDisliked) {
        await _apiService.dislikeComment(commentId, isCancel: true);
      }

      // 백그라운드에서 좋아요 상태 변경 API 호출
      final result = await _apiService.likeComment(commentId, isCancel: hasLiked);

      if (result) {
        // API 호출 성공 시 로컬 상태 업데이트
        if (hasLiked) {
          // 이미 좋아요 상태면 취소
          await provider.removeCommentReaction(commentId);
        } else {
          // 좋아요 설정 (싫어요 상태면 싫어요 제거)
          await provider.toggleLike(commentId);
        }
      } else {
        // API 호출 실패 시 원래 상태로 복원
        if (mounted) {
          setState(() {
            _parentCommentReaction = currentReaction;
          });
          StylishToast.error(context, '좋아요 처리 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      print('좋아요 처리 오류: $e');

      // 오류 시 원래 상태로 복원
      if (mounted) {
        setState(() {
          _parentCommentReaction = currentReaction;
        });
        StylishToast.error(context, '좋아요 처리 중 오류가 발생했습니다.');
      }
    }
  }

// 원본 댓글 싫어요 처리
  Future<void> _handleParentDislikeComment(bool hasDisliked, bool hasLiked) async {
    if (_parentComment == null) return;

    final commentId = _parentComment!.id;

    // 현재 상태 백업
    final CommentReaction currentReaction = _parentCommentReaction ??
        CommentReaction(
          reactionType: null,
          likeCount: _parentComment!.like_count ?? 0,
          dislikeCount: _parentComment!.dislike_count ?? 0,
        );

    // 먼저 UI 업데이트 (즉시 반응 위해)
    setState(() {
      if (hasDisliked) {
        // 이미 싫어요 -> 취소
        _parentCommentReaction = CommentReaction(
          reactionType: null,
          likeCount: currentReaction.likeCount,
          dislikeCount: currentReaction.dislikeCount - 1,
        );
      } else {
        // 싫어요 추가
        _parentCommentReaction = CommentReaction(
          reactionType: 'dislike',
          // 좋아요 상태였다면 좋아요 카운트 감소
          likeCount: hasLiked
              ? currentReaction.likeCount - 1
              : currentReaction.likeCount,
          dislikeCount: currentReaction.dislikeCount + 1,
        );
      }
    });

    try {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

      // 이미 좋아요 상태인 경우, 백그라운드에서 좋아요 취소 API 호출
      if (hasLiked) {
        await _apiService.likeComment(commentId, isCancel: true);
      }

      // 백그라운드에서 싫어요 상태 변경 API 호출
      final result = await _apiService.dislikeComment(commentId, isCancel: hasDisliked);

      if (result) {
        // API 호출 성공 시 로컬 상태 업데이트
        if (hasDisliked) {
          // 이미 싫어요 상태면 취소
          await provider.removeCommentReaction(commentId);
        } else {
          // 싫어요 설정 (좋아요 상태면 좋아요 제거)
          await provider.toggleDislike(commentId);
        }
      } else {
        // API 호출 실패 시 원래 상태로 복원
        if (mounted) {
          setState(() {
            _parentCommentReaction = currentReaction;
          });
          StylishToast.error(context, '싫어요 처리 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      print('싫어요 처리 오류: $e');

      // 오류 시 원래 상태로 복원
      if (mounted) {
        setState(() {
          _parentCommentReaction = currentReaction;
        });
        StylishToast.error(context, '싫어요 처리 중 오류가 발생했습니다.');
      }
    }
  }
  // 경고 메시지 위젯
  Widget _buildWarningMessage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16.sp,
            color: AppTheme.isDark(context)
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
          SizedBox(width: 6.w),
          Text(
            "타인에 대한 비방글은 삭제될 수 있습니다",
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.isDark(context)
                  ? Colors.grey[400]
                  : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 대댓글 섹션
  Widget _buildSubCommentsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 대댓글 헤더
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.getContainerColor(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              boxShadow: AppTheme.isDark(context)
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "댓글",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SortPopupWidget(
                  isPopularSort: _isPopularSort,
                  onSortChanged: (isPopular) {
                    setState(() {
                      _isPopularSort = isPopular;
                    });
                    _loadSubComments(isPopular: isPopular);
                  },
                ),
              ],
            ),
          ),

          // 대댓글 로딩 중
          if (_isCommentLoading)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(child: CircularProgressIndicator()),
            )
          // 대댓글이 없는 경우
          else if (_subComments.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.forum_outlined,
                        size: 40.sp,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[600]
                            : Colors.grey[400]),
                    SizedBox(height: 8.h),
                    Text(
                      "아직 답글이 없어요! 첫 답글을 남겨주세요!",
                      style: TextStyle(
                        color: AppTheme.isDark(context)
                            ? Colors.grey[400]
                            : Colors.grey[500],
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 대댓글 리스트 - 구분선 버전
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  // 첫 번째 댓글 앞에는 구분선 없음
                  _buildCommentItem(_subComments.first, isFirst: true),

                  // 두 번째 댓글부터는 구분선과 함께 표시
                  ..._subComments.skip(1).map((comment) => _buildCommentItem(comment)),
                ],
              ),
            ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // 댓글 아이템 위젯 - 구분선 스타일
  Widget _buildCommentItem(Comment comment, {bool isFirst = false}) {
    return Consumer<UserPreferenceProvider>(
      builder: (context, provider, child) {
        // 내 댓글인지 확인
        final isMyComment = provider.isMyComment(comment.id);

        // 필터링 적용
        String displayNickname = comment.nick;
        String displayComment = comment.comment;

        if (provider.isProfanityFilterEnabled) {
          displayNickname = ProfanityFilterUtils.filterText(comment.nick);
          displayComment = ProfanityFilterUtils.filterText(comment.comment);
        }


        // 이 댓글에 좋아요/싫어요 했는지 확인 (로컬 상태 우선)
        CommentReaction? localReaction = _commentReactions[comment.id];

        // 로컬 상태가 없으면 Provider에서 가져옴
        String? userReaction;
        int likeCount = comment.like_count ?? 0;
        int dislikeCount = comment.dislike_count ?? 0;

        if (localReaction != null) {
          userReaction = localReaction.reactionType;
          likeCount = localReaction.likeCount;
          dislikeCount = localReaction.dislikeCount;
        } else {
          userReaction = provider.getCommentReaction(comment.id);
        }

        final bool hasLiked = userReaction == 'like';
        final bool hasDisliked = userReaction == 'dislike';

        // 시간 포맷팅
        final String timeAgo = comment.timeAgo ?? _formatTimeAgo(comment.created_at);

        return Column(
          children: [
            // 첫 번째 댓글이 아닐 경우에만 구분선 표시
            if (!isFirst)
              Divider(
                color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[300],
                thickness: 1,
                height: 1,
              ),

            // 댓글 내용
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임 및 시간
                  Row(
                    children: [
                      Text(
                        displayNickname,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isMyComment ? Color(0xFF19B3F6) : AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.isDark(context)
                              ? Colors.grey[500]
                              : Colors.grey[500],
                        ),
                      ),
                      Spacer(),
                      // 옵션 메뉴 버튼
                      CommentOptionsWidget(
                        comment: comment,
                        discussionRoomId: _discussionRoomId,
                        isMyComment: isMyComment,
                        onDeleted: () => _loadSubComments(isPopular: _isPopularSort),
                        onBlocked: () => _loadSubComments(isPopular: _isPopularSort),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // 댓글 내용
                  Text(
                    displayComment,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.4,
                      color: AppTheme.isDark(context)
                          ? Colors.grey[300]
                          : Colors.black.withOpacity(0.85),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // 좋아요/싫어요 버튼
                  Row(
                    children: [
                      // 좋아요 버튼
                      _buildAnimatedReactionButton(
                        icon: hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        count: likeCount,
                        isActive: hasLiked,
                        activeColor: Color(0xFF19B3F6),
                        onTap: () => _handleLikeComment(comment.id, hasLiked, hasDisliked),
                      ),
                      SizedBox(width: 16.w),

                      // 싫어요 버튼
                      _buildAnimatedReactionButton(
                        icon: hasDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        count: dislikeCount,
                        isActive: hasDisliked,
                        activeColor: Color(0xFFE74C3C),
                        onTap: () => _handleDislikeComment(comment.id, hasDisliked, hasLiked),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  // 애니메이션 버튼
  Widget _buildAnimatedReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(2.r),
          child: Ink(
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacity(0.1)
                  : (AppTheme.isDark(context)
                  ? Colors.grey[800]?.withOpacity(0.3)
                  : Colors.grey[200]?.withOpacity(0.7)),
              borderRadius: BorderRadius.circular(2.r),
              border: Border.all(
                color: isActive
                    ? activeColor.withOpacity(0.4)
                    : (AppTheme.isDark(context)
                    ? Colors.grey[700]!.withOpacity(0.2)
                    : Colors.grey[300]!.withOpacity(0.5)),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16.sp,
                    color: isActive
                        ? activeColor
                        : (AppTheme.isDark(context)
                        ? Colors.grey[400]
                        : Colors.grey[600]),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                      color: isActive
                          ? activeColor
                          : (AppTheme.isDark(context)
                          ? Colors.grey[400]
                          : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // 좋아요 처리
  Future<void> _handleLikeComment(int commentId, bool hasLiked, bool hasDisliked) async {
    // 해당 댓글 찾기
    final commentIndex = _subComments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _subComments[commentIndex];

    // 현재 상태 백업
    final CommentReaction currentReaction = _commentReactions[commentId] ??
        CommentReaction(
          reactionType: null,
          likeCount: comment.like_count ?? 0,
          dislikeCount: comment.dislike_count ?? 0,
        );

    // 먼저 UI 업데이트 (즉시 반응 위해)
    setState(() {
      if (hasLiked) {
        // 이미 좋아요 -> 취소
        _commentReactions[commentId] = CommentReaction(
          reactionType: null,
          likeCount: currentReaction.likeCount - 1,
          dislikeCount: currentReaction.dislikeCount,
        );
      } else {
        // 좋아요 추가
        _commentReactions[commentId] = CommentReaction(
          reactionType: 'like',
          likeCount: currentReaction.likeCount + 1,
          // 싫어요 상태였다면 싫어요 카운트 감소
          dislikeCount: hasDisliked
              ? currentReaction.dislikeCount - 1
              : currentReaction.dislikeCount,
        );
      }
    });

    try {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

      // 이미 싫어요 상태인 경우, 백그라운드에서 싫어요 취소 API 호출
      if (hasDisliked) {
        await _apiService.dislikeComment(commentId, isCancel: true);
      }

      // 백그라운드에서 좋아요 상태 변경 API 호출
      final result = await _apiService.likeComment(commentId, isCancel: hasLiked);

      if (result) {
        // API 호출 성공 시 로컬 상태 업데이트
        if (hasLiked) {
          // 이미 좋아요 상태면 취소
          await provider.removeCommentReaction(commentId);
        } else {
          // 좋아요 설정 (싫어요 상태면 싫어요 제거)
          await provider.toggleLike(commentId);
        }
      } else {
        // API 호출 실패 시 원래 상태로 복원
        if (mounted) {
          setState(() {
            _commentReactions[commentId] = currentReaction;
          });
          StylishToast.error(context, '좋아요 처리 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      print('좋아요 처리 오류: $e');

      // 오류 시 원래 상태로 복원
      if (mounted) {
        setState(() {
          _commentReactions[commentId] = currentReaction;
        });
        StylishToast.error(context, '좋아요 처리 중 오류가 발생했습니다.');
      }
    }
  }

  // 싫어요 처리
  Future<void> _handleDislikeComment(int commentId, bool hasDisliked, bool hasLiked) async {
    // 해당 댓글 찾기
    final commentIndex = _subComments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _subComments[commentIndex];

    // 현재 상태 백업
    final CommentReaction currentReaction = _commentReactions[commentId] ??
        CommentReaction(
          reactionType: null,
          likeCount: comment.like_count ?? 0,
          dislikeCount: comment.dislike_count ?? 0,
        );

    // 먼저 UI 업데이트 (즉시 반응 위해)
    setState(() {
      if (hasDisliked) {
        // 이미 싫어요 -> 취소
        _commentReactions[commentId] = CommentReaction(
          reactionType: null,
          likeCount: currentReaction.likeCount,
          dislikeCount: currentReaction.dislikeCount - 1,
        );
      } else {
        // 싫어요 추가
        _commentReactions[commentId] = CommentReaction(
          reactionType: 'dislike',
          // 좋아요 상태였다면 좋아요 카운트 감소
          likeCount: hasLiked
              ? currentReaction.likeCount - 1
              : currentReaction.likeCount,
          dislikeCount: currentReaction.dislikeCount + 1,
        );
      }
    });

    try {
      final provider = Provider.of<UserPreferenceProvider>(context, listen: false);

      // 이미 좋아요 상태인 경우, 백그라운드에서 좋아요 취소 API 호출
      if (hasLiked) {
        await _apiService.likeComment(commentId, isCancel: true);
      }

      // 백그라운드에서 싫어요 상태 변경 API 호출
      final result = await _apiService.dislikeComment(commentId, isCancel: hasDisliked);

      if (result) {
        // API 호출 성공 시 로컬 상태 업데이트
        if (hasDisliked) {
          // 이미 싫어요 상태면 취소
          await provider.removeCommentReaction(commentId);
        } else {
          // 싫어요 설정 (좋아요 상태면 좋아요 제거)
          await provider.toggleDislike(commentId);
        }
      } else {
        // API 호출 실패 시 원래 상태로 복원
        if (mounted) {
          setState(() {
            _commentReactions[commentId] = currentReaction;
          });
          StylishToast.error(context, '싫어요 처리 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      print('싫어요 처리 오류: $e');

      // 오류 시 원래 상태로 복원
      if (mounted) {
        setState(() {
          _commentReactions[commentId] = currentReaction;
        });
        StylishToast.error(context, '싫어요 처리 중 오류가 발생했습니다.');
      }
    }
  }

  // 하단 입력 섹션
  Widget _buildInputSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이디/비밀번호 입력
          Row(
            children: [
              // 아이디 입력 필드
              Expanded(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -3,
                    intensity: 0.7,
                    shape: NeumorphicShape.flat,
                    lightSource: LightSource.topLeft,
                    color: AppTheme.isDark(context)
                        ? Color(0xFF2A2A36)
                        : Color(0xFFF5F5F5),
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(16.r)),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20.sp,
                        color: Color(0xFF19B3F6),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _idController,
                          decoration: InputDecoration(
                            hintText: "아이디",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.isDark(context)
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // 비밀번호 입력 필드
              Expanded(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -3,
                    intensity: 0.7,
                    shape: NeumorphicShape.flat,
                    lightSource: LightSource.topLeft,
                    color: AppTheme.isDark(context)
                        ? Color(0xFF2A2A36)
                        : Color(0xFFF5F5F5),
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(16.r)),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 20.sp,
                        color: Color(0xFF19B3F6),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "비밀번호",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.isDark(context)
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 댓글 입력 필드
          Container(
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF2A2A36)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Color(0xFF3C3B48)
                    : Color(0xFFE0E0E0),
                width: 1.5,
              ),
              boxShadow: AppTheme.isDark(context)
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 입력 영역
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      enabled: !_isCommenting,
                      minLines: 1,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "생각을 공유해주세요 :)",
                        hintStyle: TextStyle(
                          fontSize: 15.sp,
                          color: AppTheme.isDark(context)
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[300]
                            : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                // 전송 버튼
                Container(
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: _isCommenting
                        ? (AppTheme.isDark(context)
                        ? Colors.grey[700]
                        : Colors.grey[300])
                        : Color(0xFF19B3F6),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: _isCommenting
                            ? Colors.black.withOpacity(0.2)
                            : Color(0xFF19B3F6).withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18.r),
                      onTap:
                      _isCommenting ? null : _submitComment,
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        child: _isCommenting
                            ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22.sp,
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

  // 댓글 제출 처리
  Future<void> _submitComment() async {
    // 입력값 검증
    final String id = _idController.text.trim();
    final String password = _passwordController.text.trim();
    final String comment = _commentController.text.trim();

    if (id.isEmpty || password.isEmpty || comment.isEmpty) {
      StylishToast.error(context, '아이디, 비밀번호, 댓글 내용을 모두 입력해주세요.');
      return;
    }

    setState(() {
      _isCommenting = true;
    });

    try {
      // API 호출하여 댓글 작성
      final result = await _apiService.addComment(
          _discussionRoomId,
          id,
          password,
          id, // 닉네임으로 ID 사용
          comment,
          isSubComment: true,
          parentId: widget.commentRoomId);

      if (result) {
        // Provider로 사용자 정보 저장
        final provider =
        Provider.of<UserPreferenceProvider>(context, listen: false);
        await provider.setNickname(id);
        await provider.setPassword(password);

        // 댓글 목록 갱신 (최신순으로)
        setState(() {
          _isPopularSort = false;
        });

        await _loadSubComments(isPopular: false);

        // 가장 최근 댓글 ID 찾아서 저장 (내 댓글로 표시)
        if (_subComments.isNotEmpty) {
          // 최신순으로 가져왔기 때문에 첫 번째 댓글이 방금 작성한 댓글일 가능성이 높음
          for (var comment in _subComments) {
            if (comment.nick == id) {
              await provider.addCommentId(comment.id);
              break;
            }
          }
        }

        // 입력 필드 초기화
        _commentController.clear();

        // 키보드 숨기기 및 포커스 해제
        FocusScope.of(context).unfocus();

        StylishToast.success(context, '답글이 등록되었습니다.');
      } else {
        StylishToast.error(context, '답글 등록에 실패했습니다.');
      }
    } catch (e) {
      print('답글 작성 오류: $e');
      StylishToast.error(context, '답글 작성 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isCommenting = false;
        });
      }
    }
  }

}