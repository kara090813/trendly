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
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  // 상태 변수들
  bool _isRealTimeSummaryEnabled = false;
  String? _selectedSentiment; // null, 'positive', 'neutral', 'negative'
  bool _isAnimating = false;
  bool _isLoading = true;
  bool _isCommentLoading = false;
  bool _isSentimentUpdating = false;
  bool _isCommenting = false;
  String _summaryType = '3줄'; // 기본 요약 타입
  bool _isRefreshing = false;  // 새로고침 진행 중인지 상태

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

    // 빌드 후 콜백으로 사용자 정보 로드 (오류 수정)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPreference();
      _loadPreviousSentiment();
    });
  }

  // 토론방 정보 로드 함수 수정
  Future<void> _loadDiscussionRoomData() async {
    // 새로고침 시작 시 상태 업데이트
    setState(() {
      if (_isLoading) {
        // 초기 로딩인 경우
        _isLoading = true;
      } else {
        // 새로고침인 경우
        _isRefreshing = true;
      }
    });

    try {
      // 데이터 로드 로직
      final discussionRoom =
      await _apiService.getDiscussionRoomById(widget.discussionRoomId);
      final keyword = await _apiService
          .getLatestKeywordByDiscussionRoomId(widget.discussionRoomId);
      await _loadComments(isPopular: true);

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
          _isRefreshing = false; // 새로고침 완료
        });
      }
    } catch (e) {
      print('토론방 정보 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토론방 정보를 불러오는 중 오류가 발생했습니다.')),
        );
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

  // 사용자 정보 로드 - 오류 수정
  void _loadUserPreference() {
    // 오류가 발생하지 않도록 빌드 단계에서 분리하여 호출
    final provider =
    Provider.of<UserPreferenceProvider>(context, listen: false);

    // 필요한 경우에만 기본 정보 로드 (직접 호출하지 않음)
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
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF19B3F6)))
            : Column(
          children: [
            // 헤더 영역 - 항상 온전히 표시 (새로고침 시에도)
            _buildHeaderSection(context),

            // 나머지 콘텐츠 영역 - 새로고침 효과 적용
            Expanded(
              child: Stack(
                children: [
                  // 메인 콘텐츠 부분
                  Opacity(
                    opacity: _isRefreshing ? 0.3 : 1.0,
                    child: SingleChildScrollView(
                      physics: _isRefreshing
                          ? NeverScrollableScrollPhysics()
                          : BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          _buildInfoSection(),
                          SizedBox(height: 12.h),
                          _buildSummaryToggleSection(),
                          SizedBox(height: 12.h),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 600),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.95, end: 1.0)
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

                  // 간소화된 새로고침 오버레이
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
            ),

            // 입력 영역
            _buildInputSection(),
          ],
        ),
      ),
    );
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
            color: Colors.grey[600],
          ),
          SizedBox(width: 6.w),
          Text(
            "타인에 대한 비방글은 삭제될 수 있습니다",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
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
      key: ValueKey('emotion_container'),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: isDisabled
          ? _buildDisabledEmotionSection() // 토론방 종료시 표시
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 - 선택 전/후에 따라 다르게 표시
          Text(
            _selectedSentiment == null ? "당신의 의견을 알려주세요" : "당신의 의견",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
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

  // 비활성화된 감정 선택 섹션
  Widget _buildDisabledEmotionSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 40.sp,
          color: Colors.grey[400],
        ),
        SizedBox(height: 16.h),
        Text(
          "종료된 토론방입니다",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "더 이상 의견을 남길 수 없습니다",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
                          color: Colors.grey[700],
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
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
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
                color: Colors.grey[700],
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
            boxShadow: [
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('의견을 저장하는 중 오류가 발생했습니다.')),
        );
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
  void _resetEmotionSelection() async {
    if (_discussionRoom?.isClosed ?? true) return;

    setState(() {
      _isAnimating = true;
      _isSentimentUpdating = true;
    });

    try {
      // 서버에서 감정 의견 제거 (0으로 설정)
      await _apiService.setDiscussionSentiment(
          widget.discussionRoomId, 0, 0, 0);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('의견을 초기화하는 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSentimentUpdating = false;
        });
      }
    }

    // 애니메이션이 완료된 후 플래그 해제
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  // 헤더 섹션
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: [
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
          _buildCircleButton(
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  _keyword?.category ?? "",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 새로고침 버튼
          _buildCircleButton(
            onTap: () {
              if (!_isRefreshing) {
                _loadDiscussionRoomData();
              }
            },
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            iconSize: 22.sp,
          ),

          SizedBox(width: 8.w),

          // 공유 버튼
          _buildCircleButton(
            onTap: () {
              // 공유 기능 추가
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('공유 기능은 준비 중입니다.')),
              );
            },
            icon: Icons.cloud_upload_outlined,
            color: Colors.grey[500]!,
            iconSize: 22.sp,
          ),
        ],
      ),
    );
  }

  // 원형 버튼 위젯
  Widget _buildCircleButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 3,
              spreadRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 토론방 OPEN 부분
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 0),
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
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
                  color: isExpired ? Colors.grey[100] : Color(0xFFF9F9F9),
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
                        color: isExpired ? Colors.grey : Colors.black,
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
                              color: isExpired ? Colors.grey : Colors.black,
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
                              color: isExpired ? Colors.grey : Colors.black,
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
        color: isDisabled ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
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
          color: isDisabled ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

  // 실검 요약 토글 섹션
  Widget _buildSummaryToggleSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
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
            SizedBox(height: 16.h),
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            SizedBox(height: 12.h),

            // 요약 유형 토글 (3줄, 짧은 글, 긴 글)
            Align(alignment: Alignment.center, child: _buildSummaryToggle()),
            SizedBox(height: 12.h),
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            SizedBox(height: 16.h),

            // 선택된 유형에 따른 요약 내용
            _buildSummaryContent(),
          ],
        ],
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
          color: value ? Color(0xFF19B3F6) : Colors.grey[300],
          boxShadow: [
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
    final double totalWidth = 230.w; // 조금 더 넓게 설정
    final double buttonWidth = totalWidth / 3;
    final double buttonHeight = 31.h;

    // 요약 타입에 따른 인덱스 계산
    final int selectedIndex = ['3줄', '짧은 글', '긴 글'].indexOf(_summaryType);

    return Container(
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
                borderRadius: BorderRadius.circular(15.r),
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
            left: selectedIndex * buttonWidth,
            top: 0,
            // 상단에 위치하여 튀어나온 효과 표현
            child: Container(
              width: buttonWidth,
              height: buttonHeight + 4.h, // 살짝 더 큰 높이로 튀어나옴
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
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

          // 터치 가능한 버튼 텍스트 (포지션 고정)
          Positioned(
            top: 2.h, // 파란색 배경과 같은 위치
            child: SizedBox(
              width: totalWidth,
              height: buttonHeight,
              child: Row(
                children: List.generate(
                  ['3줄', '짧은 글', '긴 글'].length,
                      (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _summaryType = ['3줄', '짧은 글', '긴 글'][index];
                        });
                      },
                      child: Container(
                        height: buttonHeight,
                        alignment: Alignment.center,
                        color: Colors.transparent, // 투명 배경으로 탭 이벤트만 받음
                        child: Text(
                          ['3줄', '짧은 글', '긴 글'][index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            color: index == selectedIndex
                                ? Colors.black
                                : Colors.white,
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
          return Text("3줄 요약 정보가 없습니다.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _keyword!.type1
              .map((line) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ))
              .toList(),
        );

      case '짧은 글':
        return Text(
          _keyword!.type2.isNotEmpty ? _keyword!.type2 : "짧은 글 요약 정보가 없습니다.",
          style: TextStyle(
            fontSize: 15.sp,
            height: 1.5,
            color: Colors.grey[800],
          ),
        );

      case '긴 글':
        return Text(
          _keyword!.type3.isNotEmpty ? _keyword!.type3 : "긴 글 요약 정보가 없습니다.",
          style: TextStyle(
            fontSize: 15.sp,
            height: 1.5,
            color: Colors.grey[800],
          ),
        );

      default:
        return Text("요약 정보가 없습니다.");
    }
  }

  // 댓글 섹션
  Widget _buildCommentSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 댓글 정렬 헤더
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                _showSortOptions(context);
              },
              child: Row(
                children: [
                  Text(
                    "추천순",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18.sp,
                    color: Color(0xFF19B3F6),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // 댓글 로딩 중
          if (_isCommentLoading)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(child: CircularProgressIndicator()),
            )
          // 댓글이 없는 경우
          else if (_comments.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.forum_outlined,
                        size: 40.sp, color: Colors.grey[400]),
                    SizedBox(height: 8.h),
                    Text(
                      "아직 의견이 없어요! 첫 의견을 남겨주세요!",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 댓글 리스트
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: _comments
                    .map((comment) => _buildCommentItem(comment))
                    .toList(),
              ),
            ),

          SizedBox(height: 12.h),
        ],
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
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _loadComments(isPopular: true);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      "추천순",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF19B3F6),
                      ),
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _loadComments(isPopular: false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      "최신순",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
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

  // 댓글 아이템 위젯
  Widget _buildCommentItem(Comment comment) {
    // 내 댓글인지 확인
    final provider =
    Provider.of<UserPreferenceProvider>(context, listen: false);
    final isMyComment = provider.isMyComment(comment.id);

    // 이 댓글에 좋아요/싫어요 했는지 확인 (구현되지 않았으므로 기본값 사용)
    final bool hasLiked = false;
    final bool hasDisliked = false;

    // 시간 포맷팅
    final String timeAgo = comment.timeAgo ?? _formatTimeAgo(comment.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
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
                  comment.nick,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isMyComment ? Color(0xFF19B3F6) : Colors.black87,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[500],
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
                    color: Colors.grey[400],
                  ),
                )
                    : SizedBox.shrink(),
              ],
            ),

            SizedBox(height: 10.h),

            // 댓글 내용
            Text(
              comment.comment,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.4,
                color: Colors.black.withOpacity(0.85),
              ),
            ),

            SizedBox(height: 12.h),

            // 좋아요/싫어요/댓글 수
            Row(
              children: [
                // 좋아요
                InkWell(
                  onTap: () => _handleLikeComment(comment.id, hasLiked),
                  child: Row(
                    children: [
                      Icon(
                        hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 16.sp,
                        color: hasLiked ? Color(0xFF19B3F6) : Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        (comment.likeCount ?? 0).toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                          hasLiked ? FontWeight.w500 : FontWeight.normal,
                          color:
                          hasLiked ? Color(0xFF19B3F6) : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),

                // 싫어요
                InkWell(
                  onTap: () => _handleDislikeComment(comment.id, hasDisliked),
                  child: Row(
                    children: [
                      Icon(
                        hasDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        size: 16.sp,
                        color:
                        hasDisliked ? Color(0xFFE74C3C) : Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        (comment.dislikeCount ?? 0).toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                          hasDisliked ? FontWeight.w500 : FontWeight.normal,
                          color: hasDisliked
                              ? Color(0xFFE74C3C)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),

                // 댓글 수 (답글)
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      (comment.replies ?? 0).toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
                Divider(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 설정되어 있지 않습니다.')),
      );
      return;
    }

    try {
      final result = await _apiService.deleteComment(
          widget.discussionRoomId, commentId, password);

      if (result) {
        // 댓글 목록 새로고침
        _loadComments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글이 삭제되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('댓글 삭제 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  // 좋아요 처리
  Future<void> _handleLikeComment(int commentId, bool hasLiked) async {
    try {
      // 이미 좋아요한 경우 취소, 아니면 좋아요
      final result =
      await _apiService.likeComment(commentId, isCancel: hasLiked);

      if (result) {
        // 댓글 목록 새로고침
        _loadComments();
      }
    } catch (e) {
      print('좋아요 처리 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  // 싫어요 처리
  Future<void> _handleDislikeComment(int commentId, bool hasDisliked) async {
    try {
      // 이미 싫어요한 경우 취소, 아니면 싫어요
      final result =
      await _apiService.dislikeComment(commentId, isCancel: hasDisliked);

      if (result) {
        // 댓글 목록 새로고침
        _loadComments();
      }
    } catch (e) {
      print('싫어요 처리 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('싫어요 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  // 하단 입력 섹션 - 입력 필드 디자인 수정
  Widget _buildInputSection() {
    // 토론방이 종료된 경우 입력 비활성화
    final bool isDisabled = _discussionRoom?.isClosed ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이디/비밀번호 입력 - 디자인 수정
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
                    color: isDisabled ? Colors.grey[200] : Color(0xFFF5F5F5),
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
                            hintText: "아이디",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDisabled ? Colors.grey : Colors.black87,
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
                    color: isDisabled ? Colors.grey[200] : Color(0xFFF5F5F5),
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
                              color: Colors.grey[600],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDisabled ? Colors.grey : Colors.black87,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDisabled ? Colors.grey[300]! : Color(0xFFE0E0E0),
                width: 1.5,
              ),
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
                      enabled: !isDisabled && !_isCommenting,
                      minLines: 1,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: isDisabled ? "종료된 토론방입니다" : "생각을 공유해주세요 :)",
                        hintStyle: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
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
                        ? Colors.grey[300]
                        : Color(0xFF19B3F6),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDisabled || _isCommenting
                            ? Colors.grey[300]!.withOpacity(0.2)
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

  // 댓글 제출 처리
  Future<void> _submitComment() async {
    // 입력값 검증
    final String id = _idController.text.trim();
    final String password = _passwordController.text.trim();
    final String comment = _commentController.text.trim();

    if (id.isEmpty || password.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디, 비밀번호, 댓글 내용을 모두 입력해주세요.')),
      );
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

        // 입력 필드 초기화
        _commentController.clear();

        // 댓글 목록 갱신
        _loadComments();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글이 등록되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 등록에 실패했습니다.')),
        );
      }
    } catch (e) {
      print('댓글 작성 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 중 오류가 발생했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCommenting = false;
        });
      }
    }
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

// 감정 데이터 클래스
class EmotionData {
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  EmotionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}