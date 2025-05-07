import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:trendly/widgets/circleButton_widget.dart';
import 'dart:async';

import '../models/_models.dart';
import '../services/api_service.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/_widgets.dart';
import '../app_theme.dart';

class DiscussionRoomScreen extends StatefulWidget {
  final int discussionRoomId;

  const DiscussionRoomScreen({
    Key? key,
    required this.discussionRoomId,
  }) : super(key: key);

  @override
  State<DiscussionRoomScreen> createState() => _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends State<DiscussionRoomScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  // 상태 변수들
  bool _isRealTimeSummaryEnabled = false;
  String? _selectedSentiment; // null, 'positive', 'neutral', 'negative'
  bool _isAnimating = false;
  bool _isLoading = true;
  bool _isCommentLoading = false;

  // 토론방 요약 표시 여부
  bool _isDiscussionReactionEnabled = false;
  bool _isSentimentUpdating = false;
  bool _isCommenting = false;
  String _summaryType = '3줄'; // 기본 요약 타입
  bool _isRefreshing = false;
  bool _isPopularSort = true;
  bool _isDisabled = false;

  // 댓글 반응 로컬 상태 관리 (좋아요/싫어요 즉시 UI 반영용)
  Map<int, CommentReaction> _commentReactions = {};

  // 클래스 변수에 추가
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey _commentSectionKey = GlobalKey();

  // 텍스트 컨트롤러
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 데이터 변수들
  DiscussionRoom? _discussionRoom;
  Keyword? _keyword;
  List<Comment> _comments = [];
  DateTime? _expireTime;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  // 애니메이션 컨트롤러
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  final GlobalKey _positiveKey = GlobalKey();
  final GlobalKey _neutralKey = GlobalKey();
  final GlobalKey _negativeKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // 펄스 애니메이션 컨트롤러 설정
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInOutBack));

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      }
    });

    // 토론방 정보 로드
    _loadDiscussionRoomData();

    // 빌드 후 콜백으로 사용자 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPreference();
      _loadPreviousSentiment();
      _loadCommentReactions();
    });
  }

  // 댓글 반응 데이터 로드 메서드
  void _loadCommentReactions() async {
    final provider =
        Provider.of<UserPreferenceProvider>(context, listen: false);

    // 사용자가 좋아요/싫어요 한 댓글 정보 로드
    await provider.loadCommentReactions();

    // 댓글 목록에 대한 반응 상태 초기화
    if (mounted && _comments.isNotEmpty) {
      setState(() {
        for (var comment in _comments) {
          final String? reaction = provider.getCommentReaction(comment.id);
          if (reaction != null) {
            _commentReactions[comment.id] = CommentReaction(
              reactionType: reaction,
              likeCount: comment.likeCount ?? 0,
              dislikeCount: comment.dislikeCount ?? 0,
            );
          }
        }
      });
    }
  }

  // 토론방 정보 로드 함수
  Future<void> _loadDiscussionRoomData() async {
    // 상태 업데이트
    setState(() {
      if (_isLoading) {
        _isLoading = true;
      } else {
        _isRefreshing = true;
      }
    });

    try {
      // 데이터 로드
      final discussionRoom =
          await _apiService.getDiscussionRoomById(widget.discussionRoomId);
      final keyword = await _apiService
          .getLatestKeywordByDiscussionRoomId(widget.discussionRoomId);
      await _loadComments(isPopular: _isPopularSort);

      if (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 600));
      }

      if (mounted) {
        setState(() {
          _discussionRoom = discussionRoom;
          _keyword = keyword;

          // 토론방 종료 시간 계산
          if (discussionRoom.isClosed) {
            _expireTime = null;
            _isDisabled = true;
            _isDiscussionReactionEnabled = true;
          } else {
            if (discussionRoom.updatedAt != null) {
              _expireTime = discussionRoom.updatedAt!.add(Duration(hours: 24));
            } else {
              _expireTime = discussionRoom.createdAt.add(Duration(hours: 24));
            }
            _updateRemainingTime();
            _startTimer();
          }

          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('토론방 정보 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        StylishToast.error(context, '토론방 정보를 불러오는 중 오류가 발생했습니다.');
      }
    }
  }

  // 댓글 로드 함수
  Future<void> _loadComments({bool isPopular = true}) async {
    setState(() {
      _isCommentLoading = true;
    });

    try {
      final comments = await _apiService
          .getDiscussionComments(widget.discussionRoomId, isPopular: isPopular);

      if (mounted) {
        setState(() {
          _comments = comments;
          _isCommentLoading = false;

          // 댓글 반응 상태 초기화
          _updateLocalCommentReactions();
        });
      }
    } catch (e) {
      print('댓글 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isCommentLoading = false;
        });
      }
    }
  }

  // 댓글 반응 상태 초기화
  void _updateLocalCommentReactions() {
    final provider =
        Provider.of<UserPreferenceProvider>(context, listen: false);

    for (var comment in _comments) {
      final String? reaction = provider.getCommentReaction(comment.id);
      if (reaction != null) {
        _commentReactions[comment.id] = CommentReaction(
          reactionType: reaction,
          likeCount: comment.likeCount ?? 0,
          dislikeCount: comment.dislikeCount ?? 0,
        );
      } else {
        // 반응이 없는 경우 초기 상태 설정
        _commentReactions[comment.id] = CommentReaction(
          reactionType: null,
          likeCount: comment.likeCount ?? 0,
          dislikeCount: comment.dislikeCount ?? 0,
        );
      }
    }
  }

  // 남은 시간 업데이트 함수
  void _updateRemainingTime() {
    if (_expireTime == null) {
      _remainingTime = Duration.zero;
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(_expireTime!)) {
      _remainingTime = Duration.zero;
    } else {
      _remainingTime = _expireTime!.difference(now);
    }
  }

  // 타이머 시작 함수
  void _startTimer() {
    // 기존 타이머 취소
    _timer?.cancel();

    // 1초마다 남은 시간 업데이트
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateRemainingTime();
        });

        // 시간이 다 되면 타이머 중지
        if (_remainingTime.inSeconds <= 0) {
          timer.cancel();
        }
      }
    });
  }

  // 사용자 정보 로드
  void _loadUserPreference() {
    final provider =
        Provider.of<UserPreferenceProvider>(context, listen: false);

    if (provider.nickname != null) {
      _idController.text = provider.nickname!;
    }

    if (provider.password != null) {
      _passwordController.text = provider.password!;
    }
  }

  // 이전 선택 감정 로드
  void _loadPreviousSentiment() async {
    final provider =
        Provider.of<UserPreferenceProvider>(context, listen: false);
    final sentiment =
        await provider.checkRoomSentiment(widget.discussionRoomId);

    if (sentiment != null && mounted) {
      setState(() {
        _selectedSentiment = sentiment;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    _animController.dispose();
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
                                SizedBox(height: 12.h),
                                if (_discussionRoom?.isClosed ?? false)
                                  _buildClosedDiscussionAlert(),
                                SizedBox(height: 12.h),
                                _buildInfoSection(),
                                SizedBox(height: 12.h),
                                _buildSummaryToggleSection(),
                                SizedBox(height: 12.h),
                                _buildDiscussionReactionToggleSection(),
                                SizedBox(height: 12.h),
                                _isDisabled
                                    ? SizedBox.shrink()
                                    : AnimatedSwitcher(
                                        duration: Duration(milliseconds: 600),
                                        transitionBuilder: (Widget child,
                                            Animation<double> animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: ScaleTransition(
                                              scale: Tween<double>(
                                                      begin: 0.95, end: 1.0)
                                                  .animate(CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              )),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _buildEmotionButtonsSection(),
                                      ),
                                _buildWarningMessage(),
                                SizedBox(height: 4.h),
                                _buildCommentSection(),
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
                  _isDisabled ? SizedBox.shrink() : _buildInputSection(),
                ],
              ),
      ),
    );
  }

// 닫힌 토론방 알림 위젯 - 원래 디자인을 유지하면서 개선
  Widget _buildClosedDiscussionAlert() {
    final DateTime closedAt =
        _discussionRoom?.closedAt ?? _discussionRoom!.createdAt;

    final String closedTimeStr =
        '${closedAt.year}년 ${closedAt.month}월 ${closedAt.day}일 ${_formatHour(closedAt.hour)} ${_formatMinutes(closedAt.minute)}분';

    final String timeAgoStr = _formatTimeAgo(closedAt);

    final Color mainColor = Color(0xFF406BD3);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(11.r),
          topRight: Radius.circular(11.r),
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // 상단 구분선
          Container(
            height: 7.h,
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6.r),
                topRight: Radius.circular(6.r),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측 아이콘 영역
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: mainColor.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 28.sp,
                    color: mainColor,
                  ),
                ),

                SizedBox(width: 16.w),

                // 종료 상태 및 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "토론이 종료되었습니다",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 4.h),

                      Text(
                        "이 토론은 종료되어 더 이상 참여할 수 없습니다.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.isDark(context)
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // 종료 시간
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 16.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              "종료: $closedTimeStr",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.isDark(context)
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // 얼마나 지났는지
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16.sp,
                            color: mainColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "$timeAgoStr에 종료됨",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: mainColor,
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
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slide(
        begin: Offset(0, -0.1),
        end: Offset(0, 0),
        duration: 500.ms,
        curve: Curves.easeOutQuad);
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
            color:
                AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
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

  // 감정 선택 버튼 섹션
  Widget _buildEmotionButtonsSection() {
    // 고정 크기로 컨테이너 설정
    final containerHeight = 180.h;

    // 토론방이 종료된 경우 비활성화
    final bool isDisabled = _discussionRoom?.isClosed ?? false;

    return Container(
      key: ValueKey('emotion_container_${_selectedSentiment}'),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      width: double.infinity,
      height: containerHeight,
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 선택 전/후에 따라 다르게 표시
          Text(
            _selectedSentiment == null ? "당신의 의견을 알려주세요" : "당신의 의견",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 16.h),

          // 애니메이션 영역 - Expanded로 남은 공간 채우기
          _isSentimentUpdating
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _selectedSentiment == null
                      ? _buildSelectionButtons() // 선택 전 버튼들
                      : _buildSelectedOpinion() // 선택 후 내용
                  ),
        ],
      ),
    );
  }

// 토론방 요약 토글 섹션
  Widget _buildDiscussionReactionToggleSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 On/Off 토글 스위치
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "토론방 요약",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                // 커스텀 On/Off 토글 스위치
                _buildCustomToggleSwitch(
                  value: _isDiscussionReactionEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isDiscussionReactionEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // 토글이 켜져있을 때만 DiscussionReactionWidget 표시
          if (_isDiscussionReactionEnabled) ...[
            // 상단 구분선
            _buildDivider(),

            SizedBox(height: 16.h),

            // DiscussionReactionWidget 표시
            DiscussionReactionWidget(
              discussionRoom: _discussionRoom,
              keyword: _keyword,
              // 토론방 내부에서는 입장 버튼 표시 안함
              showEnterButtons: false,
            ),

            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionButtons() {
    // 애니메이션 타이밍 중앙 관리를 위한 변수들
    final motionDuration = 550.ms;
    final fadeDuration = 450.ms; // 이동 애니메이션보다 짧게 설정
    final animCurve = Curves.easeOutCirc;
    final fadeCurve = Curves.easeIn;

    return Row(
      children: [
        Expanded(
          child: _buildEmotionButton(
            key: _positiveKey,
            label: "긍정",
            icon: Icons.thumb_up_rounded,
            color: Color(0xFF19B3F6),
            onTap: () => _handleEmotionSelection('positive'),
          )
              .animate()
              .moveX(
                  begin: -100,
                  end: 0,
                  duration: motionDuration,
                  curve: animCurve)
              .scale(
                  begin: Offset(0.6, 0.6),
                  end: Offset(1.0, 1.0),
                  duration: motionDuration,
                  curve: animCurve)
              .fadeIn(begin: 0.0, duration: fadeDuration, curve: fadeCurve),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildEmotionButton(
            key: _neutralKey,
            label: "중립",
            icon: Icons.thumbs_up_down_rounded,
            color: Colors.grey,
            onTap: () => _handleEmotionSelection('neutral'),
          )
              .animate()
              .moveY(
                  begin: 100,
                  end: 0,
                  duration: motionDuration,
                  curve: animCurve)
              .scale(
                  begin: Offset(0.6, 0.6),
                  end: Offset(1.0, 1.0),
                  duration: motionDuration,
                  curve: animCurve)
              .fadeIn(begin: 0.0, duration: fadeDuration, curve: fadeCurve),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildEmotionButton(
            key: _negativeKey,
            label: "부정",
            icon: Icons.thumb_down_rounded,
            color: Color(0xFFE74C3C),
            onTap: () => _handleEmotionSelection('negative'),
          )
              .animate()
              .moveX(
                  begin: 100,
                  end: 0,
                  duration: motionDuration,
                  curve: animCurve)
              .scale(
                  begin: Offset(0.6, 0.6),
                  end: Offset(1.0, 1.0),
                  duration: motionDuration,
                  curve: animCurve)
              .fadeIn(begin: 0.0, duration: fadeDuration, curve: fadeCurve),
        ),
      ],
    );
  }

  // 선택 후 - 선택된 의견과 재선택 버튼
  Widget _buildSelectedOpinion() {
    final EmotionData emotionData = _getEmotionData(_selectedSentiment!);

    return Row(
      children: [
        // 선택된 감정 카드 (넓은 영역)
        Expanded(
          flex: 9,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: emotionData.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: emotionData.color,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    color: emotionData.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: emotionData.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    emotionData.icon,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                )
                    .animate(
                        onComplete: (controller) =>
                            _animController.forward(from: 0.0))
                    .moveY(
                        begin: 20,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic)
                    .scale(
                        begin: Offset(0.6, 0.6),
                        end: Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emotionData.label,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: emotionData.color,
                        ),
                      )
                          .animate()
                          .moveX(
                              begin: 20,
                              end: 0,
                              duration: 400.ms,
                              delay: 200.ms,
                              curve: Curves.easeOutCubic)
                          .fadeIn(duration: 300.ms, delay: 200.ms),
                      SizedBox(height: 4.h),
                      Text(
                        emotionData.description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.isDark(context)
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                          .animate()
                          .moveX(
                              begin: 30,
                              end: 0,
                              duration: 500.ms,
                              delay: 300.ms,
                              curve: Curves.easeOutCubic)
                          .fadeIn(duration: 400.ms, delay: 300.ms),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
              begin: Offset(0.9, 0.9),
              end: Offset(1.0, 1.0),
              duration: 500.ms,
              curve: Curves.easeOutBack),
        ),

        SizedBox(width: 10.w),

        // 리로드 아이콘 (재선택 버튼)
        GestureDetector(
          onTap: _resetEmotionSelection,
          child: Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF2A2A36)
                  : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: AppTheme.isDark(context)
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Center(
              child: Icon(
                Icons.refresh_rounded,
                size: 22.sp,
                color: AppTheme.isDark(context)
                    ? Colors.grey[400]
                    : Colors.grey[700],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .scale(
                begin: Offset(0.5, 0.5),
                end: Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut)
            .rotate(
                begin: -0.5,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutBack),
      ],
    );
  }

  // 감정 버튼 위젯
  Widget _buildEmotionButton({
    Key? key,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: AppTheme.isDark(context)
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 감정에 따른 데이터 구조체
  EmotionData _getEmotionData(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return EmotionData(
          label: "긍정",
          icon: Icons.thumb_up_rounded,
          color: Color(0xFF19B3F6),
          description: "해당 이슈에 대해\n긍정적으로 바라봤어요",
        );
      case 'neutral':
        return EmotionData(
          label: "중립",
          icon: Icons.thumbs_up_down_rounded,
          color: Colors.grey,
          description: "해당 이슈에 대해\n중립적으로 바라봤어요",
        );
      case 'negative':
        return EmotionData(
          label: "부정",
          icon: Icons.thumb_down_rounded,
          color: Color(0xFFE74C3C),
          description: "해당 이슈에 대해\n부정적으로 바라봤어요",
        );
      default:
        return EmotionData(
          label: "",
          icon: Icons.circle,
          color: Colors.grey,
          description: "",
        );
    }
  }

  // 감정 선택 처리 메서드
  void _handleEmotionSelection(String sentiment) async {
    if (_discussionRoom?.isClosed ?? true) return;

    // 애니메이션 플래그 설정
    setState(() {
      _isAnimating = true;
      _isSentimentUpdating = true;
      _selectedSentiment = sentiment; // 즉시 상태 업데이트
    });

    // API 호출 및 로컬 저장
    try {
      // 서버에 감정 의견 업데이트
      int positive = 0, neutral = 0, negative = 0;

      switch (sentiment) {
        case 'positive':
          positive = 1;
          break;
        case 'neutral':
          neutral = 1;
          break;
        case 'negative':
          negative = 1;
          break;
      }

      await _apiService.setDiscussionSentiment(
          widget.discussionRoomId, positive, neutral, negative);

      // 로컬에도 저장
      final provider =
          Provider.of<UserPreferenceProvider>(context, listen: false);
      await provider.setRoomSentiment(widget.discussionRoomId, sentiment);
    } catch (e) {
      print('감정 의견 업데이트 오류: $e');

      // 에러 메시지 표시
      if (mounted) {
        StylishToast.error(context, '의견을 저장하는 중 오류가 발생했습니다.');
      }
    } finally {
      // 상태 업데이트
      if (mounted) {
        setState(() {
          _isSentimentUpdating = false;
        });
      }
    }

    // 애니메이션이 완료된 후 플래그 해제
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  // 감정 재선택 메서드
  // 감정 재선택 메서드
  void _resetEmotionSelection() async {
    if (_discussionRoom?.isClosed ?? true) return;

    setState(() {
      _isAnimating = true;
      _isSentimentUpdating = true;
    });

    try {
      // 현재 선택된 감정에 따라 -1 설정
      int positive = 0;
      int neutral = 0;
      int negative = 0;

      // 현재 선택된 감정에 따라 -1로 설정하여 카운트 감소
      switch (_selectedSentiment) {
        case 'positive':
          positive = -1;
          break;
        case 'neutral':
          neutral = -1;
          break;
        case 'negative':
          negative = -1;
          break;
      }

      // 서버에 감정 의견 업데이트
      await _apiService.setDiscussionSentiment(
          widget.discussionRoomId, positive, neutral, negative);

      // 로컬에서도 제거
      final provider =
          Provider.of<UserPreferenceProvider>(context, listen: false);
      await provider.removeRoomSentiment(widget.discussionRoomId);

      if (mounted) {
        setState(() {
          _selectedSentiment = null;
        });
      }
    } catch (e) {
      print('감정 의견 제거 오류: $e');

      // 에러 메시지 표시
      if (mounted) {
        StylishToast.error(context, '의견을 초기화하는 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSentimentUpdating = false;
        });
      }
    }
  }

  // 헤더 섹션
  Widget _buildHeaderSection(BuildContext context) {
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
          // 뒤로가기 버튼
          CircleButtonWidget(
            context: context,
            onTap: () => context.pop(),
            icon: Icons.chevron_left,
            color: Color(0xFF19B3F6),
            iconSize: 28.sp,
          ),

          SizedBox(width: 12.w),

          // 키워드와 카테고리
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _keyword?.keyword ?? "키워드 로딩 중...",
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
                  _keyword?.category ?? "",
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

          // 새로고침 버튼
          CircleButtonWidget(
            onTap: () {
              if (!_isRefreshing) {
                _loadDiscussionRoomData();
              }
            },
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            iconSize: 22.sp,
            context: context,
          ),

          SizedBox(width: 8.w),

          // 공유 버튼
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

  // 정보 섹션 (토론방 시작 시간, 남은 시간)
  Widget _buildInfoSection() {
    // 토론방 생성 시간 포맷팅
    final DateTime createdAt = _discussionRoom?.createdAt ?? DateTime.now();
    final String dateStr =
        '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일';
    final String timeStr =
        '${_formatHour(createdAt.hour)} ${_formatMinutes(createdAt.minute)}분';

    // 남은 시간 포맷팅
    final bool isExpired =
        _discussionRoom?.isClosed ?? false || _remainingTime.inSeconds <= 0;
    final String hoursStr = isExpired
        ? "00"
        : _remainingTime.inHours.remainder(24).toString().padLeft(2, '0');
    final String minutesStr = isExpired
        ? "00"
        : _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String secondsStr = isExpired
        ? "00"
        : _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: AppTheme.cardDecoration(context),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 토론방 OPEN 부분
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: AppTheme.getContainerColor(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "토론방 OPEN",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF19B3F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          color: Color(0xFF19B3F6),
                          size: 38.sp,
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppTheme.isDark(context)
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 0),
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 남은시간 부분
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: AppTheme.isDark(context)
                      ? (isExpired ? Color(0xFF1D1D26) : Color(0xFF272732))
                      : (isExpired ? Colors.grey[100] : Color(0xFFF9F9F9)),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isExpired ? "종료됨" : "남은시간",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isExpired
                            ? (AppTheme.isDark(context)
                                ? Colors.grey[500]
                                : Colors.grey)
                            : AppTheme.getTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBlock(hoursStr, isDisabled: isExpired),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: isExpired
                                  ? (AppTheme.isDark(context)
                                      ? Colors.grey[600]
                                      : Colors.grey)
                                  : AppTheme.getTextColor(context),
                            ),
                          ),
                        ),
                        _buildTimeBlock(minutesStr, isDisabled: isExpired),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: isExpired
                                  ? (AppTheme.isDark(context)
                                      ? Colors.grey[600]
                                      : Colors.grey)
                                  : AppTheme.getTextColor(context),
                            ),
                          ),
                        ),
                        _buildTimeBlock(secondsStr, isDisabled: isExpired),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 타이머 블록 위젯
  Widget _buildTimeBlock(String time, {bool isDisabled = false}) {
    return Container(
      width: 48.w,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? (isDisabled ? Color(0xFF252530) : Color(0xFF2C2C38))
            : (isDisabled ? Colors.grey[200] : Colors.white),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: AppTheme.isDark(context)
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDisabled ? 0.25 : 0.4),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDisabled ? 0.1 : 0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.isDark(context)
              ? (isDisabled ? Colors.grey[600] : Colors.grey[300])
              : (isDisabled ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  // 실검 요약 토글 섹션
  Widget _buildSummaryToggleSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 On/Off 토글 스위치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "실검 요약",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              // 커스텀 On/Off 토글 스위치
              _buildCustomToggleSwitch(
                value: _isRealTimeSummaryEnabled,
                onChanged: (value) {
                  setState(() {
                    _isRealTimeSummaryEnabled = value;
                  });
                },
              ),
            ],
          ),

          // 토글이 켜져있을 때만 요약 종류 토글 및 내용 표시
          if (_isRealTimeSummaryEnabled) ...[
            SizedBox(height: 20.h),

            // 상단 구분선 - 더 밝은 색상으로 변경
            _buildDivider(),

            // 새로운 3분할 토글 - 구분선 내에 배치
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: _buildSummaryToggle(),
            ),

            SizedBox(height: 8.h),

            // 선택된 유형에 따른 요약 내용
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<String>(_summaryType),
                child: _buildSummaryContent(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.isDark(context)
              ? [
                  Colors.grey[800]!.withOpacity(0.5),
                  Colors.grey[700]!,
                  Colors.grey[800]!.withOpacity(0.5),
                ]
              : [
                  Colors.grey[300]!.withOpacity(0.5),
                  Colors.grey[200]!,
                  Colors.grey[300]!.withOpacity(0.5),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  // 커스텀 토글 스위치 (On/Off)
  Widget _buildCustomToggleSwitch({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 52.w,
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: value
              ? Color(0xFF19B3F6)
              : (AppTheme.isDark(context)
                  ? Colors.grey[700]
                  : Colors.grey[300]),
          boxShadow: AppTheme.isDark(context)
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              duration: Duration(milliseconds: 200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 요약 종류 3버전 토글 버튼 (3줄, 짧은 글, 긴 글)
  Widget _buildSummaryToggle() {
    final double totalWidth = 230.w; // 너비 유지
    final double buttonHeight = 40.h; // 높이 약간 증가

    // 요약 타입에 따른 인덱스 계산
    final int selectedIndex = ['3줄', '짧은 글', '긴 글'].indexOf(_summaryType);

    return Container(
      width: totalWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: AppTheme.isDark(context) ? Color(0xFF2A2A36) : Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Stack(
        children: [
          // 선택 인디케이터 (슬라이딩 효과)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: (totalWidth / 3) * selectedIndex,
            top: 0,
            bottom: 0,
            width: totalWidth / 3,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF19B3F6),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF19B3F6).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  ['3줄', '짧은 글', '긴 글'][selectedIndex],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().scale(
                begin: Offset(0.95, 0.95),
                end: Offset(1.0, 1.0),
                duration: 300.ms,
                curve: Curves.easeOutCubic),
          ),

          // 터치 영역과 라벨들
          Row(
            children: List.generate(
              ['3줄', '짧은 글', '긴 글'].length,
              (index) => Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () {
                      setState(() {
                        _summaryType = ['3줄', '짧은 글', '긴 글'][index];
                      });
                    },
                    child: Center(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: selectedIndex == index ? 0.0 : 1.0,
                        child: Text(
                          ['3줄', '짧은 글', '긴 글'][index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.isDark(context)
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 요약 내용 표시
  Widget _buildSummaryContent() {
    if (_keyword == null) {
      return Center(child: Text("요약 정보가 없습니다."));
    }

    // 요약 타입에 따른 내용 반환
    switch (_summaryType) {
      case '3줄':
        if (_keyword!.type1.isEmpty) {
          return Text(
            "3줄 요약 정보가 없습니다.",
            style: TextStyle(
              color: AppTheme.getTextColor(context),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _keyword!.type1.asMap().entries.map((entry) {
            int index = entry.key;
            String line = entry.value;

            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    margin: EdgeInsets.only(right: 10.w, top: 2.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B3F6).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF19B3F6),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.5,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[300]
                            : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case '짧은 글':
        return Text(
          _keyword!.type2.isNotEmpty ? _keyword!.type2 : "짧은 글 요약 정보가 없습니다.",
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.5,
            color:
                AppTheme.isDark(context) ? Colors.grey[300] : Colors.grey[800],
          ),
        );

      case '긴 글':
        return Text(
          _keyword!.type3.isNotEmpty ? _keyword!.type3 : "긴 글 요약 정보가 없습니다.",
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.5,
            color:
                AppTheme.isDark(context) ? Colors.grey[300] : Colors.grey[800],
          ),
        );

      default:
        return Text(
          "요약 정보가 없습니다.",
          style: TextStyle(
            color: AppTheme.getTextColor(context),
          ),
        );
    }
  }

  // 댓글 섹션
  Widget _buildCommentSection() {
    return CommentListWidget(
      key: _commentSectionKey,
      comments: _comments,
      discussionRoomId: widget.discussionRoomId,
      isPopularSort: _isPopularSort,
      isCommentLoading: _isCommentLoading,
      commentReactions: _commentReactions,
      onSortChanged: (isPopular) {
        setState(() {
          _isPopularSort = isPopular;
        });
        _loadComments(isPopular: isPopular);
      },
      onRefresh: () => _loadComments(isPopular: _isPopularSort),
    );
  }

  // 댓글 섹션으로 스크롤
  // 댓글 섹션으로 스크롤 - 간단한 수동 계산 버전
  void _scrollToComments() {
    // 키보드 닫기
    FocusScope.of(context).unfocus();

    // 기본 높이 값 (ScreenUtil 사용)
    double baseScrollHeight = 420.h;

    // 토글된 요소별 추가 높이 (ScreenUtil 사용)
    double realTimeSummaryHeight = 150.h;
    double discussionReactionHeight = 340.h;

    // 요약 타입별 추가 높이 (ScreenUtil 사용)
    Map<String, double> summaryTypeHeights = {
      '3줄': 200.h,
      '짧은 글': 240.h,
      '긴 글': 600.h,
    };

    // 수동으로 스크롤 위치 계산
    double scrollPosition = baseScrollHeight;

    // 실검 요약이 활성화된 경우
    if (_isRealTimeSummaryEnabled) {
      // 기본 컨테이너 높이
      scrollPosition += realTimeSummaryHeight;

      // 선택된 요약 타입에 따른 추가 높이
      if (summaryTypeHeights.containsKey(_summaryType)) {
        scrollPosition += summaryTypeHeights[_summaryType]!;
      }
    }

    // 토론방 요약이 활성화된 경우
    if (_isDiscussionReactionEnabled) {
      scrollPosition += discussionReactionHeight;
    }

    // 계산된 위치로 스크롤 (애니메이션 없이)
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(scrollPosition);
    }
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
          widget.discussionRoomId,
          id,
          password,
          id, // 닉네임으로 ID 사용
          comment);

      if (result) {
        // 댓글 등록 성공

        // Provider로 사용자 정보 저장
        final provider =
            Provider.of<UserPreferenceProvider>(context, listen: false);
        await provider.setNickname(id);
        await provider.setPassword(password);

        // 댓글 목록 갱신 (최신순으로)
        setState(() {
          _isPopularSort = false;
        });

        await _loadComments(isPopular: false);

        // 가장 최근 댓글 ID 찾아서 저장 (내 댓글로 표시)
        if (_comments.isNotEmpty) {
          // 최신순으로 가져왔기 때문에 첫 번째 댓글이 방금 작성한 댓글일 가능성이 높음
          for (var comment in _comments) {
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

        // 즉시 댓글 섹션으로 스크롤
        _scrollToComments();

        StylishToast.success(context, '댓글이 등록되었습니다.');
      } else {
        StylishToast.error(context, '댓글 등록에 실패했습니다.');
      }
    } catch (e) {
      print('댓글 작성 오류: $e');
      StylishToast.error(context, '댓글 작성 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isCommenting = false;
        });
      }
    }
  }

  // 하단 입력 섹션
  // 하단 입력 섹션
  Widget _buildInputSection() {
    // 토론방이 종료된 경우 입력 비활성화
    final bool isDisabled = _discussionRoom?.isClosed ?? false;

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
                    color: isDisabled
                        ? (AppTheme.isDark(context)
                            ? Color(0xFF252530)
                            : Colors.grey[200])
                        : (AppTheme.isDark(context)
                            ? Color(0xFF2A2A36)
                            : Color(0xFFF5F5F5)),
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
                        color: isDisabled ? Colors.grey : Color(0xFF19B3F6),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _idController,
                          enabled: !isDisabled,
                          decoration: InputDecoration(
                            hintText: "닉네임",
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
                            color: isDisabled
                                ? Colors.grey
                                : AppTheme.getTextColor(context),
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
                    color: isDisabled
                        ? (AppTheme.isDark(context)
                            ? Color(0xFF252530)
                            : Colors.grey[200])
                        : (AppTheme.isDark(context)
                            ? Color(0xFF2A2A36)
                            : Color(0xFFF5F5F5)),
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
                        color: isDisabled ? Colors.grey : Color(0xFF19B3F6),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          enabled: !isDisabled,
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
                            color: isDisabled
                                ? Colors.grey
                                : AppTheme.getTextColor(context),
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
              color:
                  AppTheme.isDark(context) ? Color(0xFF2A2A36) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDisabled
                    ? (AppTheme.isDark(context)
                        ? Colors.grey[700]!
                        : Colors.grey[300]!)
                    : (AppTheme.isDark(context)
                        ? Color(0xFF3C3B48)
                        : Color(0xFFE0E0E0)),
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
                      enabled: !isDisabled && !_isCommenting,
                      minLines: 1,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: isDisabled ? "종료된 토론방입니다" : "생각을 공유해주세요 :)",
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
                    color: isDisabled || _isCommenting
                        ? (AppTheme.isDark(context)
                            ? Colors.grey[700]
                            : Colors.grey[300])
                        : Color(0xFF19B3F6),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDisabled || _isCommenting
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
                          isDisabled || _isCommenting ? null : _submitComment,
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

  // 시간 포맷팅 함수들
  String _formatHour(int hour) {
    if (hour == 0) return '오전 12시';
    if (hour == 12) return '오후 12시';

    if (hour < 12) {
      return '오전 ${hour}시';
    } else {
      return '오후 ${hour - 12}시';
    }
  }

  String _formatMinutes(int minutes) {
    return minutes.toString().padLeft(2, '0');
  }

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
