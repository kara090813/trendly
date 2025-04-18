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
                    // 타인에 대한 비방글 경고 메시지 (배경에 직접 배치)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w), // 좌우 마진 추가
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

  // 정보 섹션 (토론방 OPEN, 남은시간)
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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h), // 상단 패딩 감소
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
                    SizedBox(height: 12.h), // 타이틀과 시간 사이 간격 약간 증가
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                      children: [
                        Icon(
                          Icons.access_time_outlined, // 아웃라인 스타일 시계 아이콘
                          color: Color(0xFF19B3F6),
                          size: 38.sp,
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                          children: [
                            Text(
                              "25년 4월 3일",
                              style: TextStyle(
                                fontSize: 15.sp, // 텍스트 크기 증가
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 1.h), // 줄간격 줄이기
                            Text(
                              "오후 12시 56분",
                              style: TextStyle(
                                fontSize: 18.sp, // 텍스트 크기 증가
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

            // 남은시간 부분 (약간 더 진한 배경)
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h), // 상단 패딩 감소
                decoration: BoxDecoration(
                  color: Color(0xFFF9F9F9), // 약간 더 진한 배경
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
                        fontSize: 15.sp, // 크기 증가
                        color: Colors.black, // 색상 변경
                        fontWeight: FontWeight.w500, // 약간 두껍게
                      ),
                    ),
                    SizedBox(height: 12.h), // 타이틀과 시간 사이 간격 약간 증가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBlock("08"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 22.sp, // 크기 증가
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildTimeBlock("18"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            ":",
                            style: TextStyle(
                              fontSize: 22.sp, // 크기 증가
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

  // 시간 블록 위젯
  Widget _buildTimeBlock(String time) {
    return Container(
      width: 42.w, // 크기 증가
      height: 42.h, // 크기 증가
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // 그림자 강화
            blurRadius: 4, // 그림자 강화
            spreadRadius: 1, // 그림자 강화
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 22.sp, // 숫자 크기 증가
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
                // 댓글 아이템들
                _buildCommentItem(
                  nickname: "나는 첫gpt",
                  time: "20분전",
                  content: "크레스티드 게코는 머리 위에 눈썹 모양의 돌기를 가지고 있어요. 이 돌기 덕분에 더욱 개성 넘치는 외모를 자랑하죠 몸 색깔과 무늬도 다양해서 보는 재미가 있답니다.",
                  likes: 546,
                  dislikes: 32,
                  comments: 12,
                ),

                _buildCommentItem(
                  nickname: "게코매니아",
                  time: "35분전",
                  content: "크레스티드 게코는 애완용으로 인기가 많아서 자연에서 잘 볼 수 없게 되었다고 해요. 애완동물로 키울때 주의사항이 있을까요?",
                  likes: 324,
                  dislikes: 12,
                  comments: 8,
                ),

                _buildCommentItem(
                  nickname: "파충류전문가",
                  time: "1시간전",
                  content: "크레스티드 게코는 에오블레파리스(레오파드 게코)와 함께 초보자도 키우기 쉬운 파충류로 알려져 있어요. 온도와 습도 관리만 잘 해주시면 됩니다.",
                  likes: 215,
                  dislikes: 5,
                  comments: 23,
                ),

                _buildCommentItem(
                  nickname: "짱구는 내꺼 철수",
                  time: "2시간전",
                  content: "크레를 너무 명정해서 자연에서 못살 것 같음 ㅠㅠㄹ;;; 안전하게 우리집에서 오래오래 살아라",
                  likes: 146,
                  dislikes: 8,
                  comments: 3,
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

  // 하단 입력 섹션 - 이미지 참고하여 개선
  Widget _buildInputSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 20.h,
                        child: Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 18.sp,
                            color: Color(0xFF19B3F6),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        height: 20.h,
                        child: Center(
                          child: Text(
                            "아이디",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 20.h,
                        child: Center(
                          child: Icon(
                            Icons.lock_outline,
                            size: 18.sp,
                            color: Color(0xFF19B3F6),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        height: 20.h,
                        child: Center(
                          child: Text(
                            "비밀번호",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 댓글 입력 필드 - 여러 줄 입력을 위해 높이 증가
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 4.w, 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end, // 하단 정렬
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 40.h,
                      maxHeight: 100.h, // 최대 높이 설정
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft, // 텍스트 왼쪽 정렬
                      child: Text(
                        "생각을 공유해주세요 :)",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
                // 전송 버튼
                Container(
                  margin: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF19B3F6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 28.sp,
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