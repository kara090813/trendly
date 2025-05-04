import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../models/_models.dart';

class DiscussionReactionWidget extends StatelessWidget {
  final DiscussionRoom? discussionRoom;
  final Keyword? keyword;
  final VoidCallback? onEnterTap;
  final String? overrideSummary;

  // 입장 버튼 표시 여부 제어 매개변수 추가
  final bool showEnterButtons;

  // 일시적 통제 변수: 한줄요약 3개 모두 없는지 여부
  final bool hasSummaries;

  // 일시적 통제 변수: 각 요약(긍정/중립/부정) 존재 여부 제어
  final List<bool> summaryAvailability;

  const DiscussionReactionWidget({
    Key? key,
    required this.discussionRoom,
    this.keyword,
    this.onEnterTap,
    this.overrideSummary,
    // 입장 버튼 표시 여부 (기본값: true)
    this.showEnterButtons = true,
    // 일시적 통제 변수에 대한 기본값 설정 (추후 실제 데이터로 대체 예정)
    this.hasSummaries = true,
    this.summaryAvailability = const [true, false, true], // [긍정, 중립, 부정]
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 토론방 반응 데이터 계산
    final int positiveCount = discussionRoom?.positiveCount ?? 0;
    final int neutralCount = discussionRoom?.neutralCount ?? 0;
    final int negativeCount = discussionRoom?.negativeCount ?? 0;
    final int totalCount = positiveCount + neutralCount + negativeCount;

    // 반응 바 있는지 여부 확인
    final bool hasReactionBar = totalCount > 0;

    // 퍼센티지 계산 (총합이 0인 경우 예외 처리)
    final double positiveRatio =
        totalCount > 0 ? (positiveCount / totalCount * 100) : 33.3;
    final double neutralRatio =
        totalCount > 0 ? (neutralCount / totalCount * 100) : 33.4;
    final double negativeRatio =
        totalCount > 0 ? (negativeCount / totalCount * 100) : 33.3;

    // 표시할 퍼센티지 (반올림하여 정수로 표시)
    final int positivePercent = positiveRatio.round();
    final int neutralPercent = neutralRatio.round();
    final int negativePercent = negativeRatio.round();

    // 경우의 수에 따라 사이드 입장 버튼 표시 여부 결정
    // showEnterButtons이 false면 항상 버튼 숨김
    final bool showSideEnterButton =
        showEnterButtons && !((!hasReactionBar && !hasSummaries));

    return Stack(
      children: [
        // 통합된 단일 컨테이너
        Container(
          margin: showEnterButtons
              ? EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h)
              : EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
          decoration: BoxDecoration(
            color: showEnterButtons
                ? (AppTheme.isDark(context) ? Color(0xFF20212A) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: showEnterButtons
                ? (AppTheme.isDark(context)
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(1, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(1, 3),
                        ),
                      ])
                : [],
          ),
          child: Column(
            children: [
              // 상단 부분: 반응바 + 퍼센트 (또는 안내 메시지)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20.w,
                    showEnterButtons ? 20.h : 0,
                    showEnterButtons ? 80.w : 20.w,
                    20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    showEnterButtons
                        ? Text(
                            '토론방 반응',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextColor(context),
                            ),
                          )
                        : SizedBox.shrink(),
                    showEnterButtons
                        ? SizedBox(height: 16.h)
                        : SizedBox(
                            height: 6.h,
                          ),

                    // 경우의 수에 따른 컨텐츠 분기
                    if (hasReactionBar) ...[
                      // 반응 바가 있는 경우 - 경우의 수 2, 4
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 12.h,
                          child: Row(
                            children: [
                              _reactionSegment(
                                  positiveRatio / 100, const Color(0xFF00AEEF)),
                              _reactionSegment(
                                  neutralRatio / 100, Colors.grey.shade400),
                              _reactionSegment(
                                  negativeRatio / 100, const Color(0xFFFF5A5F)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 퍼센트 표시 (균등 분배)
                      Row(
                        children: [
                          _reactionLabel(context, '긍정', '$positivePercent%',
                              const Color(0xFF00AEEF)),
                          SizedBox(width: 16.w),
                          _reactionLabel(context, '중립', '$neutralPercent%',
                              Colors.grey.shade600),
                          SizedBox(width: 16.w),
                          _reactionLabel(context, '부정', '$negativePercent%',
                              const Color(0xFFFF5A5F)),
                        ],
                      ),
                    ] else if (!hasSummaries) ...[
                      // 경우의 수 1: 반응 바 없음, 한줄 요약도 없음
                      _buildNoDataMessage(
                        context: context,
                        icon: Icons.analytics_outlined,
                        message: '토론방 데이터가 없습니다.',
                      ),
                    ] else ...[
                      // 경우의 수 3: 반응 바 없음, 한줄 요약 있음
                      _buildNoDataMessage(
                        context: context,
                        icon: Icons.add_reaction_outlined,
                        message: '토론방에 입장해 반응을 남겨주세요.',
                      ),
                    ],
                  ],
                ),
              ),

              // 구분선 대신 그라데이션 효과의 구분 영역
              showEnterButtons
                  ? Container(
                      width: double.infinity,
                      height: 8.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.isDark(context) ? Color(0xFF20212A) : Colors.white,
                            AppTheme.isDark(context)
                                ? Color(0xFF242430)
                                : Color(0xFFF8F8F8),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),

              // 의견 요약 또는 안내 메시지가 들어갈 배경 영역
              Container(
                width: double.infinity,
                padding: showEnterButtons
                    ? EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h)
                    : EdgeInsets.only(left: 15.w,right: 15.w, top: 2.h,bottom: 15.h),
                decoration: BoxDecoration(
                  color: showEnterButtons
                      ? (AppTheme.isDark(context)
                          ? Color(0xFF242430)
                          : Color(0xFFF8F8F8))
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
                child:
                    _buildBottomContent(context, hasReactionBar, hasSummaries),
              ),
            ],
          ),
        ),

        // 입장 버튼 (경우의 수 1 제외하고 표시)
        if (showEnterButtons && discussionRoom != null)
          Positioned(
            top: 10.h,
            right: 15.w,
            height: 132.h,
            child: Container(
              width: 60.w,
              decoration: BoxDecoration(
                color: AppTheme.isDark(context)
                    ? Color(0xFF2A2A36)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(AppTheme.isDark(context) ? 0.4 : 0.2),
                    blurRadius: 8,
                    offset: const Offset(-3, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
                child: Material(
                  color: AppTheme.getCardColor(context),
                  child: InkWell(
                    onTap: onEnterTap ??
                        () {
                          if (discussionRoom != null) {
                            context.push('/discussion/${discussionRoom!.id}');
                          }
                        },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chevron_right,
                            size: 34.sp,
                            color: const Color(0xFF00AEEF),
                          ),
                          Text(
                            '입장',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              color: AppTheme.isDark(context)
                                  ? Colors.white
                                  : Color(0xFF404040),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 하단 컨텐츠 분기 처리 (경우의 수에 따른 컨텐츠 선택)
  Widget _buildBottomContent(
      BuildContext context, bool hasReactionBar, bool hasSummaries) {
    if (!hasSummaries) {
      // 한줄 요약 없음 - 경우의 수 1, 2
      return Column(
        children: [
          Text(
            hasReactionBar
                ? '토론방 댓글을 요약하기에 충분한 데이터가 없습니다.'
                : '토론방에 참여해 의견을 공유해보세요.',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.isDark(context)
                  ? Colors.grey[400]
                  : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          // 입장 버튼 표시 조건 추가
          if (showEnterButtons)
            Column(
              children: [
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLargeEnterButton(context),
                  ],
                ),
                SizedBox(height: 6.h),
              ],
            ),
        ],
      );
    } else {
      // 한줄 요약 있음 - 경우의 수 3, 4
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 긍정 의견 카드
          _buildOpinionCard(
            context: context,
            icon: Icons.thumb_up,
            label: '긍정',
            opinion: summaryAvailability[0] ? '나는 크레스티드 게코 발 주는게 재밌다' : null,
            color: const Color(0xFF00AEEF),
          ),
          SizedBox(height: 10.h),

          // 중립 의견 카드
          _buildOpinionCard(
            context: context,
            icon: Icons.thumbs_up_down,
            label: '중립',
            opinion: summaryAvailability[1] ? '나는 별생각 없다 그냥 의무일 뿐' : null,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 10.h),

          // 부정 의견 카드
          _buildOpinionCard(
            context: context,
            icon: Icons.thumb_down,
            label: '부정',
            opinion: summaryAvailability[2] ? '발 주는게 너무 귀찮다 혼자서 먹으면 좋겠다' : null,
            color: const Color(0xFFFF5A5F),
          ),
        ],
      );
    }
  }

  // 큰 입장 버튼 위젯
  Widget _buildLargeEnterButton(BuildContext context) {
    return Container(
      width: 180.w, // 너비 지정
      height: 50.h, // 높이 지정
      child: ElevatedButton(
        onPressed: onEnterTap ??
            () {
              if (discussionRoom != null) {
                context.push('/discussion/${discussionRoom!.id}');
              }
            },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00AEEF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '토론방 댓글작성',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, size: 20.sp),
          ],
        ),
      ),
    );
  }

  // 데이터 없음 안내 메시지 - context 파라미터 추가
  Widget _buildNoDataMessage(
      {required BuildContext context,
      required IconData icon,
      required String message}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context) ? Color(0xFF2A2A36) : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10.r),
          boxShadow: AppTheme.isDark(context)
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 2),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 2),
            )
          ]
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: const Color(0xFF00AEEF),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.isDark(context)
                    ? Colors.grey[300]
                    : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 반응 그래프의 세그먼트 생성
  Widget _reactionSegment(double value, Color color) {
    return Expanded(
      flex: (value * 100).toInt() > 0 ? (value * 100).toInt() : 1,
      child: Container(
        color: color,
      ),
    );
  }

  // 반응 레이블 생성
  Widget _reactionLabel(
      BuildContext context, String text, String percentage, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '$text $percentage',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.isDark(context)
                ? Colors.grey[400]
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // 의견 카드 위젯 (요약 있을 때/없을 때 분기)
  Widget _buildOpinionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    String? opinion,
  }) {
    // 의견이 null이면 비활성화된 느낌의 카드 표시
    final bool hasOpinion = opinion != null;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12.r),
        // 의견 있는지 여부에 따라 스타일 조정
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(hasOpinion ? 0.4 : 0.2)
                : Colors.black.withOpacity(hasOpinion ? 0.15 : 0.05),
            blurRadius: hasOpinion ? 2 : 1,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        // 없는 의견은 살짝 비활성화된 느낌으로
        border: hasOpinion
            ? null
            : Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Stack(
        children: [
          // 배지 (라벨)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: hasOpinion ? color : color.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 의견 텍스트 또는 안내 메시지
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 30.h, 16.w, 12.h),
            child: hasOpinion
                ? Text(
                    opinion!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.3,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    "$label 의견에 대한 요약을 하기에 충분한 데이터가 없습니다.",
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.3,
                      color: AppTheme.isDark(context)
                          ? Colors.grey[500]
                          : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }
}
