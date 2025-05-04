import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/_models.dart';
import '../services/api_service.dart';
import '../providers/user_preference_provider.dart';
import '_widgets.dart';
import '../app_theme.dart';

class CommentListWidget extends StatefulWidget {
  final List<Comment> comments;
  final int discussionRoomId;
  final bool isPopularSort;
  final bool isCommentLoading;
  final Map<int, CommentReaction> commentReactions;
  final Function(bool) onSortChanged;
  final Function() onRefresh;
  final bool showReplyButton;

  const CommentListWidget({
    Key? key,
    required this.comments,
    required this.discussionRoomId,
    required this.isPopularSort,
    required this.isCommentLoading,
    required this.commentReactions,
    required this.onSortChanged,
    required this.onRefresh,
    this.showReplyButton = true,
  }) : super(key: key);

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  final ApiService _apiService = ApiService();
  Map<int, CommentReaction> _localCommentReactions = {};

  @override
  void initState() {
    super.initState();
    _localCommentReactions = Map.from(widget.commentReactions);
  }

  @override
  void didUpdateWidget(CommentListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentReactions != widget.commentReactions) {
      _localCommentReactions = Map.from(widget.commentReactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        children: [
          // 댓글 헤더
          _buildCommentHeader(context),

          // 댓글 로딩 중
          if (widget.isCommentLoading)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(child: CircularProgressIndicator()),
            )
          // 댓글이 없는 경우
          else if (widget.comments.isEmpty)
            _buildEmptyCommentMessage()
          // 댓글 리스트
          else
            _buildCommentList(),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "댓글",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              SortPopupWidget(
                isPopularSort: widget.isPopularSort,
                onSortChanged: widget.onSortChanged,
              ),
            ],
          ),
        ),
        Divider(
          color: AppTheme.isDark(context)
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.1),
          thickness: 1,
          height: 0,
        ),
      ],
    );
  }



  Widget _buildEmptyCommentMessage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 40.sp,
              color: AppTheme.isDark(context)
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Text(
              "아직 의견이 없어요! 첫 의견을 남겨주세요!",
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
    );
  }

  Widget _buildCommentList() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: widget.comments.length,
      separatorBuilder: (context, index) => Divider(
        color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[300],
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        return _buildCommentItem(widget.comments[index]);
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    // 내 댓글인지 확인
    final provider = Provider.of<UserPreferenceProvider>(context, listen: false);
    final isMyComment = provider.isMyComment(comment.id);

    // 이 댓글에 좋아요/싫어요 했는지 확인 (로컬 상태 우선)
    CommentReaction? localReaction = _localCommentReactions[comment.id];

    // 로컬 상태가 없으면 Provider에서 가져옴
    String? userReaction;
    int likeCount = comment.likeCount ?? 0;
    int dislikeCount = comment.dislikeCount ?? 0;

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
    final String timeAgo = comment.timeAgo ?? _formatTimeAgo(comment.createdAt);

    return Stack(
      children: [
        // 댓글 내용
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
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
                ],
              ),

              SizedBox(height: 10.h),

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

              SizedBox(height: 12.h),

              // 좋아요/싫어요/답글 수
              Row(
                children: [
                  // 좋아요 버튼
                  _buildAnimatedReactionButton(
                    icon: hasLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    count: likeCount,
                    isActive: hasLiked,
                    activeColor: Color(0xFF19B3F6),
                    onTap: () => _handleLikeComment(
                        comment.id, hasLiked, hasDisliked),
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
                    onTap: () => _handleDislikeComment(
                        comment.id, hasDisliked, hasLiked),
                  ),
                  Spacer(),

                  // 답글 버튼
                  if (widget.showReplyButton)
                    InkWell(
                      onTap: () {
                        context.push('/comment/${comment.id}');
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16.sp,
                            color: AppTheme.isDark(context)
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            comment.subCommentCount.toString(), // 속성 이름이 이렇게 되어 있는지 확인
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppTheme.isDark(context)
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
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

        // 삭제 버튼 (오른쪽 상단에 배치)
        Positioned(
          top: 16.h,
          right: 16.w,
          child: DeleteButtonWidget(
            onTap: () => _showDeletePasswordDialog(comment.id),
            size: 24,
          ),
        ),
      ],
    );
  }

  // 좋아요/싫어요 버튼에 애니메이션 효과 추가
  Widget _buildAnimatedReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: isActive ? 1.0 : 1.0),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: Row(
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
                SizedBox(width: 4.w),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                    isActive ? FontWeight.w500 : FontWeight.normal,
                    color: isActive
                        ? activeColor
                        : (AppTheme.isDark(context)
                        ? Colors.grey[400]
                        : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 비밀번호 입력 팝업을 표시하고 삭제 처리
  Future<void> _showDeletePasswordDialog(int commentId) async {
    final password = await PasswordPopupWidget.show(
      context,
      title: "댓글 삭제",
      message: "이 댓글을 삭제하려면 암호를 입력하세요",
      confirmButtonText: "삭제",
      cancelButtonText: "취소",
    );

    // 암호가 입력된 경우 삭제 처리
    if (password != null && password.isNotEmpty) {
      _deleteCommentWithPassword(commentId, password);
    }
  }

  // 암호를 사용한 댓글 삭제 처리
  Future<void> _deleteCommentWithPassword(int commentId, String password) async {
    try {
      final result = await _apiService.deleteComment(
          widget.discussionRoomId, commentId, password);

      if (result) {
        // 댓글 목록 새로고침
        widget.onRefresh();
        StylishToast.success(context, '댓글이 삭제되었습니다.');
      } else {
        StylishToast.error(context, '댓글 삭제에 실패했습니다. 암호가 올바른지 확인하세요.');
      }
    } catch (e) {
      print('댓글 삭제 오류: $e');
      StylishToast.error(context, '댓글 삭제 중 오류가 발생했습니다.');
    }
  }

  // 좋아요 처리
  Future<void> _handleLikeComment(int commentId, bool hasLiked, bool hasDisliked) async {
    // 해당 댓글 찾기
    final commentIndex = widget.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = widget.comments[commentIndex];

    // 현재 상태 백업
    final CommentReaction currentReaction = _localCommentReactions[commentId] ??
        CommentReaction(
          reactionType: null,
          likeCount: comment.likeCount ?? 0,
          dislikeCount: comment.dislikeCount ?? 0,
        );

    // 먼저 UI 업데이트 (즉시 반응 위해)
    setState(() {
      if (hasLiked) {
        // 이미 좋아요 -> 취소
        _localCommentReactions[commentId] = CommentReaction(
          reactionType: null,
          likeCount: currentReaction.likeCount - 1,
          dislikeCount: currentReaction.dislikeCount,
        );
      } else {
        // 좋아요 추가
        _localCommentReactions[commentId] = CommentReaction(
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
            _localCommentReactions[commentId] = currentReaction;
          });
          StylishToast.error(context, '좋아요 처리 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      print('좋아요 처리 오류: $e');

      // 오류 시 원래 상태로 복원
      if (mounted) {
        setState(() {
          _localCommentReactions[commentId] = currentReaction;
        });
        StylishToast.error(context, '좋아요 처리 중 오류가 발생했습니다.');
      }
    }
  }

  // 싫어요 처리
  Future<void> _handleDislikeComment(int commentId, bool hasDisliked, bool hasLiked) async {
    // 해당 댓글 찾기
    final commentIndex = widget.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = widget.comments[commentIndex];

    // 현재 상태 백업
    final CommentReaction currentReaction = _localCommentReactions[commentId] ??
        CommentReaction(
          reactionType: null,
          likeCount: comment.likeCount ?? 0,
          dislikeCount: comment.dislikeCount ?? 0,
        );

    // 먼저 UI 업데이트 (즉시 반응 위해)
    setState(() {
      if (hasDisliked) {
        // 이미 싫어요 -> 취소
        _localCommentReactions[commentId] = CommentReaction(
          reactionType: null,
          likeCount: currentReaction.likeCount,
          dislikeCount: currentReaction.dislikeCount - 1,
        );
      } else {
        // 싫어요 추가
        _localCommentReactions[commentId] = CommentReaction(
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
            _localCommentReactions[commentId] = currentReaction;
          });
          StylishToast.error(context, '싫어요 처리 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      print('싫어요 처리 오류: $e');

      // 오류 시 원래 상태로 복원
      if (mounted) {
        setState(() {
          _localCommentReactions[commentId] = currentReaction;
        });
        StylishToast.error(context, '싫어요 처리 중 오류가 발생했습니다.');
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