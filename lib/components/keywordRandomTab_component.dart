import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../app_theme.dart';
import '../widgets/_widgets.dart';

class RandomKeywordTabComponent extends StatefulWidget {
  const RandomKeywordTabComponent({Key? key}) : super(key: key);

  @override
  State<RandomKeywordTabComponent> createState() => _RandomKeywordTabComponentState();
}

class _RandomKeywordTabComponentState extends State<RandomKeywordTabComponent> 
    with TickerProviderStateMixin {
  bool _isRandomLoading = false;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentKeyword = _randomKeywords[_currentRandomIndex];
    
    return Stack(
      children: [
        // 배경 그라데이션 애니메이션
        Positioned.fill(
          child: AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ]
                    : [
                        Color(0xFFF8FAFC),
                        Color(0xFFE0E7FF),
                        Color(0xFFF8FAFC),
                      ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        
        // 플로팅 오브 효과 (최적화)
        ...List.generate(2, (index) => 
          Positioned(
            top: 150.h + (index * 300.h),
            left: index.isEven ? -30.w : null,
            right: index.isOdd ? -30.w : null,
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    index.isEven ? _floatingController.value * 20 : -_floatingController.value * 20,
                    _floatingController.value * 15,
                  ),
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (index == 0 ? Colors.blue : Colors.purple)
                              .withOpacity(0.2),
                          (index == 0 ? Colors.blue : Colors.purple)
                              .withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // 히어로 섹션
            SliverToBoxAdapter(
              child: _buildRandomKeywordHeader(currentKeyword),
            ),
            
            // 키워드 요약 섹션
            SliverToBoxAdapter(
              child: _buildKeywordSummary().animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.03, end: 0, duration: 600.ms),
            ),
            
            // 관련 뉴스 섹션  
            SliverToBoxAdapter(
              child: _buildRelatedNews().animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.03, end: 0, duration: 600.ms),
            ),
            
            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 100.h),
            ),
          ],
        ),
      ],
    );
  }


  // 랜덤 키워드 히어로 섹션 - TimeMachine 스타일
  Widget _buildRandomKeywordHeader(Map<String, dynamic> keyword) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 구조화된 타이틀
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFEF4444).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shuffle_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "랜덤 키워드",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "예상치 못한 트렌드를 발견하세요",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 32.h),
          
          // 키워드 선택 카드
          GestureDetector(
            onTap: _randomizeKeyword,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Color(0xFF1E293B), Color(0xFF0F172A)]
                      : [Colors.white, Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _isRandomLoading
                      ? Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFEF4444).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 24.sp,
                            height: 24.sp,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFEF4444).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shuffle_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          keyword["keyword"],
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor(context),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          keyword["date"],
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Color(0xFFEF4444).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      keyword["category"],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFEF4444),
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 800.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
              .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), duration: 800.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  // 키워드 요약 섹션 - TimeMachine 스타일
  Widget _buildKeywordSummary() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "키워드 요약",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "AI 분석 핵심 포인트",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 요약 내용 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNumberedPoint(
                    1,
                    "무표정 고양이 짤이 트위터에서 유행함.",
                  ),
                  SizedBox(height: 16.h),
                  _buildNumberedPoint(
                    2,
                    "이 짤은 이후 밈 채널에서 다양하게 재해석됨.",
                  ),
                  SizedBox(height: 16.h),
                  _buildNumberedPoint(
                    3,
                    "'짤줍'이라는 단어가 본격 확산되기 시작한 계기가 됨.",
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  // 번호가 있는 포인트 아이템 - TimeMachine 스타일
  Widget _buildNumberedPoint(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.4,
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 관련 뉴스 섹션 - TimeMachine 스타일
  Widget _buildRelatedNews() {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모던 섹션 헤더
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "관련 뉴스",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextColor(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "연관 뉴스 및 커뮤니티 반응",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 뉴스 리스트 컨테이너
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ..._newsData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Map<String, dynamic> newsItem = entry.value;
                    final isLast = index == _newsData.length - 1;
                    return _buildNewsCard(newsItem, index * 100, isLast);
                  }),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .slideY(begin: 0.03, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  // 뉴스 카드 - TimeMachine 스타일
  Widget _buildNewsCard(Map<String, dynamic> newsItem, int delay, bool isLast) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 이미지 또는 기본 이미지
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: isDark
                  ? Color(0xFF0F172A)
                  : Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.r),
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

          SizedBox(width: 16.w),

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
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // 커뮤니티/뉴스 타입 태그
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(newsItem['type']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        newsItem['type'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(newsItem['type']),
                        ),
                      ),
                    ),

                    Spacer(),

                    // 날짜
                    Text(
                      newsItem['date'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // 제목
                Text(
                  newsItem['title'],
                  style: TextStyle(
                    fontSize: 16.sp,
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
    ).animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.03, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  // 기본 썸네일 (썸네일이 없을 때) - TimeMachine 스타일
  Widget _buildDefaultThumbnail(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case '뉴스':
        iconData = Icons.newspaper_rounded;
        iconColor = Color(0xFF10B981);
        break;
      case '커뮤니티':
        iconData = Icons.forum_rounded;
        iconColor = Color(0xFF8B5CF6);
        break;
      default:
        iconData = Icons.article_rounded;
        iconColor = Color(0xFF6B7280);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withOpacity(0.15),
            iconColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor.withOpacity(0.7),
          size: 20.sp,
        ),
      ),
    );
  }

  // 타입에 따른 색상 반환 - TimeMachine 스타일
  Color _getTypeColor(String type) {
    switch (type) {
      case '뉴스':
        return Color(0xFF10B981);
      case '커뮤니티':
        return Color(0xFF8B5CF6);
      default:
        return AppTheme.isDark(context) ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

}