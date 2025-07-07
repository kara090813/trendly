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
import '../app_theme.dart';

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

      try {
        discussionRoom = await _apiService.getDiscussionRoomById(comment.discussion_room);

        // 토론방 정보를 성공적으로 가져온 경우, 해당 토론방의 최신 키워드 정보 가져오기
        if (discussionRoom != null) {
          keyword = await _apiService.getLatestKeywordByDiscussionRoomId(comment.discussion_room);
        }
      } catch (e) {
        print('토론방 또는 키워드 정보 로드 오류: $e');
        // 오류가 발생해도 UI는 계속 진행
      }

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
      // 실제 API 호출을 통해 대댓글 목록 가져오기
      final subComments = await _apiService.getSubComments(
          widget.commentRoomId, isPopular: isPopular);

      if (mounted) {
        setState(() {
          _subComments = subComments;
          _isCommentLoading = false;

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
                          CommentListWidget(
                            comments: _subComments,
                            discussionRoomId: _discussionRoomId,
                            isPopularSort: _isPopularSort,
                            isCommentLoading: _isCommentLoading,
                            commentReactions: _commentReactions,
                            showReplyButton: false,
                            onSortChanged: (isPopular) {
                              setState(() {
                                _isPopularSort = isPopular;
                              });
                              _loadSubComments(isPopular: isPopular);
                            },
                            onRefresh: () => _loadSubComments(isPopular: _isPopularSort),
                          ),
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

          SizedBox(width: 8.w),

          // 공유 버튼 - CircleButtonWidget 사용
          CircleButtonWidget(
            context: context,
            onTap: () {
              // 공유 기능 추가
              StylishToast.show(context, message: '공유 기능은 준비 중입니다.');
            },
            icon: Icons.share_outlined,
            color: AppTheme.isDark(context)
                ? Colors.grey[400]!
                : Colors.grey[500]!,
            iconSize: 22.sp,
          ),
        ],
      ),
    );
  }

  // 원본 댓글 섹션
  Widget _buildParentCommentSection() {
    if (_parentComment == null) return SizedBox.shrink();

    // 시간 포맷팅
    final String timeAgo = _formatTimeAgo(_parentComment!.created_at);

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
                  _parentComment!.nick,
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
              ],
            ),

            SizedBox(height: 12.h),

            // 댓글 내용
            Text(
              _parentComment!.comment,
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
    // 내 댓글인지 확인
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    final isMyComment = provider.isMyComment(comment.id);

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
                    comment.nick,
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
                  // 더보기 버튼 (내 댓글일 때만 작동)
                  isMyComment
                      ? GestureDetector(
                    onTap: () => _showCommentOptions(comment),
                    child: Icon(
                      Icons.more_horiz,
                      size: 16.sp,
                      color: AppTheme.isDark(context)
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                  )
                      : SizedBox.shrink(),
                ],
              ),

              SizedBox(height: 8.h),

              // 댓글 내용
              Text(
                comment.comment,
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

  // 댓글 옵션 표시 (삭제 등)
  void _showCommentOptions(Comment comment) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          backgroundColor: AppTheme.isDark(context) ? Color(0xFF2A2A36) : Colors.white,
          child: Container(
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _deleteComment(comment.id);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.red, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "댓글 삭제하기",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: AppTheme.isDark(context) ? Colors.grey[700] : Colors.grey[300],
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      "취소",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 댓글 삭제 처리
  Future<void> _deleteComment(int commentId) async {
    final provider =
    Provider.of<UserPreferenceProvider>(context, listen: false);
    final password = provider.password;

    if (password == null || password.isEmpty) {
      StylishToast.error(context, '비밀번호가 설정되어 있지 않습니다.');
      return;
    }

    try {
      final result = await _apiService.deleteComment(
          _discussionRoomId, commentId, password);

      if (result) {
        // 댓글 목록 새로고침
        _loadSubComments(isPopular: _isPopularSort);
        StylishToast.success(context, '댓글이 삭제되었습니다.');
      } else {
        StylishToast.error(context, '댓글 삭제에 실패했습니다.');
      }
    } catch (e) {
      print('댓글 삭제 오류: $e');
      StylishToast.error(context, '댓글 삭제 중 오류가 발생했습니다.');
    }
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

  // 시간 포맷팅 함수
  String _formatTimeAgo(DateTime dateTime) {
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