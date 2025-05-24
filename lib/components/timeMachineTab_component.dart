import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../widgets/_widgets.dart';

class TimeMachineTabComponent extends StatefulWidget {
  const TimeMachineTabComponent({Key? key}) : super(key: key);

  @override
  State<TimeMachineTabComponent> createState() => _TimeMachineTabComponentState();
}

class _TimeMachineTabComponentState extends State<TimeMachineTabComponent> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 14)); // 기본값: 2주 전

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(height: 16.h),
        _buildDateSelector(),
        SizedBox(height: 16.h),
        _buildTimeCapsule(),
        SizedBox(height: 16.h),
        _buildEventSummary(),
        SizedBox(height: 16.h),
      ],
    );
  }

  // 설정 컨테이너 스타일 공통 함수
  Widget _buildSettingContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF252530)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Color(0xFF19B3F6).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? EdgeInsets.all(16.w),
      child: child,
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOutQuad);
  }

  // 날짜 선택기
  Widget _buildDateSelector() {
    return _buildSettingContainer(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF19B3F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(10.w),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF19B3F6),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "이날의 실시간 트렌드",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          Spacer(),
          _buildButton(
            icon: Icons.edit_calendar_rounded,
            label: "날짜 선택",
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF19B3F6),
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // 타임캡슐 (TOP 10 키워드)
  Widget _buildTimeCapsule() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 타임캡슐 헤더
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "실시간 키워드 TOP 10",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 타임캡슐 콘텐츠 - 컴팩트한 그리드 레이아웃
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(10, (index) {
                // 예시 데이터
                final List<Map<String, dynamic>> data = [
                  {"rank": 1, "keyword": "크레딧카드 개코", "change": "+154"},
                  {"rank": 2, "keyword": "포켓몬 우유", "change": "+97"},
                  {"rank": 3, "keyword": "갤럭시 S25", "change": "+33"},
                  {"rank": 4, "keyword": "파워에이드", "change": "+21"},
                  {"rank": 5, "keyword": "소금 우유", "change": "+19"},
                  {"rank": 6, "keyword": "김소현 복귀", "change": "+16"},
                  {"rank": 7, "keyword": "링스틱", "change": "+15"},
                  {"rank": 8, "keyword": "투싹", "change": "+11"},
                  {"rank": 9, "keyword": "갤럭시탭", "change": "+9"},
                  {"rank": 10, "keyword": "10일만에 새마음", "change": "+7"},
                ];

                return _buildCompactRankCard(
                  data[index]["rank"],
                  data[index]["keyword"],
                  data[index]["change"],
                );
              }),
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutQuad);
  }

  // 컴팩트한 랭크 카드
  Widget _buildCompactRankCard(int rank, String keyword, String change) {
    final isTop3 = rank <= 3;
    final Color rankColor = isTop3 ? Color(0xFF19B3F6) : Color(0xFF5A5A5A);

    // 변화량 색상 설정 (양수면 빨간색, 음수면 파란색)
    final bool isPositive = change.startsWith('+');
    final Color changeColor = isPositive ? Color(0xFFFF2D55) : Color(0xFF34C759);

    return Container(
      // IntrinsicWidth을 사용하여 내용물 크기에 맞게 조정
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.isDark(context)
                ? (isTop3 ? Color(0xFF1D2333) : Color(0xFF21202C))
                : (isTop3 ? Color(0xFFF5FAFF) : Colors.white),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isTop3
                  ? Color(0xFF19B3F6).withOpacity(0.5)
                  : AppTheme.isDark(context)
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.isDark(context)
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 내용물에 맞게 크기 조정
            children: [
              // 순위 표시
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // 키워드 & 변화량
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    keyword,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: changeColor,
                        size: 12.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        change.replaceAll('+', ''),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 4.w), // 오른쪽 여백 추가
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: rank * 40))
        .scaleXY(begin: 0.95, end: 1, duration: 200.ms);
  }

  // 이벤트 요약
  Widget _buildEventSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.getContainerColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: AppTheme.isDark(context)
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF19B3F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.summarize_rounded,
                  color: Color(0xFF19B3F6),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "일일 트렌드 요약",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 요약 콘텐츠
          _buildSummaryItem(
              "이날은 포켓몬 우유 밈이 트위터에서 급확산되며 연관 키워드 다수가 실검 진입하였습니다. '크레딧카드 개코'와 '포켓몬 우유'가 1, 2위를 차지했습니다."
          ),

          SizedBox(height: 8.h),

          _buildSummaryItem(
              "아이폰 관련 키워드가 급증했고, IT 카테고리에서 갤럭시 기기가 주목받았습니다."
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  // 요약 아이템
  Widget _buildSummaryItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📌",
          style: TextStyle(
            fontSize: 16.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
              color: AppTheme.isDark(context)
                  ? Colors.grey[300]
                  : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  // 버튼
  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? Color(0xFF19B3F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}