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

  // 뉴스 데이터 (썸네일 정보 포함)
  final List<Map<String, dynamic>> _newsData = [
    {
      "source": "중앙일보",
      "type": "뉴스",
      "title": "무표정 고양이 짤, 이틀 만에 30만 뷰 돌파",
      "date": "2022-11-03",
      "thumbnail": "https://example.com/news1.jpg", // 실제 썸네일 URL
      "hasImage": true,
    },
    {
      "source": "인사이트",
      "type": "커뮤니티",
      "title": "'짤줍'의 시작은 이 고양이였다?",
      "date": "2022-11-04",
      "thumbnail": null, // 썸네일 없음
      "hasImage": false,
    },
    {
      "source": "위키트렌드",
      "type": "뉴스",
      "title": "트위터 밈 급부상 키워드 분석",
      "date": "2022-11-05",
      "thumbnail": "https://example.com/news3.jpg",
      "hasImage": true,
    },
  ];

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
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(height: 16.h),
        _buildRandomKeywordHeader(currentKeyword),
        SizedBox(height: 16.h),
        _buildKeywordSummary(),
        SizedBox(height: 16.h),
        _buildRelatedNews(),
        SizedBox(height: 40.h),
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
          ..._newsData.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> newsItem = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index == _newsData.length - 1 ? 0 : 12.h),
              child: _buildNewsCard(newsItem, index * 100),
            );
          }).toList(),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  // 개선된 뉴스 카드
  Widget _buildNewsCard(Map<String, dynamic> newsItem, int delay) {
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
          // 썸네일 이미지 또는 기본 이미지
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Color(0xFF2A2A36)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.r),
              child: newsItem['hasImage'] == true && newsItem['thumbnail'] != null
                  ? Image.network(
                newsItem['thumbnail'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultThumbnail(newsItem['type']);
                },
              )
                  : _buildDefaultThumbnail(newsItem['type']),
            ),
          ),

          SizedBox(width: 12.w),

          // 뉴스 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 뉴스사명과 타입, 날짜
                Row(
                  children: [
                    // 뉴스사명
                    Text(
                      newsItem['source'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),

                    SizedBox(width: 6.w),

                    // 구분점
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: AppTheme.isDark(context)
                            ? Colors.grey[500]
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),

                    SizedBox(width: 6.w),

                    // 커뮤니티/뉴스 타입 태그
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(newsItem['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: _getTypeColor(newsItem['type']).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        newsItem['type'],
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(newsItem['type']),
                        ),
                      ),
                    ),

                    Spacer(),

                    // 날짜
                    Text(
                      newsItem['date'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.isDark(context)
                            ? Colors.grey[500]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // 제목
                Text(
                  newsItem['title'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  // 기본 썸네일 (썸네일이 없을 때)
  Widget _buildDefaultThumbnail(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case '뉴스':
        iconData = Icons.newspaper;
        iconColor = Color(0xFF19B3F6);
        break;
      case '커뮤니티':
        iconData = Icons.forum;
        iconColor = Color(0xFF9B59B6);
        break;
      default:
        iconData = Icons.article;
        iconColor = Color(0xFF6C757D);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withOpacity(0.1),
            iconColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor.withOpacity(0.6),
          size: 24.sp,
        ),
      ),
    );
  }

  // 타입에 따른 색상 반환
  Color _getTypeColor(String type) {
    switch (type) {
      case '뉴스':
        return Color(0xFF19B3F6);
      case '커뮤니티':
        return Color(0xFF9B59B6);
      default:
        return AppTheme.isDark(context) ? Colors.grey[400]! : Colors.grey[600]!;
    }
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