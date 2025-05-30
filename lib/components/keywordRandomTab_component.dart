import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../widgets/_widgets.dart';

class RandomKeywordTabComponent extends StatefulWidget {
  const RandomKeywordTabComponent({Key? key}) : super(key: key);

  @override
  State<RandomKeywordTabComponent> createState() => _RandomKeywordTabComponentState();
}

class _RandomKeywordTabComponentState extends State<RandomKeywordTabComponent> {
  bool _isRandomLoading = false;

  // 랜덤 키워드 리스트 (나중에 API로 대체)
  final List<Map<String, dynamic>> _randomKeywords = [
    {"keyword": "고양이 밈", "category": "문화", "date": "2022년 11월 2일"},
    {"keyword": "포켓몬 우유", "category": "엔터", "date": "2025년 2월 15일"},
    {"keyword": "신형 아이폰", "category": "IT", "date": "2024년 9월 12일"},
    {"keyword": "키즈 카페", "category": "육아", "date": "2024년 12월 5일"},
  ];

  // 현재 선택된 랜덤 키워드 인덱스
  int _currentRandomIndex = 0;

  // 랜덤 키워드 기능
  void _randomizeKeyword() {
    setState(() {
      _isRandomLoading = true;
    });

    // 로딩 효과 후 랜덤 키워드 선택
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          // 현재와 다른 인덱스 선택을 보장
          int newIndex;
          do {
            newIndex = (DateTime.now().millisecondsSinceEpoch % _randomKeywords.length).toInt();
          } while (newIndex == _currentRandomIndex && _randomKeywords.length > 1);

          _currentRandomIndex = newIndex;
          _isRandomLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 랜덤 키워드
    final currentKeyword = _randomKeywords[_currentRandomIndex];

    return ListView(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(height: 16.h),
        _buildRandomKeywordHeader(currentKeyword),
        SizedBox(height: 16.h),
        _buildKeywordSummary(),
        SizedBox(height: 16.h),
        _buildRelatedNews(),
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

  // 랜덤 키워드 헤더
  Widget _buildRandomKeywordHeader(Map<String, dynamic> keyword) {
    return _buildSettingContainer(
      child: Row(
        children: [
          _isRandomLoading
              ? Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF19B3F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  color: Color(0xFF19B3F6),
                  strokeWidth: 2.5,
                ),
              ),
            ),
          )
              : Container(
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
              Icons.shuffle,
              color: Color(0xFF19B3F6),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    keyword["keyword"],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B3F6).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Color(0xFF19B3F6).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      keyword["category"],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF19B3F6),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                keyword["date"],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.isDark(context) ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          Spacer(),
          _buildButton(
            icon: Icons.refresh,
            label: "랜덤 선택",
            onTap: _randomizeKeyword,
          ),
        ],
      ),
    );
  }

  // 키워드 요약
  Widget _buildKeywordSummary() {
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
          HistoryTitleWidget(
            title: "키워드 요약",
            icon: Icons.text_snippet_rounded,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFF818CF8),
            darkIconBackground: Color(0xFF6366F1),
            // 기타 색상은 기존 유지
          ),

          SizedBox(height: 16.h),

          // 요약 내용
          _buildNumberedPoint(
            1,
            "무표정 고양이 짤이 트위터에서 유행함.",
          ),

          SizedBox(height: 10.h),

          _buildNumberedPoint(
            2,
            "이 짤은 이후 밈 채널에서 다양하게 재해석됨.",
          ),

          SizedBox(height: 10.h),

          _buildNumberedPoint(
            3,
            "'짤줍'이라는 단어가 본격 확산되기 시작한 계기가 됨.",
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOutQuad);
  }

  // 번호가 있는 포인트 아이템
  Widget _buildNumberedPoint(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: Color(0xFF19B3F6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF19B3F6),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.4,
              color: AppTheme.getTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  // 관련 뉴스
  Widget _buildRelatedNews() {
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
          // 관련 뉴스
          HistoryTitleWidget(
            title: "관련 뉴스",
            icon: Icons.newspaper_rounded,
            lightPrimaryColor: Color(0xFFDCF1FF),
            lightSecondaryColor: Color(0xFFBAE6FD),
            darkPrimaryColor: Color(0xFF334155),
            darkSecondaryColor: Color(0xFF475569),
            lightIconBackground: Color(0xFFFBBF24),
            darkIconBackground: Color(0xFFF59E0B),
          ),

          SizedBox(height: 16.h),

          // 뉴스 카드 목록
          _buildNewsCard(
            "중앙일보",
            "무표정 고양이 짤, 이틀 만에 30만 뷰 돌파",
            "2022-11-03",
            0,
          ),

          SizedBox(height: 12.h),

          _buildNewsCard(
            "인사이트",
            "'짤줍'의 시작은 이 고양이였다?",
            "2022-11-04",
            100,
          ),

          SizedBox(height: 12.h),

          _buildNewsCard(
            "위키트렌드",
            "트위터 밈 급부상 키워드 분석",
            "2022-11-05",
            200,
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  // 뉴스 카드
  Widget _buildNewsCard(String source, String title, String date, int delay) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Color(0xFF21202C)
            : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.grey[700]!
              : Colors.grey[400]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDark(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 미디어 아이콘
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Color(0xFF19B3F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                Icons.article,
                color: Color(0xFF19B3F6),
                size: 20.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 뉴스 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF19B3F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: Color(0xFF19B3F6).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF19B3F6),
                        ),
                      ),
                    ),

                    Spacer(),

                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[500]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextColor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay))
        .slideX(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
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