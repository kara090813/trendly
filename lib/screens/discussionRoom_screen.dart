import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

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
  bool _isRealTimeSummaryEnabled = false;
  String? _selectedSentiment; // null, 'positive', 'neutral', 'negative'
  bool _isAnimating = false;

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 영역
            _buildHeaderSection(context),

            // 스크롤 가능한 본문
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    _buildInfoSection(),
                    SizedBox(height: 12.h),
                    _buildSummaryToggleSection(),
                    SizedBox(height: 12.h),
                    // 감정 버튼 영역 (애니메이션 전환)
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 600),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        // custom 전환 효과
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                                begin: 0.95,
                                end: 1.0
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: _buildEmotionButtonsSection(),
                    ),

                    // 경고 메시지
                    _buildWarningMessage(),
                    SizedBox(height: 4.h),
                    _buildCommentSection(),
                    SizedBox(height: 12.h),
                  ],
                ),
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

  // 감정 선택 버튼 섹션 수정
  Widget _buildEmotionButtonsSection() {
    // 고정 크기로 컨테이너 설정
    final containerHeight = 180.h;

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
      child: Column(
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
          Expanded(
              child: _selectedSentiment == null
                  ? _buildSelectionButtons() // 선택 전 버튼들
                  : _buildSelectedOpinion() // 선택 후 내용
              ),
        ],
      ),
    );
  }

  // 수정된 선택 버튼 부분
  Widget _buildSelectionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildEmotionButton(
            key: _positiveKey,
            label: "긍정",
            icon: Icons.thumb_up_rounded,
            color: Color(0xFF19B3F6),
            onTap: () => _handleEmotionSelection('positive'),
          ).animate().fadeIn(duration: 400.ms),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildEmotionButton(
            key: _neutralKey,
            label: "중립",
            icon: Icons.thumbs_up_down_rounded,
            color: Colors.grey,
            onTap: () => _handleEmotionSelection('neutral'),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildEmotionButton(
            key: _negativeKey,
            label: "부정",
            icon: Icons.thumb_down_rounded,
            color: Color(0xFFE74C3C),
            onTap: () => _handleEmotionSelection('negative'),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
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
                ).animate(
                    onComplete: (controller) => _animController.forward(from: 0.0)
                )
                    .moveY(
                    begin: 20,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic
                )
                    .scale(
                    begin: Offset(0.6, 0.6),  // 수정: double -> Offset
                    end: Offset(1.0, 1.0),    // 수정: double -> Offset
                    duration: 600.ms,
                    curve: Curves.elasticOut
                ),
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
                      ).animate()
                          .moveX(
                          begin: 20,
                          end: 0,
                          duration: 400.ms,
                          delay: 200.ms,
                          curve: Curves.easeOutCubic
                      )
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
                      ).animate()
                          .moveX(
                          begin: 30,
                          end: 0,
                          duration: 500.ms,
                          delay: 300.ms,
                          curve: Curves.easeOutCubic
                      )
                          .fadeIn(duration: 400.ms, delay: 300.ms),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 400.ms)
              .scale(
              begin: Offset(0.9, 0.9),  // 수정: double -> Offset
              end: Offset(1.0, 1.0),    // 수정: double -> Offset
              duration: 500.ms,
              curve: Curves.easeOutBack
          ),
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
        ).animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .scale(
            begin: Offset(0.5, 0.5),  // 수정: double -> Offset
            end: Offset(1.0, 1.0),    // 수정: double -> Offset
            duration: 500.ms,
            curve: Curves.elasticOut
        )
            .rotate(
            begin: -0.5,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutBack
        ),
      ],
    );
  }

  // 감정 버튼 위젯 - 수정됨
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
  void _handleEmotionSelection(String sentiment) {
    // 애니메이션 플래그 설정
    setState(() {
      _isAnimating = true;
      _selectedSentiment = sentiment; // 즉시 상태 업데이트
    });

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
  void _resetEmotionSelection() {
    setState(() {
      _isAnimating = true;
      _selectedSentiment = null; // 즉시 상태 업데이트
    });

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
                  "크레스티드 게코",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "취미/반려동물",
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
            onTap: () {},
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            iconSize: 22.sp,
          ),

          SizedBox(width: 8.w),

          // 공유 버튼
          _buildCircleButton(
            onTap: () {},
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
                              "25년 4월 3일",
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 0),
                            Text(
                              "오후 12시 56분",
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
                  color: Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "남은시간",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBlock("08"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildTimeBlock("18"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildTimeBlock("28"),
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
  Widget _buildTimeBlock(String time) {
    return Container(
      width: 48.w,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "실검 요약",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          // 커스텀 토글 스위치
          _buildToggleSwitch(
            value: _isRealTimeSummaryEnabled,
            onChanged: (value) {
              setState(() {
                _isRealTimeSummaryEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // 커스텀 토글 스위치
  Widget _buildToggleSwitch({
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

          SizedBox(height: 8.h),

          // 댓글 리스트 (예시 하나만 표시)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                _buildCommentItem(
                  nickname: "게코알못",
                  time: "5분전",
                  content: "이 친구들 털 없어서 알러지 걱정 없다고 하던데 진짜임?",
                  likes: 87,
                  dislikes: 2,
                  comments: 4,
                ),
                _buildCommentItem(
                  nickname: "눈썹미남게코",
                  time: "12분전",
                  content: "크레스티드 게코는 야행성이라 낮엔 거의 안 움직여요! 처음엔 고장난 줄 알았음ㅋㅋ",
                  likes: 134,
                  dislikes: 3,
                  comments: 7,
                ),
                _buildCommentItem(
                  nickname: "동물농장매니아",
                  time: "22분전",
                  content: "예전에 TV에서 크레 나왔던 거 봤는데, 진짜 얌전하고 귀엽더라구요. 사료 같은 것도 따로 있나요?",
                  likes: 76,
                  dislikes: 1,
                  comments: 2,
                ),
                _buildCommentItem(
                  nickname: "도마뱀아빠",
                  time: "30분전",
                  content: "우리집 크레는 이름이 '콩이'인데, 손 위에 올려놓으면 가만히 있어서 심장 녹음ㅠㅠ",
                  likes: 243,
                  dislikes: 4,
                  comments: 15,
                ),
                _buildCommentItem(
                  nickname: "한밤의게코",
                  time: "42분전",
                  content: "야행성이라 밤마다 나랑 같이 생활하는 중... 나보다 더 규칙적인 듯;;",
                  likes: 118,
                  dislikes: 3,
                  comments: 6,
                ),
                _buildCommentItem(
                  nickname: "초보파충류러",
                  time: "1시간전",
                  content: "습도는 어느 정도로 유지해야 하나요? 자꾸 피막 벗기기 실패해서 걱정입니다ㅠ",
                  likes: 97,
                  dislikes: 6,
                  comments: 9,
                ),
                _buildCommentItem(
                  nickname: "사랑해크레야",
                  time: "1시간 20분전",
                  content: "크레 눈에 속눈썹 같은 거 있어서 너무 예뻐요. 눈 안 닦아줘도 되나 궁금하네요.",
                  likes: 64,
                  dislikes: 2,
                  comments: 3,
                ),
                _buildCommentItem(
                  nickname: "야생의마음",
                  time: "2시간전",
                  content: "사육보다 자연이 좋다고 생각하지만... 요즘 자연에서 보기 힘들어진 게 안타깝네요.",
                  likes: 102,
                  dislikes: 17,
                  comments: 11,
                ),
                _buildCommentItem(
                  nickname: "도마도마",
                  time: "2시간 30분전",
                  content: "크레는 수직 사육장 좋아한다던데 높이 어느 정도로 맞춰야 해요?",
                  likes: 55,
                  dislikes: 0,
                  comments: 5,
                ),
                _buildCommentItem(
                  nickname: "파충류수집가",
                  time: "3시간전",
                  content: "크레는 점프력이 꽤 좋아요. 뚜껑 안 닫으면 탈출합니다 진짜임...",
                  likes: 149,
                  dislikes: 9,
                  comments: 13,
                ),
              ]

            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // 댓글 아이템 위젯
  Widget _buildCommentItem({
    required String nickname,
    required String time,
    required String content,
    required int likes,
    required int dislikes,
    required int comments,
  }) {
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
                  nickname,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF19B3F6),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[500],
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.more_horiz,
                  size: 16.sp,
                  color: Colors.grey[400],
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // 댓글 내용
            Text(
              content,
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
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16.sp,
                      color: Color(0xFF19B3F6),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      likes.toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF19B3F6),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),

                // 싫어요
                Row(
                  children: [
                    Icon(
                      Icons.thumb_down_outlined,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      dislikes.toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Spacer(),

                // 댓글 수
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      comments.toString(),
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

  // 하단 입력 섹션
  Widget _buildInputSection() {
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
                    color: Color(0xFFF5F5F5),
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
                      Text(
                        "아이디",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
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
                    color: Color(0xFFF5F5F5),
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
                      Text(
                        "비밀번호",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
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
                color: Color(0xFFE0E0E0),
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
                      minLines: 1,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "생각을 공유해주세요 :)",
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
                    color: Color(0xFF19B3F6),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF19B3F6).withOpacity(0.2),
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
                      onTap: () {},
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        child: Icon(
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
