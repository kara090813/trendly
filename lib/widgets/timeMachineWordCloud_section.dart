import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../app_theme.dart';

class TimeMachineWordCloudSection extends StatelessWidget {
  final Map<String, Color> categoryColors;
  final String? wordCloudImagePath;
  final List<String>? keywords; // 동적 키워드 리스트

  const TimeMachineWordCloudSection({
    Key? key,
    required this.categoryColors,
    this.wordCloudImagePath,
    this.keywords,
  }) : super(key: key);

  List<WordCloudItem> _generateDynamicLayout() {
    // 기본 키워드 (없을 경우 사용)
    final defaultKeywords = [
      '포켓몬', '갤럭시', 'AI', '트렌드', '뉴스', '키워드', '게임', '스마트폰', '기술', '엔터테인먼트',
      '스포츠', '경제', '정치', '문화', '음악', '영화', '드라마', '웹툰', '유튜브', '인스타그램',
      '틱톡', '카카오톡', '넷플릭스', '디즈니', '아마존', '구글', '애플', '테슬라', '비트코인', '메타버스'
    ];
    
    final keywordList = keywords ?? defaultKeywords;
    final wordCount = keywordList.length;
    
    // 순위별 크기 계산 (1위가 가장 큼)
    double _getRankBasedSize(int rank, int totalCount) {
      if (rank <= 3) {
        return 24.0 - (rank - 1) * 2; // 1위:24px, 2위:22px, 3위:20px
      } else if (rank <= 10) {
        return 18.0 - (rank - 4) * 1; // 4위:18px -> 10위:12px
      } else {
        final ratio = (rank - 11) / (totalCount - 11).clamp(1, double.infinity);
        return 12.0 - (ratio * 4); // 11위부터 점점 작아져서 8px까지
      }
    }
    
    // 동적 위치 생성 (겹치지 않는 배치)
    final items = <WordCloudItem>[];
    final random = math.Random(DateTime.now().millisecondsSinceEpoch ~/ 1000); // 시간 기반 시드
    final placedRects = <Rect>[];
    
    for (int i = 0; i < wordCount; i++) {
      final rank = i + 1;
      final fontSize = _getRankBasedSize(rank, wordCount);
      final keyword = keywordList[i];
      
      // 텍스트 크기 추정
      final estimatedWidth = keyword.length * fontSize * 0.6;
      final estimatedHeight = fontSize * 1.2;
      
      // 겹치지 않는 위치 찾기
      Offset? position = _findSafePosition(
        estimatedWidth,
        estimatedHeight,
        placedRects,
        random,
        rank,
        wordCount,
      );
      
      if (position != null) {
        final rect = Rect.fromLTWH(
          position.dx - estimatedWidth / 2,
          position.dy - estimatedHeight / 2,
          estimatedWidth,
          estimatedHeight,
        );
        placedRects.add(rect);
        
        items.add(WordCloudItem(
          keyword,
          position.dx,
          position.dy,
          fontSize,
          rank,
          color: categoryColors.values.elementAt(i % categoryColors.length),
        ));
      }
    }
    
    return items;
  }
  
  Offset? _findSafePosition(
    double width,
    double height,
    List<Rect> placedRects,
    math.Random random,
    int rank,
    int totalCount,
  ) {
    const int maxAttempts = 100; // 시도 횟수 줄여서 더 빠르게 배치
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      double x = 0.5, y = 0.5; // 기본값 초기화
      
      // 랭킹별 배치 전략
      if (rank <= 3) {
        // 상위 3위 - 중앙 핵심 영역
        x = 0.35 + random.nextDouble() * 0.3; // 35-65%
        y = 0.25 + random.nextDouble() * 0.5; // 25-75%
      } else if (rank <= 8) {
        // 4-8위 - 중앙 확장 영역
        x = 0.25 + random.nextDouble() * 0.5; // 25-75%
        y = 0.2 + random.nextDouble() * 0.6; // 20-80%
      } else if (rank <= 15) {
        // 9-15위 - 중간 영역 (중앙 피하기)
        if (random.nextBool()) {
          // 좌우 영역
          x = random.nextBool() ? 
              0.05 + random.nextDouble() * 0.25 : // 5-30% (왼쪽)
              0.7 + random.nextDouble() * 0.25;   // 70-95% (오른쪽)
          y = 0.1 + random.nextDouble() * 0.8; // 10-90%
        } else {
          // 상하 영역
          x = 0.1 + random.nextDouble() * 0.8; // 10-90%
          y = random.nextBool() ?
              0.05 + random.nextDouble() * 0.2 : // 5-25% (위)
              0.75 + random.nextDouble() * 0.2;  // 75-95% (아래)
        }
      } else {
        // 16위 이후 - 가장자리 영역
        final side = random.nextInt(4);
        switch (side) {
          case 0: // 왼쪽
            x = 0.05 + random.nextDouble() * 0.15; // 5-20%
            y = 0.05 + random.nextDouble() * 0.9;  // 5-95%
            break;
          case 1: // 오른쪽
            x = 0.8 + random.nextDouble() * 0.15;  // 80-95%
            y = 0.05 + random.nextDouble() * 0.9;  // 5-95%
            break;
          case 2: // 위
            x = 0.05 + random.nextDouble() * 0.9;  // 5-95%
            y = 0.05 + random.nextDouble() * 0.15; // 5-20%
            break;
          case 3: // 아래
            x = 0.05 + random.nextDouble() * 0.9;  // 5-95%
            y = 0.8 + random.nextDouble() * 0.15;  // 80-95%
            break;
        }
      }
      
      // 경계 보정
      x = x.clamp(0.05, 0.95);
      y = y.clamp(0.05, 0.95);
      
      final newRect = Rect.fromLTWH(
        x - width / 2,
        y - height / 2,
        width,
        height,
      );
      
      // 경계 체크
      if (newRect.left < 0.05 || newRect.right > 0.95 ||
          newRect.top < 0.05 || newRect.bottom > 0.95) {
        continue;
      }
      
      // 겹침 체크 (상위 랭크는 더 엄격하게, 하위 랭크는 관대하게)
      bool hasOverlap = false;
      final overlapThreshold = rank <= 10 ? 0.01 : 0.005; // 상위 랭크는 더 큰 여백
      
      for (final placedRect in placedRects) {
        if (newRect.overlaps(placedRect.inflate(overlapThreshold))) {
          hasOverlap = true;
          break;
        }
      }
      
      if (!hasOverlap) {
        return Offset(x, y);
      }
    }
    
    // 실패 시 랭킹별 기본 위치 반환
    if (rank <= 3) {
      return Offset(0.5, 0.4); // 중앙
    } else if (rank <= 8) {
      return Offset(
        0.3 + (rank - 4) * 0.1, // 30-70%로 분산
        0.3 + random.nextDouble() * 0.4,
      );
    } else {
      // 가장자리 배치
      final side = (rank - 9) % 4;
      switch (side) {
        case 0: return Offset(0.1, 0.5);
        case 1: return Offset(0.9, 0.5);
        case 2: return Offset(0.5, 0.1);
        case 3: return Offset(0.5, 0.9);
        default: return Offset(0.5, 0.5);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark(context);
    
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 24.h),
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
                          colors: [Color(0xFFB39DDB), Color(0xFF9C27B0)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "키워드 클라우드",
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
                    "AI가 분석한 키워드 연관성을 시각화",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideX(begin: -0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
          
          SizedBox(height: 24.h),
          
          // 워드클라우드 컨테이너
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            width: double.infinity,
            height: 260.h,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Stack(
                children: [
                  // 배경 그라데이션
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: isDark
                            ? [
                                Color(0xFF1E293B).withOpacity(0.8),
                                Color(0xFF0F172A),
                              ]
                            : [
                                Color(0xFFF8FAFC),
                                Color(0xFFE2E8F0),
                              ],
                      ),
                    ),
                  ),
                  
                  // 동적 워드클라우드
                  CustomPaint(
                    painter: StaticWordCloudPainter(
                      items: _generateDynamicLayout(),
                      isDark: isDark,
                    ),
                    size: Size.infinite,
                  ),
                  
                  
                  // 글래스 오버레이
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
              .scale(begin: Offset(0.98, 0.98), end: Offset(1, 1), duration: 600.ms),
          
          SizedBox(height: 24.h),
          
          // 카테고리 레전드
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Color(0xFF1E3A8A).withOpacity(0.2), Color(0xFF3B82F6).withOpacity(0.1)]
                    : [Color(0xFFE0E7FF), Color(0xFFEEF2FF)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Color(0xFF3B82F6).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "카테고리 색상 가이드",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  children: categoryColors.entries.map((entry) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: entry.value.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: entry.value.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: entry.value.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: entry.value,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate()
              .fadeIn(duration: 500.ms, delay: 1000.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isDark) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B82F6).withOpacity(0.1),
                      Color(0xFFB39DDB).withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFFB39DDB)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 36.sp,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          Text(
            "AI 분석 중...",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            "키워드 연관성을 분석하여\n워드클라우드를 생성하고 있습니다",
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 24.h),
          
          Container(
            width: 200.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFFB39DDB)],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms)
                    .slideX(duration: 2000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WordCloudItem {
  final String text;
  final double x;
  final double y;
  final double size;
  final int rank;
  Color? color;

  WordCloudItem(this.text, this.x, this.y, this.size, this.rank, {this.color});
}

class StaticWordCloudPainter extends CustomPainter {
  final List<WordCloudItem> items;
  final bool isDark;

  StaticWordCloudPainter({
    required this.items,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final margin = 20.0;
    final safeWidth = size.width - (margin * 2);
    final safeHeight = size.height - (margin * 2);
    
    // 랭킹 순으로 정렬 (하위 랭크부터 그려서 상위 랭크가 위에 오도록)
    final sortedItems = List<WordCloudItem>.from(items);
    sortedItems.sort((a, b) => b.rank.compareTo(a.rank)); // 내림차순 (높은 랭크부터)
    
    for (final item in sortedItems) {
      // 위치 계산 (비율을 실제 픽셀로 변환)
      final x = margin + (item.x * safeWidth);
      final y = margin + (item.y * safeHeight);
      
      // 텍스트 스타일
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.text,
          style: TextStyle(
            color: item.color?.withOpacity(0.9) ?? Colors.blue.withOpacity(0.9),
            fontSize: item.size,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: item.color?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // 중앙 정렬
      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      
      // 글로우 효과 (크기에 따라 조정)
      if (item.size >= 18) {
        final glowPaint = Paint()
          ..color = item.color?.withOpacity(0.15) ?? Colors.blue.withOpacity(0.15)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, item.size * 0.5);
        
        canvas.drawCircle(Offset(x, y), item.size * 0.8, glowPaint);
      }
      
      // 텍스트 그리기
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}