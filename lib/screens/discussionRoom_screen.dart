import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class DiscussionRoomScreen extends StatefulWidget {
  final int discussionRoomId;

  const DiscussionRoomScreen({
    Key? key,
    required this.discussionRoomId,
  }) : super(key: key);

  @override
  State<DiscussionRoomScreen> createState() => _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends State<DiscussionRoomScreen> {
  bool _isRealTimeSummaryEnabled = false;
  String? _selectedSentiment; // null, 'positive', 'neutral', 'negative'
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // 고정된 헤더
            _buildHeader(context),

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
                    _buildSummaryToggle(),
                    SizedBox(height: 12.h),
                    // 새로 추가한 감정 버튼 위젯
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildSentimentButtons(),
                    ),
                    // 타인에 대한 비방글 경고 메시지 (배경에 직접 배치)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      // 좌우 마진 추가
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
                    ),
                    SizedBox(height: 4.h),
                    _buildCommentSection(),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // 고정된 입력 섹션
            _buildInputSection(),
          ],
        ),
      ),
    );
  }
  // 2. _buildSummaryToggle() 메서드 아래에 감정 반응 버튼 위젯 추가
  Widget _buildSentimentButtons() {
    // 감정이 선택되지 않은 경우: 3개의 버튼 표시
    if (_selectedSentiment == null) {
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
            Text(
              "당신의 의견을 알려주세요",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildSentimentButton(
                  label: "긍정",
                  color: Color(0xFF19B3F6),
                  onTap: () => _selectSentiment('positive'),
                ),
                SizedBox(width: 10.w),
                _buildSentimentButton(
                  label: "중립",
                  color: Colors.grey,
                  onTap: () => _selectSentiment('neutral'),
                ),
                SizedBox(width: 10.w),
                _buildSentimentButton(
                  label: "부정",
                  color: Color(0xFFE74C3C),
                  onTap: () => _selectSentiment('negative'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    // 감정이 선택된 경우: 선택된 버튼과 재선택 버튼 표시
    else {
      String label;
      Color color;

      switch (_selectedSentiment) {
        case 'positive':
          label = "긍정";
          color = Color(0xFF19B3F6);
          break;
        case 'neutral':
          label = "중립";
          color = Colors.grey;
          break;
        case 'negative':
          label = "부정";
          color = Color(0xFFE74C3C);
          break;
        default:
          label = "";
          color = Colors.grey;
      }

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
            Text(
              "당신의 의견",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildSentimentButton(
                    label: label,
                    color: color,
                    onTap: () {}, // 이미 선택됨
                    isSelected: true,
                  ),
                ),
                SizedBox(width: 10.w),
                TextButton(
                  onPressed: _resetSentiment,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "재선택",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
  Widget _buildSentimentButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Expanded(
      child: Material(
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: color,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// 4. 감정 선택 처리 메서드
  void _selectSentiment(String sentiment) {
    setState(() {
      _isAnimating = true;
      _selectedSentiment = sentiment;
    });

    // 애니메이션 효과를 위한 지연
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

// 5. 감정 재선택 메서드
  void _resetSentiment() {
    setState(() {
      _isAnimating = true;
      _selectedSentiment = null;
    });

    // 애니메이션 효과를 위한 지연
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }
  // 헤더 부분 (제목, 뒤로가기, 새로고침, 공유 버튼)
  Widget _buildHeader(BuildContext context) {
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
          // 뒤로가기 버튼 (둥근 백그라운드와 음영 추가)
          _buildRoundedButton(
            onTap: () => context.pop(),
            icon: Icons.chevron_left,
            color: Color(0xFF19B3F6),
            iconSize: 28.sp,
          ),

          SizedBox(width: 12.w),

          // 키워드와 카테고리 (좌측 정렬)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
              mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
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
          _buildRoundedButton(
            onTap: () {},
            icon: Icons.refresh,
            color: Color(0xFF19B3F6),
            iconSize: 22.sp,
          ),

          SizedBox(width: 8.w),

          // 클라우드 업로드 버튼
          _buildRoundedButton(
            onTap: () {},
            icon: Icons.cloud_upload_outlined,
            color: Colors.grey[500]!,
            iconSize: 22.sp,
          ),
        ],
      ),
    );
  }

  // 라운드 버튼 위젯
  Widget _buildRoundedButton({
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

  // 정보 섹션 (토론방 OPEN, 남은시간) 개선
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
                            // 1. 줄간격 제거 - SizedBox 높이를 0으로 설정
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

  // 2. 타이머 블록 크기 증가
  Widget _buildTimeBlock(String time) {
    return Container(
      // 크기를 더 키움 (42 -> 48)
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
          fontSize: 24.sp, // 숫자 크기도 증가 (22 -> 24)
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 실검 요약 토글
  Widget _buildSummaryToggle() {
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
          // 커스텀 토글 스위치 (음영 있는 디자인)
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
    );
  }

  // 커스텀 토글 스위치
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

  // 댓글 섹션 - 색상 반전 및 레이아웃 개선
  Widget _buildCommentSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색을 흰색으로 변경
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

          // 각 댓글을 개별 카드로 표시
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
                  content:
                      "예전에 TV에서 크레 나왔던 거 봤는데, 진짜 얌전하고 귀엽더라구요. 사료 같은 것도 따로 있나요?",
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
              ],
            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // 댓글 아이템 - 색상 반전 및 레이아웃 개선
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
        color: Color(0xFFF5F5F5), // 카드 배경색을 어둡게 변경
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
            // 닉네임 및 시간을 하나의 행에 배치
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

  // 하단 입력 섹션 - 수정된 버전
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
          // 1. 아이디/비밀번호 입력 - 수직 정렬 수정
          Row(
            children: [
              // 아이디 입력 필드 - 정렬 수정
              Expanded(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -3,
                    intensity: 0.7,
                    shape: NeumorphicShape.flat,
                    lightSource: LightSource.topLeft,
                    color: Color(0xFFF5F5F5),
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16.r)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // 명시적으로 세로 가운데 정렬 설정
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 아이콘 정렬을 위한 Container 제거
                      Icon(
                        Icons.person_outline,
                        size: 20.sp,
                        color: Color(0xFF19B3F6),
                      ),
                      SizedBox(width: 10.w),
                      // 텍스트도 Container 없이 직접 배치
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
              // 비밀번호 입력 필드 - 정렬 수정
              Expanded(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: -3,
                    intensity: 0.7,
                    shape: NeumorphicShape.flat,
                    lightSource: LightSource.topLeft,
                    color: Color(0xFFF5F5F5),
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16.r)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // 명시적으로 세로 가운데 정렬
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

          // 2. 댓글 입력 필드 - 더 넓은 입력창과 간소화된 디자인
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
                // 입력 영역 - TextField로 변경하여 실제 입력 가능하게
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 8.h),
                    child: TextField(
                      minLines: 1,
                      maxLines: 3,  // 최대 3줄까지 입력 가능
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

                // 전송 버튼만 유지하고 디자인 개선
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
